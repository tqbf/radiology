import SwiftUI

/// Native UI uses semantic SF styles; the source surface uses adjustable SF Mono.
enum Theme {
    static let windowMinWidth: CGFloat = 760
    static let windowMinHeight: CGFloat = 480
    static let windowDefaultWidth: CGFloat = 1180
    static let windowDefaultHeight: CGFloat = 780
    static let sidebarMinWidth: CGFloat = 220
    static let sidebarIdealWidth: CGFloat = 280
    static let sidebarMaxWidth: CGFloat = 440
    static let inset: CGFloat = 12
    static let spacing: CGFloat = 8
    static let sourceFontSize: CGFloat = 14
    static let sourceLineHeight: CGFloat = 22
    static let sourceInset: CGFloat = 12
    /// Fold control, collapsed-size badge, and source line number each have a
    /// distinct lane. The extra width prevents large fold counts from reading
    /// as (or colliding with) canonical source line numbers.
    static let gutterWidth: CGFloat = 104
    static let foldMarkerSize: CGFloat = 11
    static let foldHitWidth: CGFloat = 28
    static let inspectorMinWidth: CGFloat = 220
    static let inspectorIdealWidth: CGFloat = 280
    static let inspectorMaxWidth: CGFloat = 420
    static let outlineIndent: CGFloat = 12
    static let breadcrumbSpacing: CGFloat = 5
    static let breadcrumbHeight: CGFloat = 32
    static let destinationHighlightAlpha: CGFloat = 0.18
    enum Fonts {
        static let body = Font.body
        static let heading = Font.headline
        static let meta = Font.callout
        static let codePreview = Font.body.monospaced()
        /// Canonical symbol identifiers and command lines: long, secondary, monospaced.
        static let identifier = Font.caption.monospaced()
    }
    static let semanticUnderlineColor = NSColor.controlAccentColor
    static let semanticOccurrenceColor = NSColor.controlAccentColor.withAlphaComponent(0.16)
    static let activeSemanticOccurrenceColor = NSColor.controlAccentColor.withAlphaComponent(0.28)

    struct PinnedOccurrenceColors {
        let fill: NSColor
        let stroke: NSColor
    }

    /// Teal, amber, violet, and rose remain distinguishable from the ordinary
    /// blue accent wash. Locked groups also receive a heavier outline, so hue
    /// is never the only state cue. System colors adapt their actual RGB values
    /// while opacity is tuned separately for light and dark source surfaces.
    static func pinnedOccurrenceColors(slot: Int, appearance: NSAppearance) -> PinnedOccurrenceColors {
        let palette: [NSColor] = [.systemTeal, .systemOrange, .systemPurple, .systemPink]
        let base = palette[((slot % palette.count) + palette.count) % palette.count]
        let dark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        return PinnedOccurrenceColors(fill: base.withAlphaComponent(dark ? 0.22 : 0.15),
                                      stroke: base.withAlphaComponent(dark ? 0.88 : 0.72))
    }

    /// Maps Tree-sitter capture names to dynamic system colors, so both
    /// appearances come from Apple's own light and dark palettes rather than a
    /// hand-inverted one. Roles are keyed on the capture's first component,
    /// with a few whole-name exceptions that need to stand out from their
    /// surroundings.
    enum SyntaxColors {
        static func color(for capture: String) -> NSColor {
            switch capture {
            case "string.escape", "string.special": .systemOrange
            case "variable.builtin": .systemPink
            default: role(of: capture)
            }
        }

        private static func role(of capture: String) -> NSColor {
            switch capture.split(separator: ".").first {
            case "comment": .secondaryLabelColor
            case "string": .systemRed
            case "number", "constant": .systemOrange
            case "keyword": .systemPink
            case "type", "constructor", "namespace", "tag": .systemTeal
            case "function": .systemBlue
            case "property": .systemIndigo
            case "attribute": .systemPurple
            case "label": .systemBrown
            default: .textColor
            }
        }
    }
}
