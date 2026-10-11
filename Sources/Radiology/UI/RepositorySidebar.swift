import SwiftUI

struct RepositorySidebar: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            if let repository = model.repository {
                SidebarModeTabs(modes: BrowserMode.available(reviewing: model.isReviewing), selection: $model.mode)
                switch model.mode {
                case .changes:
                    ReviewChangesView()
                case .files:
                    RepositoryFilesView(repository: repository)
                case .search: RepositorySearchView()
                }
                Divider()
                HStack {
                    Text(footer(repository)).font(Theme.Fonts.meta).foregroundStyle(.secondary).lineLimit(2)
                        .help(footer(repository))
                    Spacer()
                    Image(systemName: repository.isGit ? "point.3.connected.trianglepath.dotted" : "folder")
                        .help(model.review.map { "Pull request head: \($0.headSHA)" }
                              ?? (repository.isGit ? "Git ignore rules applied" : "Folder browsing"))
                        .accessibilityLabel(model.review.map { "Pull request head \($0.headSHA.prefix(10))" }
                                            ?? (repository.isGit ? "Git repository" : "Folder"))
                }.padding(Theme.inset)
            } else {
                ContentUnavailableView("Repository", systemImage: "folder", description: Text("Open a folder to explore its files."))
            }
        }
        .onChange(of: model.isReviewing) { if !model.isReviewing, model.mode == .changes { model.mode = .files } }
    }

    /// Visible count, named filter state, and any hidden-open-file notice.
    private func footer(_ repository: RepositorySnapshot) -> String {
        let filters = [model.sourceFilters.sourceFilesOnly ? "Source only" : nil,
                       model.sourceFilters.hidesTests ? "Tests hidden" : nil].compactMap { $0 }
        if model.mode == .changes, let review = model.review {
            let visible = ReviewChangesPresentation(changes: review.changes, filters: model.sourceFilters)
            var text = ([visible.fileCountLabel] + filters).joined(separator: " · ")
            if let source = model.source, visible.selectionID(path: source.path, revision: source.revision) == nil {
                text += " · open file not in visible changes"
            }
            return text
        }
        var text = model.sourceFilters.isActive
            ? "\(model.visibleFileCount) of \(repository.files.count) files"
            : "\(repository.files.count) files"
        if !filters.isEmpty { text += " · \(filters.joined(separator: " · "))" }
        if model.mode == .files, model.isOpenFileFilteredOut { text += " · open file hidden by filters" }
        return text
    }
}
