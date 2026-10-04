import Foundation
import Observation

/// Main-actor state for semantic navigation: the published index, its status
/// and diagnostics, the current file's byte-mapped occurrences, the symbol
/// under the caret, reference results, and ⌘T matches. It never touches disk
/// or subprocesses itself.
@Observable @MainActor
final class SemanticModel {
    var status: SemanticIndexStatus = .noIndex(reason: "Open a repository to index it.")
    var outcomes: [StrategyOutcome] = []
    var skipped: [IndexingStrategy] = []
    var unsupportedLanguages: [String] = []
    var metadata: IndexMetadata?
    var cacheDirectory: URL?
    /// Changes whenever a different index object is published, so views drop
    /// hover and hit-test state derived from the old one.
    var indexRevision = 0
    /// Changes whenever the open file's occurrence map is replaced or cleared.
    var documentRevision = 0
    var documentSemantics: DocumentSemantics?
    var caretTarget: SemanticTarget?
    var occurrenceSelection: SemanticOccurrenceSelection?
    var references: ReferenceResults?
    var isFindingReferences = false
    var referencesError: String?
    var symbolQuery = ""
    var symbolMatches: [SymbolSearch.Match] = []
    var isSearchingSymbols = false
    var navigationError: String?
    @ObservationIgnored private(set) var index: SemanticIndex = .empty
    @ObservationIgnored private var repositoryRoot: URL?
    @ObservationIgnored private var buffer: SourceBuffer?
    @ObservationIgnored private var caretByte = 0
    @ObservationIgnored private var documentTask: Task<Void, Never>?
    @ObservationIgnored private var referencesTask: Task<Void, Never>?
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    @ObservationIgnored private var documentGeneration = UUID()
    @ObservationIgnored private var repositoryGeneration = UUID()
    @ObservationIgnored let service: SemanticIndexService
    @ObservationIgnored let queries = SemanticQueryWorker()

    init(service: SemanticIndexService = SemanticIndexService()) {
        self.service = service
    }

    var isRepositoryOpen: Bool { repositoryRoot != nil }
    var hasIndex: Bool { index.documentCount > 0 }

    // MARK: - Repository lifecycle

    func repositoryOpened(_ snapshot: RepositorySnapshot) {
        documentTask?.cancel()
        referencesTask?.cancel()
        searchTask?.cancel()
        repositoryGeneration = UUID()
        let generation = repositoryGeneration
        repositoryRoot = snapshot.root
        index = .empty
        indexRevision += 1
        status = .noIndex(reason: "Checking the repository…")
        outcomes = []
        skipped = []
        unsupportedLanguages = []
        metadata = nil
        cacheDirectory = nil
        documentSemantics = nil
        caretTarget = nil
        occurrenceSelection = nil
        references = nil
        referencesError = nil
        isFindingReferences = false
        symbolQuery = ""
        symbolMatches = []
        isSearchingSymbols = false
        navigationError = nil
        let publish: SemanticIndexService.Publish = { [weak self] publication in
            await self?.receive(publication, generation: generation)
        }
        Task { [service] in await service.open(snapshot, publish: publish) }
    }

    func repositoryClosed() {
        repositoryGeneration = UUID()
        repositoryRoot = nil
        buffer = nil
        documentTask?.cancel()
        referencesTask?.cancel()
        searchTask?.cancel()
        index = .empty
        indexRevision += 1
        status = .noIndex(reason: "Open a repository to index it.")
        outcomes = []
        documentSemantics = nil
        caretTarget = nil
        occurrenceSelection = nil
        references = nil
        symbolMatches = []
        Task { [service] in await service.close() }
    }

    func repositoryReloaded(_ snapshot: RepositorySnapshot) {
        guard repositoryRoot == snapshot.root else { return repositoryOpened(snapshot) }
        let generation = repositoryGeneration
        let publish: SemanticIndexService.Publish = { [weak self] publication in
            await self?.receive(publication, generation: generation)
        }
        Task { [service] in await service.refresh(snapshot, publish: publish) }
    }

