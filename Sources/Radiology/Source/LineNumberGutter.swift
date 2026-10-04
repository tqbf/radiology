import AppKit

final class LineNumberGutter: NSView {
    private weak var textView: NSTextView?
    override var isFlipped: Bool { true }
    override var wantsDefaultClipping: Bool { true }
    var buffer: SourceBuffer?
    var fontSize = Theme.sourceFontSize
    var currentLine = 1
    var folds: [SourceFold] = []
    var foldedIDs = Set<String>()
    var onToggleFold: ((SourceFold) -> Void)?
    private var foldHitRects: [String: NSRect] = [:]
    private var foldTooltips: [NSView.ToolTipTag] = []
    private var foldTooltipText: [NSView.ToolTipTag: String] = [:]

    init(textView: NSTextView) {
        self.textView = textView
        super.init(frame: .zero)
        setAccessibilityLabel("Source line numbers and folding controls")
        setAccessibilityHelp("Click a disclosure control to collapse or expand a source region.")
    }
    required init(coder: NSCoder) { fatalError("LineNumberGutter is constructed programmatically.") }

    override func draw(_ rect: NSRect) {
        NSColor.windowBackgroundColor.setFill()
        bounds.fill()
        for tag in foldTooltips { removeToolTip(tag) }
        foldTooltips.removeAll(keepingCapacity: true)
        foldTooltipText.removeAll(keepingCapacity: true)
        foldHitRects.removeAll(keepingCapacity: true)
        var collapsedFunctionDescriptions: [String] = []
        guard let text = textView, let layout = text.layoutManager,
              let container = text.textContainer, let buffer else { return }
        let visible = text.visibleRect
        let contentFrame: NSRect
        if let clip = text.enclosingScrollView?.contentView {
            contentFrame = clip.convert(clip.bounds, to: self)
        } else {
            contentFrame = bounds
        }
        let glyphs = layout.glyphRange(forBoundingRect: visible.offsetBy(dx: -text.textContainerOrigin.x, dy: -text.textContainerOrigin.y), in: container)
        let font = NSFont.monospacedDigitSystemFont(ofSize: fontSize - 1, weight: .regular)
        var rows: [(line: Int, y: CGFloat)] = []
        var seenLines = Set<Int>()
        layout.enumerateLineFragments(forGlyphRange: glyphs) { rect, _, _, glyphRange, _ in
            guard let glyph = Self.firstVisibleGlyph(in: glyphRange, layout: layout) else { return }
            let offset = layout.characterIndexForGlyph(at: glyph)
            let line = buffer.line(atByte: buffer.byteOffset(forUTF16: offset))
            // A wrapped fragment should not repeat the canonical source number.
            guard seenLines.insert(line).inserted else { return }
            let y = rect.minY + text.textContainerOrigin.y - visible.minY + contentFrame.minY
            rows.append((line, y))
        }
        if glyphs.location + glyphs.length >= layout.numberOfGlyphs,
           buffer.text.hasSuffix("\n"), seenLines.insert(buffer.lineCount).inserted {
            rows.append((buffer.lineCount, layout.extraLineFragmentRect.minY
                         + text.textContainerOrigin.y - visible.minY + contentFrame.minY))
        }
        for (line, y) in rows {
            guard y < contentFrame.maxY, y + Theme.sourceLineHeight > contentFrame.minY else { continue }
            let label = "\(line)" as NSString
            let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: line == currentLine ? NSColor.labelColor : NSColor.secondaryLabelColor]
            let size = label.size(withAttributes: attributes)
            label.draw(at: NSPoint(x: bounds.width - size.width - Theme.sourceInset, y: y + (max(Theme.sourceLineHeight, fontSize * 1.55) - size.height) / 2), withAttributes: attributes)
            if let fold = fold(onHeaderLine: line, buffer: buffer) {
                let collapsed = foldedIDs.contains(fold.id)
                let symbol = collapsed ? "▶" : "▼"
                let hitRect = NSRect(x: 0, y: y, width: Theme.foldHitWidth,
                                     height: max(Theme.sourceLineHeight, fontSize * 1.55))
                foldHitRects[fold.id] = hitRect
                let markerFont = NSFont.systemFont(ofSize: Theme.foldMarkerSize, weight: .medium)
                let markerSize = (symbol as NSString).size(withAttributes: [.font: markerFont])
                (symbol as NSString).draw(at: NSPoint(x: (Theme.foldHitWidth - markerSize.width) / 2,
                                                       y: y + (max(Theme.sourceLineHeight, fontSize * 1.55) - markerSize.height) / 2), withAttributes: [
                    .font: markerFont,
                    .foregroundColor: NSColor.tertiaryLabelColor,
                ])
                if collapsed, fold.kind == "function" {
                    let hidden = Self.hiddenSourceLineCount(for: fold, in: buffer)
                    let width = Self.functionMeterWidth(hiddenLineCount: hidden)
                    let meter = NSRect(x: (Theme.foldHitWidth - width) / 2,
                                       y: hitRect.maxY - 4, width: width, height: 3)
                    NSColor.secondaryLabelColor.setFill()
                    NSBezierPath(roundedRect: meter, xRadius: 1.5, yRadius: 1.5).fill()

                    // Exact count in its own compact lane. Its capsule shape,
                    // smaller medium type, and neutral fill distinguish it
                    // from the canonical source line number to the right.
                    let count = Self.foldCountLabel(hiddenLineCount: hidden) as NSString
                    let countFont = NSFont.monospacedDigitSystemFont(ofSize: 9, weight: .medium)
                    let countAttributes: [NSAttributedString.Key: Any] = [
                        .font: countFont,
                        .foregroundColor: NSColor.secondaryLabelColor,
                    ]
                    let countSize = count.size(withAttributes: countAttributes)
                    let badgeWidth = max(20, min(32, countSize.width + 8))
                    let badgeHeight: CGFloat = 15
                    let badge = NSRect(x: Theme.foldHitWidth + 2,
                                       y: y + (hitRect.height - badgeHeight) / 2,
                                       width: badgeWidth, height: badgeHeight)
                    NSColor.quaternaryLabelColor.setFill()
                    NSBezierPath(roundedRect: badge, xRadius: badgeHeight / 2,
                                 yRadius: badgeHeight / 2).fill()
                    NSColor.separatorColor.setStroke()
                    let border = NSBezierPath(roundedRect: badge.insetBy(dx: 0.5, dy: 0.5),
                                              xRadius: badgeHeight / 2, yRadius: badgeHeight / 2)
                    border.lineWidth = 1
                    border.stroke()
                    count.draw(at: NSPoint(x: badge.midX - countSize.width / 2,
                                           y: badge.midY - countSize.height / 2),
                               withAttributes: countAttributes)
                    let noun = hidden == 1 ? "line" : "lines"
                    collapsedFunctionDescriptions.append("Collapsed function — \(hidden) \(noun) hidden")
                    let tag = addToolTip(hitRect.union(badge), owner: self, userData: nil)
                    foldTooltips.append(tag)
                    foldTooltipText[tag] = "Collapsed function — \(hidden) \(noun) hidden"
                }
            }
        }
        if collapsedFunctionDescriptions.isEmpty {
            setAccessibilityHelp("Click a disclosure control to collapse or expand a source region.")
        } else {
            setAccessibilityHelp((["Click a disclosure control to collapse or expand a source region."]
                                  + collapsedFunctionDescriptions).joined(separator: " "))
        }
        window?.invalidateCursorRects(for: self)
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if let id = foldHitRects.first(where: { $0.value.contains(point) })?.key,
           let fold = folds.first(where: { $0.id == id }) {
            onToggleFold?(fold)
        } else {
            super.mouseDown(with: event)
        }
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        for rect in foldHitRects.values { addCursorRect(rect, cursor: .pointingHand) }
    }

    func view(_ view: NSView, stringForToolTip tag: NSView.ToolTipTag,
              point: NSPoint, userData data: UnsafeMutableRawPointer?) -> String {
        foldTooltipText[tag] ?? "Toggle source fold"
    }

    private func fold(onHeaderLine line: Int, buffer: SourceBuffer) -> SourceFold? {
        folds.first { Self.headerLine(for: $0, in: buffer) == line }
    }

    static func headerLine(for fold: SourceFold, in buffer: SourceBuffer) -> Int {
        let start = buffer.line(atByte: fold.byteRange.lowerBound)
        return isDelimited(fold.byteRange, in: buffer) ? start : max(1, start - 1)
    }

    /// Counts canonical source rows removed by the fold. A visible delimiter
    /// remains on the header row; indentation bodies hide their captured rows.
    static func hiddenSourceLineCount(for fold: SourceFold, in buffer: SourceBuffer) -> Int {
        guard !fold.byteRange.isEmpty else { return 0 }
        let start = buffer.line(atByte: fold.byteRange.lowerBound)
        let lastByte = max(fold.byteRange.lowerBound, fold.byteRange.upperBound - 1)
        let end = buffer.line(atByte: lastByte)
        return isDelimited(fold.byteRange, in: buffer) ? max(0, end - start) : max(0, end - start + 1)
    }

    /// Logarithmic, capped scale: 0 lines = 6 pt, 256+ lines = 22 pt.
    static func functionMeterWidth(hiddenLineCount: Int) -> CGFloat {
        let bounded = min(256, max(0, hiddenLineCount))
        return 6 + 16 * log2(CGFloat(bounded) + 1) / log2(257)
    }

    /// Keep the badge compact for pathological generated functions while the
    /// tooltip and accessibility help retain the exact unabridged count.
    static func foldCountLabel(hiddenLineCount: Int) -> String {
        hiddenLineCount < 10_000 ? "\(max(0, hiddenLineCount))" : "9999+"
    }

    private static func isDelimited(_ range: Range<Int>, in buffer: SourceBuffer) -> Bool {
        let openers: Set<UInt8> = [0x7B, 0x5B, 0x28, 0x22, 0x27, 0x60]
        let closers: Set<UInt8> = [0x7D, 0x5D, 0x29, 0x22, 0x27, 0x60]
        guard range.lowerBound >= 0, range.upperBound <= buffer.data.count, range.count >= 2 else { return false }
        return openers.contains(buffer.data[range.lowerBound])
            && closers.contains(buffer.data[range.upperBound - 1])
    }

    static func shouldDrawLine(atUTF16 offset: Int, layout: NSLayoutManager, utf16Count: Int) -> Bool {
        guard offset >= 0, offset < utf16Count else { return true }
        let glyph = layout.glyphIndexForCharacter(at: offset)
        return !layout.notShownAttribute(forGlyphAt: glyph)
            && !layout.propertyForGlyph(at: glyph).contains(.null)
    }

    static func firstVisibleGlyph(in range: NSRange, layout: NSLayoutManager) -> Int? {
        guard range.length > 0 else { return nil }
        for glyph in range.location..<NSMaxRange(range) where glyph < layout.numberOfGlyphs {
            let property = layout.propertyForGlyph(at: glyph)
            if !property.contains(.null), !layout.notShownAttribute(forGlyphAt: glyph) { return glyph }
        }
        return nil
    }
}
