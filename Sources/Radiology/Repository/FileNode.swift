import Foundation

struct FileNode: Identifiable, Sendable {
    let path: String
    let name: String
    var children: [FileNode]?
    var id: String { path }
    var isDirectory: Bool { children != nil }

    static func tree(files: [RepositoryFile], prefix: String = "") -> [FileNode] {
        let groups = Dictionary(grouping: files) { file in
            String(file.path.dropFirst(prefix.count).split(separator: "/", maxSplits: 1).first ?? "")
        }
        return groups.compactMap { name, files in
            guard !name.isEmpty else { return nil }
            let path = prefix + name
            let directory = files.contains { $0.path != path }
            return FileNode(path: path, name: name, children: directory ? tree(files: files, prefix: path + "/") : nil)
        }.sorted {
            if $0.isDirectory != $1.isDirectory { return $0.isDirectory }
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
}
