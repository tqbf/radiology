import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model
    @State private var isOutlinePresented = true
    var body: some View {
        @Bindable var model = model
        NavigationSplitView {
            RepositorySidebar()
                .navigationSplitViewColumnWidth(min: Theme.sidebarMinWidth, ideal: Theme.sidebarIdealWidth, max: Theme.sidebarMaxWidth)
        } detail: {
            ReaderDetail()
        }
        .navigationTitle(model.repository?.root.lastPathComponent ?? "Radiology")
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button("Back", systemImage: "chevron.left", action: model.goBack)
                    .disabled(!model.history.canGoBack).help("Back (⌘[)")
                Button("Forward", systemImage: "chevron.right", action: model.goForward)
                    .disabled(!model.history.canGoForward).help("Forward (⌘])")
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Toggle Outline", systemImage: "sidebar.right", action: toggleOutline)
                    .disabled(model.source == nil).help("Show or Hide Document Outline")
                Button("Go to File", systemImage: "doc.text.magnifyingglass", action: model.showFiles)
                    .disabled(model.repository == nil).help("Go to File (⌘K or ⌘P)")
                Button("Go to Symbol", systemImage: "function", action: model.showSymbolSearch)
                    .disabled(model.repository == nil).help("Go to Symbol (⌘T)")
                Button("Search Repository", systemImage: "magnifyingglass", action: model.showSearch)
                    .disabled(model.repository == nil).help("Search Repository (⇧⌘F)")
                Button("Open Repository", systemImage: "folder.badge.plus", action: model.chooseRepository)
                    .help("Open Repository (⌘O)")
            }
        }
        .inspector(isPresented: $isOutlinePresented) {
            InspectorView()
        }
        .sheet(item: $model.sheet) { sheet in
            switch sheet {
            case .files: QuickFilePicker()
            case .line: GoToLineSheet()
            case .symbols: SymbolSearchSheet()
            }
        }
        .dropDestination(for: URL.self) { urls, _ in
            guard let url = urls.first else { return false }
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else { return false }
            model.openRepository(isDirectory.boolValue ? url : url.deletingLastPathComponent())
            return true
        }
    }

    private func toggleOutline() { isOutlinePresented.toggle() }
}
