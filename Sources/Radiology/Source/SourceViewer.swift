import SwiftUI

struct SourceViewer: NSViewRepresentable {
    let buffer: SourceBuffer
    let fontSize: CGFloat
    let syntax: SyntaxSnapshot?
    let target: SourceLocation?
    let revision: Int
    let selectsTarget: Bool
    let focusRevision: Int
    let foldToDefinitionsRevision: Int
    let collapseFunctionsRevision: Int
    let highlightTarget: SourceLocation?
    let highlightRevision: Int
    /// Changes when the semantic index or the file's occurrence map changes.
    let semanticRevision: Int
    let semanticTarget: (Int) -> SemanticTarget?
    let occurrenceHighlightRanges: [Range<Int>]
    let activeOccurrenceHighlightRange: Range<Int>?
    let pinnedOccurrenceGroups: [PinnedOccurrenceGroup]
    let onSelectOccurrences: (Int?) -> Void
    let onTogglePinnedOccurrences: (Int?) -> Void
    let onGoToDefinition: (Int) -> Void
    let onFindReferences: (Int) -> Void
    let onCaret: (Int) -> Void
    let onPosition: (Int, Int) -> Void

    func makeCoordinator() -> SourceViewerCoordinator { SourceViewerCoordinator() }

    func makeNSView(context: Context) -> SourceContainerView {
        let view = SourceContainerView()
        let scroll = view.scroll
        view.addSubview(scroll)
        scroll.hasVerticalScroller = true
        scroll.hasHorizontalScroller = true
        scroll.autohidesScrollers = true
        scroll.borderType = .noBorder
        let text = ReaderTextView(frame: NSRect(origin: .zero, size: scroll.contentSize))
        text.isEditable = false
        text.isSelectable = true
        text.isRichText = false
        text.isAutomaticLinkDetectionEnabled = false
        text.isAutomaticQuoteSubstitutionEnabled = false
        text.isAutomaticDashSubstitutionEnabled = false
        text.allowsUndo = false
        text.usesFindBar = true
        text.isIncrementalSearchingEnabled = true
        text.textContainerInset = NSSize(width: Theme.sourceInset, height: Theme.sourceInset)
        text.isVerticallyResizable = true
        text.isHorizontallyResizable = true
        text.minSize = NSSize(width: 0, height: 0)
        text.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        text.autoresizingMask = [.width]
        text.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        text.textContainer?.widthTracksTextView = false
        text.setAccessibilityLabel("Read-only source code")
        text.delegate = context.coordinator
        text.layoutManager?.delegate = context.coordinator
        scroll.documentView = text
        let ruler = LineNumberGutter(textView: text)
        view.gutter = ruler
        view.addSubview(ruler)
        context.coordinator.gutter = ruler
        context.coordinator.textView = text
        context.coordinator.scrollView = scroll
        scroll.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(SourceViewerCoordinator.didScroll), name: NSView.boundsDidChangeNotification, object: scroll.contentView)
        return view
    }

    func updateNSView(_ view: SourceContainerView, context: Context) {
        let scroll = view.scroll
        let coordinator = context.coordinator
        guard let text = coordinator.textView else { return }
        coordinator.onPosition = onPosition
        coordinator.onCaret = onCaret
        coordinator.updating = true
        defer { coordinator.updating = false }
        if let reader = text as? ReaderTextView {
            reader.semanticTarget = semanticTarget
            reader.onSelectOccurrences = onSelectOccurrences
            reader.onTogglePinnedOccurrences = onTogglePinnedOccurrences
            reader.onGoToDefinition = onGoToDefinition
            reader.onFindReferences = onFindReferences
            reader.byteForUTF16 = { [buffer] in buffer.byteOffset(forUTF16: $0) }
            reader.utf16RangeForBytes = { [buffer] in buffer.utf16Range(forByteRange: $0) }
            reader.occurrenceHighlightRanges = occurrenceHighlightRanges.map(buffer.utf16Range(forByteRange:))
            reader.activeOccurrenceHighlightRange = activeOccurrenceHighlightRange.map(buffer.utf16Range(forByteRange:))
            reader.pinnedOccurrenceDecorations = pinnedOccurrenceGroups.map { group in
                ReaderTextView.PinnedDecoration(ranges: group.byteRanges.map(buffer.utf16Range(forByteRange:)),
                                                colorSlot: group.colorSlot)
            }
            let pinnedCount = pinnedOccurrenceGroups.reduce(0) { $0 + $1.byteRanges.count }
            let transientCount = occurrenceHighlightRanges.count
            let help: String
            if pinnedCount > 0 {
                help = "\(pinnedOccurrenceGroups.count) pinned symbol groups, \(pinnedCount) pinned occurrences. Double-click a pinned occurrence to unlock it."
            } else if transientCount > 0 {
                help = "\(transientCount) occurrences highlighted. Double-click to pin this symbol."
            } else {
                help = "Read-only source code. Double-click a symbol to pin its occurrences."
            }
            reader.setAccessibilityHelp(help)
            if coordinator.semanticRevision != semanticRevision {
                coordinator.semanticRevision = semanticRevision
                reader.clearHover()
            }
        }
        let changed = coordinator.buffer?.path != buffer.path || coordinator.buffer?.data != buffer.data
        let syntaxChanged = coordinator.syntax != syntax
        var appliedDefaultFolds = false
        var appliedFoldLayout = false
        if changed || syntaxChanged || text.font?.pointSize != fontSize {
            if changed { coordinator.cancelDestinationHighlight() }
            (text as? ReaderTextView)?.clearHover()
            appliedDefaultFolds = coordinator.updateSyntax(syntax, buffer: buffer, resetFolds: changed)
            let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
            let paragraph = NSMutableParagraphStyle()
            paragraph.minimumLineHeight = max(Theme.sourceLineHeight, fontSize * 1.55)
            paragraph.maximumLineHeight = paragraph.minimumLineHeight
            paragraph.tabStops = []
            paragraph.defaultTabInterval = font.maximumAdvancement.width * 4
            let attributed = NSMutableAttributedString(string: buffer.text, attributes: [.font: font, .foregroundColor: NSColor.textColor, .paragraphStyle: paragraph])
            if syntax?.path == buffer.path {
                for highlight in syntax?.highlights ?? [] {
                    let range = buffer.utf16Range(forByteRange: highlight.byteRange)
                    guard range.location + range.length <= attributed.length else { continue }
                    attributed.addAttribute(.foregroundColor, value: Theme.SyntaxColors.color(for: highlight.name), range: range)
                }
            }
            if changed { coordinator.prepareForSourceReplacement() }
            text.textStorage?.setAttributedString(attributed)
            if changed { coordinator.finishSourceReplacement() }
            text.font = font
            text.backgroundColor = .textBackgroundColor
            if let ruler = view.gutter {
                ruler.buffer = buffer
                ruler.fontSize = fontSize
                ruler.folds = syntax?.folds ?? []
                ruler.onToggleFold = { [weak coordinator] fold in coordinator?.toggleFold(fold) }
            }
            // Resolve default folds against a pending/restored destination
            // before asking TextKit to generate any folded glyphs. Applying
            // one fold layout and immediately invalidating it again to reveal
            // the destination can re-enter NSATSTypesetter on large files.
            if changed || coordinator.revision != revision || appliedDefaultFolds {
                let byte = target?.path == buffer.path ? target?.byteOffset ?? 0 : 0
                coordinator.reveal(byteOffset: byte, applyAttributes: false)
            }
            coordinator.applyFoldAttributes()
            appliedFoldLayout = true
        }
        if changed || coordinator.revision != revision || appliedDefaultFolds {
            coordinator.revision = revision
            coordinator.cancelDestinationHighlight()
            (text as? ReaderTextView)?.clearHover()
            let byte = target?.path == buffer.path ? target?.byteOffset ?? 0 : 0
            let range = NSRange(location: buffer.utf16Offset(forByte: byte), length: 0)
            // The changed/syntax/font branch already revealed this target and
            // generated the folded glyph tree. Invalidating the same large
            // document again in this update can re-enter NSATSTypesetter and
            // corrupt its glyph-to-character mapping.
            coordinator.reveal(byteOffset: byte, applyAttributes: !appliedFoldLayout)
            if selectsTarget { text.setSelectedRange(range) }
            coordinator.programmaticPositionByte = byte
            scroll.pendingLocation = range.location
            scroll.needsLayout = true
            coordinator.settleNavigation(atUTF16: range.location, revision: revision)
            view.gutter?.currentLine = buffer.line(atByte: byte)
        }
        if coordinator.foldToDefinitionsRevision != foldToDefinitionsRevision {
            coordinator.foldToDefinitionsRevision = foldToDefinitionsRevision
            coordinator.foldToDefinitions()
        }
        if coordinator.collapseFunctionsRevision != collapseFunctionsRevision {
            coordinator.collapseFunctionsRevision = collapseFunctionsRevision
            coordinator.collapseFunctions()
        }
        if coordinator.highlightRevision != highlightRevision {
            coordinator.highlightRevision = highlightRevision
            if highlightTarget?.path == buffer.path, let byte = highlightTarget?.byteOffset {
                coordinator.flashDestination(atUTF16: buffer.utf16Offset(forByte: byte))
            }
        }
        if coordinator.focusRevision != focusRevision {
            coordinator.focusRevision = focusRevision
            DispatchQueue.main.async { [weak text] in
                guard let text, let window = text.window else { return }
                window.makeFirstResponder(text)
            }
        }
        view.gutter?.needsDisplay = true
        text.needsDisplay = true
    }

    static func dismantleNSView(_ view: SourceContainerView, coordinator: SourceViewerCoordinator) {
        NotificationCenter.default.removeObserver(coordinator)
    }
}
