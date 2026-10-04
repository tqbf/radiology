import SwiftUI

/// One declaration in the outline. Indentation carries nesting; the symbol
/// gives the kind at a glance without introducing another type size or weight.
struct OutlineRow: View {
    let symbol: DocumentSymbol
    let select: () -> Void

    var body: some View {
        Button(symbol.name, systemImage: Self.icon(for: symbol.kind), action: select)
            .font(Theme.Fonts.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .buttonStyle(.plain)
            .help("Go to \(symbol.name)")
    }

    static func icon(for kind: String) -> String {
        switch kind {
        case "type", "struct": "square.stack.3d.up"
        case "protocol": "point.3.connected.trianglepath.dotted"
        case "enum": "list.bullet.rectangle"
        case "case": "circle.hexagongrid"
        case "typealias": "arrow.triangle.branch"
        case "module", "extension": "shippingbox"
        case "initializer", "deinitializer": "plusminus"
        case "property", "variable": "cube"
        case "constant": "lock"
        case "macro": "number"
        case "method": "function"
        default: "function"
        }
    }
}
