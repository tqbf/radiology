import AppKit

/// Read-only source surface. Besides the current-line and destination
/// highlights, it hosts the ⌘-hover affordance for semantic targets: an
/// underline and pointing hand only where an occurrence resolves to a
/// definition, ⌘-click to follow it, and context-menu actions.
final class ReaderTextView: NSTextView {
    struct PinnedDecoration: Equatable {
        let ranges: [NSRange]
        let colorSlot: Int
    }
    var destinationHighlightRange: NSRange?
    var destinationHighlightAlpha: CGFloat = 0
    /// Resolves a canonical byte offset to a target; nil when nothing is there.
    var semanticTarget: ((Int) -> SemanticTarget?)?
    var onSelectOccurrences: ((Int?) -> Void)?
    var onTogglePinnedOccurrences: ((Int?) -> Void)?
    var onGoToDefinition: ((Int) -> Void)?
    var onFindReferences: ((Int) -> Void)?
    /// UTF-16 offset → canonical byte, and back, through the owning buffer.
    var byteForUTF16: ((Int) -> Int)?
    var utf16RangeForBytes: ((Range<Int>) -> NSRange)?
    private(set) var hoverRange: NSRange?
    private var hoverByte: Int?
    private var trackingArea: NSTrackingArea?
    private var modifierMonitor: Any?
    private var menuByte: Int?
    var occurrenceHighlightRanges: [NSRange] = [] {
        didSet { if occurrenceHighlightRanges != oldValue { needsDisplay = true } }
    }
    var activeOccurrenceHighlightRange: NSRange? {
        didSet { if activeOccurrenceHighlightRange != oldValue { needsDisplay = true } }
    }
    var pinnedOccurrenceDecorations: [PinnedDecoration] = [] {
        didSet { if pinnedOccurrenceDecorations != oldValue { needsDisplay = true } }
    }

