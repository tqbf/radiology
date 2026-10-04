import AppKit

@MainActor
final class SourceViewerCoordinator: NSObject, NSTextViewDelegate {
    weak var textView: NSTextView?
    weak var scrollView: NSScrollView?
    weak var gutter: LineNumberGutter?
    var buffer: SourceBuffer?
    var syntax: SyntaxSnapshot?
    var onPosition: ((Int, Int) -> Void)?
    var onCaret: ((Int) -> Void)?
    var revision = -1
    var focusRevision = -1
    var foldToDefinitionsRevision = 0
    var collapseFunctionsRevision = 0
    var highlightRevision = 0
    var semanticRevision = -1
    var updating = false
    var programmaticPositionByte: Int?
    private var foldedIDs = Set<String>()
    private var foldedCharacterRanges: [NSRange] = []
    private var highlightTask: Task<Void, Never>?
    private var navigationLayoutTask: Task<Void, Never>?
    private var appliedDefaultFunctionFolds = false

    /// `foldedCharacterRanges` is sorted and disjoint. Glyph generation is a
    /// per-character hot path, so membership must be logarithmic rather than a
    /// linear scan across every function in a large file.
    private func isCharacterFolded(_ location: Int) -> Bool {
        var lower = 0
        var upper = foldedCharacterRanges.count
        while lower < upper {
            let middle = lower + (upper - lower) / 2
            let range = foldedCharacterRanges[middle]
            if location < range.location {
                upper = middle
            } else if location >= NSMaxRange(range) {
                lower = middle + 1
            } else {
                return true
            }
        }
        return false
    }

    /// Returns true when function folds were applied for the first time for
    /// this loaded buffer. The caller can then re-reveal a pending target.
    func updateSyntax(_ snapshot: SyntaxSnapshot?, buffer: SourceBuffer, resetFolds: Bool) -> Bool {
        self.buffer = buffer
        syntax = snapshot
        if resetFolds {
            foldedIDs.removeAll()
            appliedDefaultFunctionFolds = false
        }
        var appliedDefault = false
        if let snapshot, !appliedDefaultFunctionFolds {
            appliedDefaultFunctionFolds = true
            // `updateSyntax` runs before SourceViewer replaces TextKit's
            // attributed string. Only update fold state here: invalidating
            // glyphs with ranges from the new buffer while the layout manager
            // still owns the previous file can raise NSRunStorage exceptions.
            foldedIDs.formUnion(snapshot.folds.lazy.filter { $0.kind == "function" }.map(\.id))
            appliedDefault = true
        }
        gutter?.foldedIDs = foldedIDs
        return appliedDefault
    }

    func toggleFold(_ fold: SourceFold) {
        if foldedIDs.contains(fold.id) { foldedIDs.remove(fold.id) } else { foldedIDs.insert(fold.id) }
        applyFoldAttributes()
        gutter?.foldedIDs = foldedIDs
        gutter?.needsDisplay = true
    }

    func isFolded(_ fold: SourceFold) -> Bool { foldedIDs.contains(fold.id) }

    func foldToDefinitions() {
        guard let syntax else { return }
        foldedIDs = Set(syntax.folds.filter { fold in
            if fold.kind == "function" { return true }
            guard fold.kind == "type" else { return false }
            // Keep containers open when they expose nested declarations.
            return !syntax.symbols.contains {
                fold.byteRange.lowerBound <= $0.byteRange.lowerBound
                    && $0.byteRange.upperBound <= fold.byteRange.upperBound
            }
        }.map(\.id))
        applyFoldAttributes()
        gutter?.foldedIDs = foldedIDs
        gutter?.needsDisplay = true
    }

    func collapseFunctions() {
        guard let syntax else { return }
        foldedIDs.formUnion(syntax.folds.lazy.filter { $0.kind == "function" }.map(\.id))
        applyFoldAttributes()
        gutter?.foldedIDs = foldedIDs
        gutter?.needsDisplay = true
    }

    func reveal(byteOffset: Int, applyAttributes: Bool = true) {
        guard let syntax else { return }
        let hidden = syntax.folds.filter { foldedIDs.contains($0.id) && $0.byteRange.contains(byteOffset) }
        guard !hidden.isEmpty else { return }
        foldedIDs.subtract(hidden.map(\.id))
        if applyAttributes { applyFoldAttributes() }
        gutter?.foldedIDs = foldedIDs
    }

