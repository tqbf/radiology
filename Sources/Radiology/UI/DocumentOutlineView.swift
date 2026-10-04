import SwiftUI

struct DocumentOutlineView: View {
    @Environment(AppModel.self) private var model
    @State private var selectedID: String?

    var body: some View {
        Group {
            if let syntax = model.syntax, !syntax.symbols.isEmpty {
                List(selection: $selectedID) {
                    OutlineGroup(OutlineNode.forest(from: syntax.symbols), children: \.optionalChildren) { node in
                        OutlineRow(symbol: node.symbol) { activate(node.symbol) }
                            .tag(node.id)
                            .accessibilityValue(node.symbol.id == model.activeSymbol?.id ? "Current declaration" : "")
                    }
                }
                .onChange(of: selectedID) { _, id in preview(id, symbols: syntax.symbols) }
                .onChange(of: model.activeSymbol?.id) { _, id in selectedID = id }
                .onAppear { selectedID = model.activeSymbol?.id }
                .onKeyPress(.return) {
                    guard let symbol = syntax.symbols.first(where: { $0.id == selectedID }) else { return .ignored }
                    model.commit(symbol)
                    return .handled
                }
            } else if model.isParsingSource {
                ProgressView("Reading structure…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView("No Outline", systemImage: "list.bullet.indent",
                                       description: Text(emptyDescription))
            }
        }
        .navigationTitle("Outline")
    }

    private var emptyDescription: String {
        if let syntaxError = model.syntaxError { return syntaxError }
        guard let path = model.source?.path else { return "Open a source file to see its declarations." }
        guard let language = SourceLanguageRegistry.language(for: path) else {
            return "Radiology parses "
                + SourceLanguageRegistry.all.map(\.displayName).formatted(.list(type: .and))
                + ". Other files are shown as plain text."
        }
        return "No declarations were found in this \(language.displayName) file."
    }

    private func preview(_ id: String?, symbols: [DocumentSymbol]) {
        guard let id, let symbol = symbols.first(where: { $0.id == id }), id != model.activeSymbol?.id else { return }
        model.preview(symbol)
    }

    private func activate(_ symbol: DocumentSymbol) {
        selectedID = symbol.id
        model.commit(symbol, highlight: true)
    }
}
