import Foundation

/// Semantic navigation entry points. Destinations are resolved against the
/// file on disk before the jump, so history only ever holds exact byte offsets.
extension AppModel {
    /// Cmd-click, the Navigate menu, or the context menu at a byte in the open file.
    func goToDefinition(at byte: Int) {
        guard let source, let root = repository?.root else { return }
        guard let target = semantics.target(at: byte) else {
            semantics.navigationError = "No symbol is under the cursor."
            return
        }
        guard let position = target.definitions.first else {
            semantics.navigationError = target.isOnDefinition
                ? "\(target.displayName) is defined here."
                : "\(target.displayName) is defined outside this repository."
            return
        }
        semantics.navigationError = nil
        let origin = SourceLocation(path: source.path, byteOffset: byte)
        let generation = semanticNavigationGeneration
        Task { [semantics] in
            do {
                let destination = try await semantics.queries.resolve(position, root: root)
                guard generation == semanticNavigationGeneration, repository?.root == root else { return }
                navigateSemantically(from: origin, to: destination)
            } catch {
                guard generation == semanticNavigationGeneration else { return }
                semantics.navigationError = error.localizedDescription
            }
        }
    }

    /// Jumps to a definition chosen from a list (inspector or ⌘T).
    func navigate(toDefinition position: SemanticPosition) {
        guard let root = repository?.root else { return }
        let origin = source.map { SourceLocation(path: $0.path, byteOffset: positions[$0.path]?.byteOffset ?? navigationTarget?.byteOffset ?? 0) }
        let generation = semanticNavigationGeneration
        Task { [semantics] in
            do {
                let destination = try await semantics.queries.resolve(position, root: root)
                guard generation == semanticNavigationGeneration, repository?.root == root else { return }
                if let origin { navigateSemantically(from: origin, to: destination) } else { navigate(to: destination) }
            } catch {
                guard generation == semanticNavigationGeneration else { return }
                semantics.navigationError = error.localizedDescription
            }
        }
    }

    /// Records the exact departure point, then the destination, so Back returns
    /// to the caret or click position rather than a stale scroll position. A
    /// pinned structural anchor stays in history; the departure is added after it.
    func navigateSemantically(from origin: SourceLocation, to destination: SourceLocation) {
        if currentHistoryEntryTracksPassivePosition {
            history.updateCurrent(origin)
            currentHistoryEntryTracksPassivePosition = false
        } else if history.current != origin {
            history.visit(origin)
        }
        navigate(to: destination)
        jumpHighlightTarget = destination
        jumpHighlightRevision += 1
    }

    func findReferences(at byte: Int) {
        guard let target = semantics.target(at: byte) else {
            semantics.navigationError = "No symbol is under the cursor."
            return
        }
        semantics.navigationError = nil
        inspectorMode = .semantics
        semantics.findReferences(of: target.symbol)
    }

    func findReferencesAtCaret() {
        guard let source else { return }
        findReferences(at: positions[source.path]?.byteOffset ?? navigationTarget?.byteOffset ?? 0)
    }

    func goToDefinitionAtCaret() {
        guard let source else { return }
        goToDefinition(at: positions[source.path]?.byteOffset ?? navigationTarget?.byteOffset ?? 0)
    }

    func showSymbolSearch() {
        semantics.searchSymbols("")
        sheet = .symbols
    }

    /// Where the reader is now: the tracked caret, else the last navigation target.
    var currentCaretLocation: SourceLocation? {
        guard let source else { return nil }
        return positions[source.path] ?? navigationTarget.flatMap { $0.path == source.path ? $0 : nil } ?? SourceLocation(path: source.path, byteOffset: 0)
    }

    func reindexRepository() { semantics.reindex() }
    func cancelIndexing() { semantics.cancelIndexing() }
}