    func flashDestination(atUTF16 offset: Int, hold: Duration = .milliseconds(900)) {
        guard let textView = textView as? ReaderTextView else { return }
        highlightTask?.cancel()
        textView.destinationHighlightRange = NSRange(location: offset, length: 0)
        textView.destinationHighlightAlpha = Theme.destinationHighlightAlpha
        textView.needsDisplay = true
        highlightTask = Task { @MainActor [weak self, weak textView] in
            try? await Task.sleep(for: hold)
            guard let self, let textView, !Task.isCancelled else { return }
            if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
                clearDestinationHighlight(in: textView)
                return
            }
            for step in 1...6 {
                try? await Task.sleep(for: .milliseconds(35))
                guard !Task.isCancelled else { return }
                textView.destinationHighlightAlpha = Theme.destinationHighlightAlpha * CGFloat(6 - step) / 6
                textView.needsDisplay = true
            }
            clearDestinationHighlight(in: textView)
        }
    }

    func cancelDestinationHighlight() {
        highlightTask?.cancel()
        if let textView = textView as? ReaderTextView { clearDestinationHighlight(in: textView) }
    }

    func settleNavigation(atUTF16 offset: Int, revision: Int) {
        navigationLayoutTask?.cancel()
        navigationLayoutTask = Task { @MainActor [weak self] in
            await Task.yield()
            guard let self, !Task.isCancelled, self.revision == revision,
                  let scrollView = self.scrollView as? SourceScrollView else { return }
            scrollView.pendingLocation = offset
            scrollView.needsLayout = true
            scrollView.layoutSubtreeIfNeeded()
        }
    }

    private func clearDestinationHighlight(in textView: ReaderTextView) {
        textView.destinationHighlightRange = nil
        textView.destinationHighlightAlpha = 0
        textView.needsDisplay = true
    }

    func applyFoldAttributes() {
        guard let textView, let buffer, let layout = textView.layoutManager else { return }
        (textView as? ReaderTextView)?.clearHover()
        let previousRanges = foldedCharacterRanges
        let activeFolds = (syntax?.folds ?? []).filter { foldedIDs.contains($0.id) }
        var requestedRanges = activeFolds.map { hiddenRange(for: $0, buffer: buffer) }
        requestedRanges.removeAll { $0.length == 0 }
        requestedRanges.sort {
            $0.location == $1.location ? $0.length > $1.length : $0.location < $1.location
        }
        // TextKit must see a disjoint set. Feeding both a collapsed function
        // and its nested local functions/closures into glyph generation can
        // replace the same glyph run twice, corrupting character mapping and
        // surfacing nested markers on the parent's surviving closing brace.
        foldedCharacterRanges = requestedRanges.reduce(into: []) { ranges, candidate in
            guard !ranges.contains(where: { NSLocationInRange(candidate.location, $0)
                && NSMaxRange(candidate) <= NSMaxRange($0) }) else { return }
            ranges.append(candidate)
        }
        guard previousRanges != foldedCharacterRanges else {
            gutter?.needsDisplay = true
            textView.needsDisplay = true
            return
        }
        if layout.delegate !== self { layout.delegate = self }
        let removed = previousRanges.filter { !foldedCharacterRanges.contains($0) }
        let added = foldedCharacterRanges.filter { !previousRanges.contains($0) }
        let changed = removed + added
        let invalidStart = changed.map(\.location).min() ?? 0
        let invalidEnd = changed.map(NSMaxRange).max() ?? buffer.utf16Count
        let glyphRange = NSRange(location: invalidStart, length: max(0, invalidEnd - invalidStart))
        let downstreamLayout = NSRange(location: invalidStart,
                                       length: max(0, buffer.utf16Count - invalidStart))
        layout.invalidateGlyphs(forCharacterRange: glyphRange,
                                changeInLength: 0, actualCharacterRange: nil)
        // Only the changed fold needs new glyph properties. Its height affects
        // every subsequent fragment, so downstream layout is invalidated while
        // the rest of the document's glyph cache remains intact.
        layout.invalidateLayout(forCharacterRange: downstreamLayout, actualCharacterRange: nil)
        textView.needsLayout = true
        textView.needsDisplay = true
    }

    /// Clears old-file fold state before TextKit's backing string is replaced.
    /// The delegate is detached only across the replacement boundary; toggling
    /// it during ordinary folds can make the typesetter briefly lay out every
    /// hidden newline and leave hundreds of empty fragments behind.
    func prepareForSourceReplacement() {
        foldedCharacterRanges.removeAll(keepingCapacity: true)
        textView?.layoutManager?.delegate = nil
    }

    func finishSourceReplacement() {
        textView?.layoutManager?.delegate = self
    }

    /// Brace-, bracket-, or quote-delimited bodies keep their delimiters
    /// visible, so a collapsed function still reads as `{}`. Bodies delimited
    /// by indentation instead — Python blocks, Kotlin `statements`, Swift
    /// `statements` — are hidden whole, because leaving their first and last
    /// characters behind would show meaningless fragments.
    private func hiddenRange(for fold: SourceFold, buffer: SourceBuffer) -> NSRange {
        let range = buffer.utf16Range(forByteRange: fold.byteRange)
        guard range.length > 0 else { return NSRange(location: range.location, length: 0) }
        guard isDelimited(fold.byteRange, in: buffer) else { return range }
        guard range.length > 2 else { return NSRange(location: range.location, length: 0) }
        return NSRange(location: range.location + 1, length: range.length - 2)
    }

    private func isDelimited(_ byteRange: Range<Int>, in buffer: SourceBuffer) -> Bool {
        let openers: Set<UInt8> = [0x7B, 0x5B, 0x28, 0x22, 0x27, 0x60]  // { [ ( " \' `
        let closers: Set<UInt8> = [0x7D, 0x5D, 0x29, 0x22, 0x27, 0x60]  // } ] ) " \' `
        guard byteRange.lowerBound >= 0, byteRange.upperBound <= buffer.data.count,
              byteRange.count >= 2 else { return false }
        return openers.contains(buffer.data[byteRange.lowerBound])
            && closers.contains(buffer.data[byteRange.upperBound - 1])
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        guard !updating, let textView, let buffer else { return }
        let byte = buffer.byteOffset(forUTF16: textView.selectedRange().location)
        let line = buffer.line(atByte: byte)
        gutter?.currentLine = line
        gutter?.needsDisplay = true
        textView.needsDisplay = true
        onPosition?(byte, line)
        onCaret?(byte)
    }

    @objc func didScroll(_ notification: Notification) {
        gutter?.needsDisplay = true
        guard !updating, let textView, let buffer, let layout = textView.layoutManager, let container = textView.textContainer else { return }
        if let byte = programmaticPositionByte {
            programmaticPositionByte = nil
            onPosition?(byte, buffer.line(atByte: byte))
            return
        }
        let point = NSPoint(x: 0, y: max(0, textView.visibleRect.minY))
        let glyph = layout.glyphIndex(for: point, in: container)
        let utf16 = glyph < layout.numberOfGlyphs ? layout.characterIndexForGlyph(at: glyph) : buffer.utf16Count
        let byte = buffer.byteOffset(forUTF16: utf16)
        let selectedByte = buffer.byteOffset(forUTF16: textView.selectedRange().location)
        onPosition?(byte, buffer.line(atByte: selectedByte))
    }
}