    func reindex() {
        guard isRepositoryOpen else { return }
        Task { [service] in await service.reindex() }
    }

    func cancelIndexing() {
        Task { [service] in await service.cancel() }
    }

    func installIndexer(_ indexerID: String) {
        Task { [service] in await service.install(indexerID: indexerID) }
    }

    private func receive(_ publication: SemanticPublication, generation: UUID) {
        guard generation == repositoryGeneration, publication.repositoryRoot == repositoryRoot else { return }
        let replaced = publication.index !== index
        index = publication.index
        status = publication.status
        outcomes = publication.outcomes
        skipped = publication.skipped
        unsupportedLanguages = publication.unsupportedLanguages
        metadata = publication.metadata
        cacheDirectory = publication.cacheDirectory
        if replaced {
            indexRevision += 1
            caretTarget = nil
            occurrenceSelection = nil
            if let buffer { mapDocument(buffer) }
            if let references { findReferences(of: references.symbol) }
        }
    }

    // MARK: - Current file

    func bufferChanged(_ buffer: SourceBuffer?) {
        self.buffer = buffer
        documentSemantics = nil
        documentRevision += 1
        caretTarget = nil
        occurrenceSelection = nil
        documentTask?.cancel()
        guard let buffer else { return }
        mapDocument(buffer)
    }

    private func mapDocument(_ buffer: SourceBuffer) {
        documentTask?.cancel()
        documentGeneration = UUID()
        let generation = documentGeneration
        let index = index
        guard index.documents[buffer.path] != nil else {
            documentSemantics = nil
            caretTarget = nil
            return
        }
        documentTask = Task { [queries] in
            let semantics = await queries.documentSemantics(index: index, buffer: buffer)
            guard generation == documentGeneration, self.buffer?.path == buffer.path, !Task.isCancelled else { return }
            documentSemantics = semantics
            documentRevision += 1
            caretTarget = target(at: caretByte)
        }
    }

    func caretMoved(to byte: Int) {
        caretByte = byte
        caretTarget = target(at: byte)
    }

    /// Synchronous lookup for hover, click, and menus; nil when the file has no
    /// occurrence there or no index covers it.
    func target(at byte: Int) -> SemanticTarget? {
        guard let documentSemantics, documentSemantics.path == buffer?.path else { return nil }
        return index.target(in: documentSemantics, at: byte)
    }

    /// Ordinary source clicks select every occurrence of exactly one SCIP
    /// symbol in this document. A miss clears the persistent decoration.
    func selectOccurrences(at byte: Int?) {
        guard let byte, let documentSemantics, documentSemantics.path == buffer?.path else {
            occurrenceSelection = nil
            return
        }
        occurrenceSelection = index.occurrenceSelection(in: documentSemantics, at: byte)
    }

    // MARK: - References

    func findReferences(of symbol: SemanticSymbolID) {
        guard let root = repositoryRoot else { return }
        referencesTask?.cancel()
        isFindingReferences = true
        referencesError = nil
        let index = index
        referencesTask = Task { [queries] in
            do {
                let results = try await queries.references(of: symbol, in: index, root: root)
                guard !Task.isCancelled, self.index === index else { return }
                references = results
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                referencesError = error.localizedDescription
            }
            isFindingReferences = false
        }
    }

    func clearReferences() {
        referencesTask?.cancel()
        references = nil
        referencesError = nil
        isFindingReferences = false
    }

    // MARK: - Symbol search

    func searchSymbols(_ query: String) {
        symbolQuery = query
        searchTask?.cancel()
        let index = index
        isSearchingSymbols = true
        searchTask = Task { [queries] in
            if !query.isEmpty { try? await Task.sleep(for: .milliseconds(60)) }
            guard !Task.isCancelled else { return }
            let matches = await queries.search(query, in: index)
            guard !Task.isCancelled, self.index === index, self.symbolQuery == query else { return }
            symbolMatches = matches
            isSearchingSymbols = false
        }
    }
}
