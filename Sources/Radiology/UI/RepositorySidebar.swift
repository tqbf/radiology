import SwiftUI

struct RepositorySidebar: View {
    @Environment(AppModel.self) private var model
    @State private var selection: String?
    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            if let repository = model.repository {
                Picker("Browse", selection: $model.mode) {
                    ForEach(BrowserMode.allCases) { mode in Text(mode.rawValue).tag(mode) }
                }.pickerStyle(.segmented).padding(Theme.inset)
                switch model.mode {
                case .files:
                    TextField("Filter files", text: $model.fileQuery)
                        .textFieldStyle(.roundedBorder).padding(.horizontal, Theme.inset)
                        .onChange(of: model.fileQuery) { model.filterFiles() }
                    List(selection: $selection) {
                        if model.fileQuery.isEmpty {
                            OutlineGroup(repository.tree, children: \.children) { node in
                                Label(node.name, systemImage: node.isDirectory ? "folder" : "doc.text")
                                    .lineLimit(1).truncationMode(.tail)
                                    .tag(node.path)
                                    .contextMenu { Button("Reveal in Finder") { NSWorkspace.shared.activateFileViewerSelecting([repository.root.appending(path: node.path)]) } }
                            }
                        } else {
                            ForEach(model.filteredFiles) { file in
                                Label(file.path, systemImage: "doc.text").lineLimit(1).truncationMode(.tail).tag(file.path)
                            }
                        }
                    }
                    .listStyle(.sidebar)
                    .onChange(of: selection) {
                        guard let path = selection, path != model.selectedPath, repository.files.contains(where: { $0.path == path }) else { return }
                        model.openFile(path)
                    }
                case .search: RepositorySearchView()
                }
                Divider()
                HStack {
                    Text("\(repository.files.count) files").font(Theme.Fonts.meta).foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: repository.isGit ? "point.3.connected.trianglepath.dotted" : "folder")
                        .help(repository.isGit ? "Git ignore rules applied" : "Folder browsing")
                }.padding(Theme.inset)
            } else {
                ContentUnavailableView("Repository", systemImage: "folder", description: Text("Open a folder to explore its files."))
            }
        }
        .onChange(of: model.selectedPath) { selection = model.selectedPath }
        .task { selection = model.selectedPath }
    }
}
