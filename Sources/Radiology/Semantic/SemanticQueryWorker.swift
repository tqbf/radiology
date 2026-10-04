import Foundation

/// One reference occurrence, already converted to bytes against the file as
/// it is on disk now, with the line it sits on for display.
struct ReferenceHit: Sendable, Equatable, Identifiable {
    let location: SourceLocation
    let byteRange: Range<Int>
    let line: Int
    let column: Int
    let lineText: String
    let isDefinition: Bool
    var id: String { "\(location.path):\(byteRange.lowerBound)" }
}

struct ReferenceGroup: Sendable, Equatable, Identifiable {
    let path: String
    let hits: [ReferenceHit]
    var id: String { path }
}

struct ReferenceResults: Sendable, Equatable {
    let symbol: SemanticSymbolID
    let displayName: String
    let kind: SemanticSymbolKind
    let groups: [ReferenceGroup]
    /// Occurrences whose coordinates no longer fit the current file contents.
    let unmappedCount: Int
    /// Files the index names that could not be read.
    let unreadablePaths: [String]
    var total: Int { groups.reduce(0) { $0 + $1.hits.count } }
}

/// Queries that touch the disk or scan the whole index run here, off MainActor.
actor SemanticQueryWorker {
    private let sources = SourceStore()

    func documentSemantics(index: SemanticIndex, buffer: SourceBuffer) -> DocumentSemantics? {
        guard let document = index.documents[buffer.path] else { return nil }
        return DocumentSemantics.make(document: document, buffer: buffer)
    }

    /// Resolves a definition's coordinates against the destination file.
    func resolve(_ position: SemanticPosition, root: URL) async throws -> SourceLocation {
        let buffer = try await sources.load(root: root, path: position.path)
        guard let byte = buffer.byteOffset(zeroBasedLine: position.range.startLine, column: position.range.startCharacter, encoding: position.encoding) else {
            throw BrowserError.message("The index points at line \(position.range.startLine + 1) of \(position.path), which no longer matches the file. Reindex to refresh semantic data.")
        }
        return SourceLocation(path: position.path, byteOffset: byte)
    }

    /// Definitions and references of a symbol, grouped by file in path order.
    func references(of id: SemanticSymbolID, in index: SemanticIndex, root: URL) async throws -> ReferenceResults {
        var positions: [String: [(SemanticPosition, Bool)]] = [:]
        for position in index.definitions(of: id) { positions[position.path, default: []].append((position, true)) }
        for position in index.references[id] ?? [] { positions[position.path, default: []].append((position, false)) }
        var groups: [ReferenceGroup] = []
        var unmapped = 0
        var unreadable: [String] = []
        for path in positions.keys.sorted(by: { $0.localizedStandardCompare($1) == .orderedAscending }) {
            try Task.checkCancellation()
            guard let buffer = try? await sources.load(root: root, path: path) else {
                unreadable.append(path)
                continue
            }
            var hits: [ReferenceHit] = []
            for (position, isDefinition) in positions[path] ?? [] {
                guard let range = buffer.byteRange(for: position.range, encoding: position.encoding) else { unmapped += 1; continue }
                let line = buffer.line(atByte: range.lowerBound)
                hits.append(ReferenceHit(location: SourceLocation(path: path, byteOffset: range.lowerBound), byteRange: range,
                                         line: line, column: range.lowerBound - buffer.lineStarts[line - 1] + 1,
                                         lineText: buffer.lineText(line), isDefinition: isDefinition))
            }
            hits.sort { $0.byteRange.lowerBound < $1.byteRange.lowerBound }
            if !hits.isEmpty { groups.append(ReferenceGroup(path: path, hits: hits)) }
        }
        return ReferenceResults(symbol: id, displayName: index.displayName(id), kind: index.symbols[id]?.kind ?? SemanticSymbolKind(rawValue: 0),
                                groups: groups, unmappedCount: unmapped, unreadablePaths: unreadable)
    }

    func search(_ query: String, in index: SemanticIndex) -> [SymbolSearch.Match] {
        SymbolSearch.rank(query, in: index.searchEntries)
    }
}
