import AppKit

/// TextKit navigation needs the final clip-view geometry, after SwiftUI lays out
/// the representable.
final class SourceScrollView: NSScrollView {
    var pendingLocation: Int?
    override func layout() {
        super.layout()
        guard let offset = pendingLocation, let text = documentView as? NSTextView,
              let layout = text.layoutManager else { return }
        pendingLocation = nil
        // Lay out and size the document before scrolling. Otherwise a newly
        // opened file is clamped to its partially laid-out height and the jump
        // lands with the destination at the bottom of the viewport.
        if let container = text.textContainer {
            layout.ensureLayout(for: container)
            let used = layout.usedRect(for: container)
            text.setFrameSize(NSSize(width: max(contentSize.width, used.maxX + text.textContainerInset.width * 2),
                                     height: max(contentSize.height, used.maxY + text.textContainerInset.height * 2)))
        }
        let count = (text.string as NSString).length
        var y: CGFloat = 0
        if offset < count {
            let glyph = layout.glyphIndexForCharacter(at: offset)
            y = layout.lineFragmentRect(forGlyphAt: glyph, effectiveRange: nil).minY
        } else if count > 0 {
            y = layout.extraLineFragmentRect.minY
        }
        contentView.scroll(to: NSPoint(x: 0, y: y))
        reflectScrolledClipView(contentView)
    }
}