extension SourceViewerCoordinator: @preconcurrency NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager,
                       shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>,
                       properties: UnsafePointer<NSLayoutManager.GlyphProperty>,
                       characterIndexes: UnsafePointer<Int>, font: NSFont,
                       forGlyphRange glyphRange: NSRange) -> Int {
        var adjusted = Array(UnsafeBufferPointer(start: properties, count: glyphRange.length))
        for index in adjusted.indices {
            if isCharacterFolded(characterIndexes[index]) {
                // Preserve TextKit's original glyph semantics and add only the
                // visibility bit. Hidden control characters receive a zero-
                // advancement action below, so newlines compact without
                // corrupting the glyph/character mapping after a large fold.
                adjusted[index].insert(.null)
            } else {
                adjusted[index].remove(.null)
            }
        }
        adjusted.withUnsafeBufferPointer { pointer in
            guard let baseAddress = pointer.baseAddress else { return }
            layoutManager.setGlyphs(glyphs, properties: baseAddress, characterIndexes: characterIndexes,
                                    font: font, forGlyphRange: glyphRange)
        }
        return glyphRange.length
    }

    func layoutManager(_ layoutManager: NSLayoutManager,
                       shouldUse action: NSLayoutManager.ControlCharacterAction,
                       forControlCharacterAt charIndex: Int) -> NSLayoutManager.ControlCharacterAction {
        isCharacterFolded(charIndex) ? .zeroAdvancement : action
    }
}
