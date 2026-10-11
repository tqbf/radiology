import SwiftUI

/// The sidebar's Files mode: filter field and the
/// filtered tree (or the filter field's flat results).
struct RepositoryFilesView: View {
    @Environment(AppModel.self) private var model
    @State private var selection: String?
    let repository: RepositorySnapshot

    var body: some View {
        @Bindable var model = model
        TextField("Filter files", text: $model.fileQuery)
            .textFieldStyle(.roundedBorder)
            .onChange(of: model.fileQuery) { model.filterFiles() }
            .padding(.horizontal, Theme.inset)
        Group {
            if model.fileQuery.isEmpty, model.fileTree.isEmpty, !repository.files.isEmpty {
                ContentUnavailableView {
                    Label("No Files to Show", systemImage: "line.3.horizontal.decrease.circle")
                } description: {
                    Text("The current filters exclude every file in this repository.")
                } actions: {
                    Button("Show All Files", action: model.clearSourceFilters)
                }
            } else if !model.fileQuery.isEmpty, model.filteredFiles.isEmpty {
                ContentUnavailableView {
                    Label("No Matching Files", systemImage: "magnifyingglass")
                } description: {
                    Text(model.sourceFilters.isActive
                         ? "No files matching “\(model.fileQuery)” pass the current filters."
                         : "No files match “\(model.fileQuery)”.")
                } actions: {
                    if model.sourceFilters.isActive {
                        Button("Show All Files", action: model.clearSourceFilters)
                    }
                }
            } else {
                List(selection: $selection) {
                    if model.fileQuery.isEmpty {
                        ForEach(model.fileTree) { node in
                            FileTreeRow(node: node, expansion: model.fileTreeExpansion, root: repository.root)
                        }
                    } else {
                        ForEach(model.filteredFiles) { file in
                            FileTreeLabel(title: file.path, path: file.path, isDirectory: false, root: repository.root)
                        }
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .frame(maxHeight: .infinity)
        .onChange(of: selection) { openSelection() }
        .onChange(of: model.selectedPath, initial: true) { selection = model.selectedPath }
    }

    private func openSelection() {
        guard let path = selection, path != model.selectedPath,
              repository.files.contains(where: { $0.path == path }) else { return }
        model.openFile(path)
    }
}
