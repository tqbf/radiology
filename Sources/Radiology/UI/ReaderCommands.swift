import SwiftUI

struct ReaderCommands: Commands {
    let model: AppModel
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Open Repository…", action: model.chooseRepository).keyboardShortcut("o")
            Menu("Open Recent") {
                ForEach(model.recentRepositories, id: \.self) { path in
                    Button(path) { model.openRepository(URL(filePath: path)) }
                }
            }.disabled(model.recentRepositories.isEmpty)
        }
        CommandGroup(after: .textEditing) {
            Button("Find in File…") { performFind(.showFindInterface) }
                .keyboardShortcut("f").disabled(model.source == nil)
            Button("Find Next") { performFind(.nextMatch) }
                .keyboardShortcut("g").disabled(model.source == nil)
            Button("Find Previous") { performFind(.previousMatch) }
                .keyboardShortcut("g", modifiers: [.command, .shift]).disabled(model.source == nil)
        }
        CommandMenu("Navigate") {
            Button("Back", action: model.goBack).keyboardShortcut("[").disabled(!model.history.canGoBack)
            Button("Forward", action: model.goForward).keyboardShortcut("]").disabled(!model.history.canGoForward)
            Divider()
            Button("Go to File…", action: model.showFiles).keyboardShortcut("k").disabled(model.repository == nil)
            Button("Go to File (Command-P Alias)", action: model.showFiles).keyboardShortcut("p").disabled(model.repository == nil)
            Button("Go to Symbol…", action: model.showSymbolSearch).keyboardShortcut("t").disabled(model.repository == nil)
            Button("Go to Line…", action: model.showGoToLine).keyboardShortcut("l").disabled(model.source == nil)
            Button("Search Repository", action: model.showSearch).keyboardShortcut("f", modifiers: [.command, .shift]).disabled(model.repository == nil)
            Divider()
            Button("Go to Definition", action: model.goToDefinitionAtCaret)
                .keyboardShortcut("j", modifiers: [.command, .control])
                .disabled(model.semantics.caretTarget?.hasDefinition != true)
            Button("Find References", action: model.findReferencesAtCaret)
                .keyboardShortcut("r", modifiers: [.command, .control])
                .disabled(model.semantics.caretTarget == nil)
        }
        CommandMenu("Repository") {
            Button("Reindex", action: model.reindexRepository)
                .keyboardShortcut("i", modifiers: [.command, .control])
                .disabled(!model.semantics.isRepositoryOpen || model.semantics.status.isIndexing)
            Button("Cancel Indexing", action: model.cancelIndexing)
                .disabled(!model.semantics.status.isIndexing)
        }
        CommandGroup(after: .toolbar) {
            Button("Reload Repository", action: model.refresh).keyboardShortcut("r").disabled(model.repository == nil)
            Button("Fold to Definitions", action: model.foldToDefinitions)
                .keyboardShortcut("0", modifiers: [.command, .option])
                .disabled(model.syntax == nil)
            Button("Collapse Functions", action: model.collapseFunctions)
                .keyboardShortcut("0", modifiers: [.command, .shift])
                .disabled(!model.canCollapseFunctions)
            Divider()
            Button("Increase Source Text Size", action: model.increaseFontSize).keyboardShortcut("+")
            Button("Decrease Source Text Size", action: model.decreaseFontSize).keyboardShortcut("-")
        }
    }
    private func performFind(_ action: NSTextFinder.Action) {
        let item = NSMenuItem()
        item.tag = action.rawValue
        NSApp.sendAction(#selector(NSTextView.performFindPanelAction(_:)), to: nil, from: item)
    }
}