    isolated deinit {
        if let modifierMonitor { NSEvent.removeMonitor(modifierMonitor) }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let modifierMonitor { NSEvent.removeMonitor(modifierMonitor) }
        modifierMonitor = nil
        guard window != nil else { return }
        // `flagsChanged` is otherwise delivered only to the first responder.
        // A local monitor keeps Cmd-hover honest when the outline or search
        // field owns focus and the pointer is already resting over source.
        modifierMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.updateHoverForCurrentPointer(commandDown: event.modifierFlags.contains(.command))
            return event
        }
    }

    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)
        guard layoutManager != nil, textContainer != nil, !string.isEmpty else { return }
        if let destinationHighlightRange, destinationHighlightAlpha > 0 {
            drawLine(at: destinationHighlightRange.location, in: rect,
                     color: .controlAccentColor.withAlphaComponent(destinationHighlightAlpha))
        }
        let index = min(selectedRange().location, (string as NSString).length - 1)
        drawLine(at: max(0, index), in: rect, color: .controlAccentColor.withAlphaComponent(0.05))
        for decoration in pinnedOccurrenceDecorations {
            let colors = Theme.pinnedOccurrenceColors(slot: decoration.colorSlot, appearance: effectiveAppearance)
            for range in decoration.ranges {
                drawOccurrence(range, in: rect, color: colors.fill, strokeColor: colors.stroke, lineWidth: 1.4)
            }
        }
        for range in occurrenceHighlightRanges where range != activeOccurrenceHighlightRange {
            drawOccurrence(range, in: rect, color: Theme.semanticOccurrenceColor)
        }
        if let activeOccurrenceHighlightRange {
            drawOccurrence(activeOccurrenceHighlightRange, in: rect,
                           color: Theme.activeSemanticOccurrenceColor,
                           strokeColor: .controlAccentColor.withAlphaComponent(0.55))
        }
    }

    /// Paints only glyphs TextKit currently shows. Null glyphs inside folds do
    /// not contribute rectangles, preventing hidden occurrences from stacking
    /// on the surviving fold line. This is drawing-only: no text attributes,
    /// selection, or canonical source storage are touched.
    private func drawOccurrence(_ characterRange: NSRange, in dirtyRect: NSRect,
                                color: NSColor, strokeColor: NSColor? = nil, lineWidth: CGFloat = 1) {
        guard let layoutManager, let textContainer,
              characterRange.length > 0,
              characterRange.location >= 0,
              NSMaxRange(characterRange) <= (string as NSString).length else { return }
        let glyphRange = layoutManager.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)
        guard glyphRange.length > 0 else { return }
        var shownStart: Int?
        let end = NSMaxRange(glyphRange)
        for glyph in glyphRange.location...end {
            let shown = glyph < end && !layoutManager.notShownAttribute(forGlyphAt: glyph)
            if shown, shownStart == nil { shownStart = glyph }
            if !shown, let start = shownStart {
                drawShownGlyphs(NSRange(location: start, length: glyph - start), in: dirtyRect,
                                container: textContainer, layout: layoutManager,
                                color: color, strokeColor: strokeColor, lineWidth: lineWidth)
                shownStart = nil
            }
        }
    }

    private func drawShownGlyphs(_ glyphRange: NSRange, in dirtyRect: NSRect,
                                 container: NSTextContainer, layout: NSLayoutManager,
                                 color: NSColor, strokeColor: NSColor?, lineWidth: CGFloat) {
        layout.enumerateEnclosingRects(forGlyphRange: glyphRange, withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0), in: container) { [self] rect, _ in
            var highlight = rect.offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
            highlight = highlight.insetBy(dx: -1.5, dy: 0)
            guard highlight.intersects(dirtyRect) else { return }
            let path = NSBezierPath(roundedRect: highlight, xRadius: 2.5, yRadius: 2.5)
            color.setFill()
            path.fill()
            if let strokeColor {
                strokeColor.setStroke()
                path.lineWidth = lineWidth
                path.stroke()
            }
        }
    }

    private func drawLine(at characterIndex: Int, in dirtyRect: NSRect, color: NSColor) {
        guard let layoutManager, let textContainer else { return }
        let clamped = min(max(0, characterIndex), max(0, (string as NSString).length - 1))
        let glyph = layoutManager.glyphIndexForCharacter(at: clamped)
        var line = layoutManager.lineFragmentRect(forGlyphAt: glyph, effectiveRange: nil)
        line.origin.y += textContainerOrigin.y
        line.origin.x = 0
        line.size.width = max(bounds.width, textContainer.size.width.isFinite ? min(textContainer.size.width, bounds.width) : bounds.width)
        color.setFill()
        line.intersection(dirtyRect).fill()
    }

    // MARK: - Semantic hover

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea { removeTrackingArea(trackingArea) }
        let area = NSTrackingArea(rect: .zero, options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        updateHover(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        clearHover()
    }

    override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
        updateHoverForCurrentPointer(commandDown: event.modifierFlags.contains(.command))
    }

    private func updateHoverForCurrentPointer(commandDown: Bool) {
        guard commandDown, let window else { clearHover(); return }
        let location = window.mouseLocationOutsideOfEventStream
        updateHover(at: convert(location, from: nil), commandDown: true)
    }

    private func updateHover(with event: NSEvent) {
        updateHover(at: convert(event.locationInWindow, from: nil), commandDown: event.modifierFlags.contains(.command))
    }

    private func updateHover(at point: NSPoint, commandDown: Bool) {
        guard commandDown, let byte = byte(at: point), let target = semanticTarget?(byte), target.hasDefinition,
              let range = utf16RangeForBytes?(target.byteRange), range.length > 0 else {
            clearHover()
            return
        }
        guard range != hoverRange else { return }
        clearHover()
        hoverRange = range
        hoverByte = byte
        layoutManager?.addTemporaryAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue,
                                               .underlineColor: Theme.semanticUnderlineColor], forCharacterRange: range)
        NSCursor.pointingHand.set()
    }

    /// Removes the affordance. Safe to call at any time, including after the
    /// index or buffer behind it was replaced.
    func clearHover() {
        if let hoverRange, let layoutManager, NSMaxRange(hoverRange) <= (string as NSString).length {
            layoutManager.removeTemporaryAttribute(.underlineStyle, forCharacterRange: hoverRange)
            layoutManager.removeTemporaryAttribute(.underlineColor, forCharacterRange: hoverRange)
        }
        if hoverRange != nil { NSCursor.iBeam.set() }
        hoverRange = nil
        hoverByte = nil
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        if hoverRange != nil { NSCursor.pointingHand.set() }
    }

    /// The canonical byte under a view point, or nil when the point is past the
    /// end of a line, inside folded (not shown) text, or outside the text.
    func byte(at point: NSPoint) -> Int? {
        guard let layoutManager, let textContainer, !string.isEmpty else { return nil }
        let local = NSPoint(x: point.x - textContainerOrigin.x, y: point.y - textContainerOrigin.y)
        var fraction: CGFloat = 0
        let glyph = layoutManager.glyphIndex(for: local, in: textContainer, fractionOfDistanceThroughGlyph: &fraction)
        guard glyph < layoutManager.numberOfGlyphs, !layoutManager.notShownAttribute(forGlyphAt: glyph) else { return nil }
        let rect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyph, length: 1), in: textContainer)
        guard rect.insetBy(dx: -1, dy: -1).contains(local) else { return nil }
        let character = layoutManager.characterIndexForGlyph(at: glyph)
        return byteForUTF16?(character)
    }

    // MARK: - Clicks and menus

    override func mouseDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            if event.clickCount == 1,
               let byte = byte(at: convert(event.locationInWindow, from: nil)),
               let target = semanticTarget?(byte), target.hasDefinition {
                clearHover()
                onGoToDefinition?(byte)
            } else {
                super.mouseDown(with: event)
            }
            return
        }
        let selectedByte = event.clickCount <= 2 ? byte(at: convert(event.locationInWindow, from: nil)) : nil
        super.mouseDown(with: event)
        if event.clickCount >= 2 {
            onTogglePinnedOccurrences?(selectedByte)
        } else if event.clickCount == 1 && selectedRange().length == 0 {
            onSelectOccurrences?(selectedByte)
        }
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        let menu = super.menu(for: event) ?? NSMenu()
        guard let byte = byte(at: convert(event.locationInWindow, from: nil)), let target = semanticTarget?(byte) else { return menu }
        menuByte = byte
        let definition = NSMenuItem(title: "Go to Definition of \u{201C}\(target.displayName)\u{201D}", action: #selector(goToDefinitionFromMenu), keyEquivalent: "")
        definition.target = self
        definition.isEnabled = target.hasDefinition
        let references = NSMenuItem(title: "Find References to \u{201C}\(target.displayName)\u{201D}", action: #selector(findReferencesFromMenu), keyEquivalent: "")
        references.target = self
        menu.insertItem(NSMenuItem.separator(), at: 0)
        menu.insertItem(references, at: 0)
        menu.insertItem(definition, at: 0)
        menu.autoenablesItems = false
        return menu
    }

    @objc private func goToDefinitionFromMenu() {
        if let menuByte { onGoToDefinition?(menuByte) }
    }

    @objc private func findReferencesFromMenu() {
        if let menuByte { onFindReferences?(menuByte) }
    }
}
