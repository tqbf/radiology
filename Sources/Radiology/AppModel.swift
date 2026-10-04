import SwiftUI
import Observation

@Observable @MainActor
final class AppModel {
    var repository: RepositorySnapshot?
    var source: SourceBuffer?
    var syntax: SyntaxSnapshot?
    var syntaxError: String?
    var isParsingSource = false
    var selectedPath: String?
    var isOpening = false
    var isLoadingSource = false
    var repositoryError: String?
    var sourceError: String?
    var searchError: String?
    var fileQuery = ""
    var filteredFiles: [RepositoryFile] = []
    var searchOptions = SearchOptions()
    var matches: [SearchMatch] = []
    var isSearching = false
    var searchLimited = false
    var mode: BrowserMode = .files
    var sheet: ReaderSheet?
    var lineInput = 1
    var currentLine = 1
    var sourceFontSize = Theme.sourceFontSize
    var navigationTarget: SourceLocation?
    var navigationRevision = 0
    var navigationSelectsText = true
    var foldToDefinitionsRevision = 0
    var collapseFunctionsRevision = 0
    var jumpHighlightRevision = 0
    var jumpHighlightTarget: SourceLocation?
    var focusRevision = 0
    var sourceFocusRevision = 0
    var syntacticOccurrenceSelection: SyntacticOccurrenceSelection?
    var occurrencePins = OccurrencePinStore()
    var sourceContentIdentity: SourceContentIdentity?
    var history = NavigationHistory()
    var recentRepositories: [String]
    var inspectorMode: InspectorMode = .outline
    let semantics: SemanticModel
    @ObservationIgnored private let preferences: UserDefaults
    @ObservationIgnored private let repositories = RepositoryWorker()
    @ObservationIgnored private let sources = SourceStore()
    @ObservationIgnored private let search = SearchWorker()
    @ObservationIgnored private let syntaxWorker = SyntaxWorker()
    @ObservationIgnored private var repositoryTask: Task<Void, Never>?
    @ObservationIgnored private var sourceTask: Task<Void, Never>?
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    @ObservationIgnored private var syntaxTask: Task<Void, Never>?
    @ObservationIgnored private var repositoryGeneration = UUID()
    @ObservationIgnored private var sourceGeneration = UUID()
    @ObservationIgnored private var searchGeneration = UUID()
    @ObservationIgnored var positions: [String: SourceLocation] = [:]
    @ObservationIgnored var currentHistoryEntryTracksPassivePosition = false
    @ObservationIgnored var semanticNavigationGeneration = UUID()

    init(preferences: UserDefaults = .standard, semantics: SemanticModel = SemanticModel()) {
        self.preferences = preferences
        self.semantics = semantics
        recentRepositories = preferences.stringArray(forKey: "recentRepositories") ?? []
    }

    func chooseRepository() {
        let panel = NSOpenPanel()
        panel.title = "Open Repository"
        panel.prompt = "Open"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            self?.openRepository(url)
        }
    }

    func openRepository(_ url: URL) {
        repositoryTask?.cancel()
        sourceTask?.cancel()
        syntaxTask?.cancel()
        cancelSearch()
        repositoryGeneration = UUID()
        let generation = repositoryGeneration
        isOpening = true
        isLoadingSource = false
        repositoryError = nil
        sourceError = nil
        searchError = nil
        source = nil
        syntax = nil
        syntacticOccurrenceSelection = nil
        occurrencePins = OccurrencePinStore()
        sourceContentIdentity = nil
        syntaxError = nil
        isParsingSource = false
        repository = nil
        selectedPath = nil
        history = NavigationHistory()
        positions = [:]
        matches = []
        filteredFiles = []
        navigationTarget = nil
        mode = .files
        fileQuery = ""
        sourceGeneration = UUID()
        semanticNavigationGeneration = UUID()
        semantics.repositoryClosed()
        repositoryTask = Task {
            do {
                let snapshot = try await repositories.open(url)
                guard generation == repositoryGeneration, !Task.isCancelled else { return }
                repository = snapshot
                filterFiles()
                semantics.repositoryOpened(snapshot)
                recentRepositories.removeAll { $0 == snapshot.root.path }
                recentRepositories.insert(snapshot.root.path, at: 0)
                recentRepositories = Array(recentRepositories.prefix(8))
                preferences.set(recentRepositories, forKey: "recentRepositories")
            } catch {
                guard generation == repositoryGeneration, !Task.isCancelled else { return }
                repositoryError = error.localizedDescription
            }
            if generation == repositoryGeneration { isOpening = false }
        }
    }

    /// Opens a repository and selects one file once its listing is ready.
    /// Backs the `--repository` / `--file` development launch arguments.
    func openRepository(_ url: URL, selecting path: String?) async {
        openRepository(url)
        let task = repositoryTask
        let generation = repositoryGeneration
        await task?.value
        guard let path, generation == repositoryGeneration, repository != nil else { return }
        openFile(path)
    }

    func openFile(_ path: String) {
        navigate(to: positions[path] ?? SourceLocation(path: path, byteOffset: 0), tracksPassivePosition: true)
    }

    func navigate(to location: SourceLocation, recordHistory: Bool = true, tracksPassivePosition: Bool = false) {
        guard let repository else { return }
        if recordHistory {
            if currentHistoryEntryTracksPassivePosition,
               let path = source?.path, let current = positions[path] { history.updateCurrent(current) }
            history.visit(location)
            currentHistoryEntryTracksPassivePosition = tracksPassivePosition
        }
        navigationSelectsText = true
        selectedPath = location.path
        navigationTarget = location
        navigationRevision += 1
        if source?.path == location.path {
            currentLine = source?.line(atByte: location.byteOffset) ?? 1
            return
        }
        sourceTask?.cancel()
        syntaxTask?.cancel()
        sourceGeneration = UUID()
        let generation = sourceGeneration
        source = nil
        syntax = nil
        syntacticOccurrenceSelection = nil
        sourceContentIdentity = nil
        syntaxError = nil
        isParsingSource = false
        sourceError = nil
        isLoadingSource = true
        semantics.bufferChanged(nil)
        sourceTask = Task {
            do {
                let buffer = try await sources.load(root: repository.root, path: location.path)
                guard generation == sourceGeneration, !Task.isCancelled else { return }
                source = buffer
                let identity = SourceContentIdentity(buffer.data)
                sourceContentIdentity = identity
                var pins = occurrencePins
                pins.reconcile(path: buffer.path, sourceIdentity: identity)
                occurrencePins = pins
                currentLine = buffer.line(atByte: location.byteOffset)
                semantics.bufferChanged(buffer)
                semantics.caretMoved(to: location.byteOffset)
                beginParsing(buffer, generation: generation)
            } catch {
                guard generation == sourceGeneration, !Task.isCancelled else { return }
                sourceError = error.localizedDescription
            }
            if generation == sourceGeneration { isLoadingSource = false }
        }
    }

    private func beginParsing(_ buffer: SourceBuffer, generation: UUID) {
        guard SourceLanguageRegistry.language(for: buffer.path) != nil else { return }
        isParsingSource = true
        syntaxTask = Task {
            do {
                let result = try await syntaxWorker.parse(buffer)
                guard generation == sourceGeneration, source?.path == buffer.path, !Task.isCancelled else { return }
                syntax = result
            } catch is CancellationError {
                return
            } catch {
                guard generation == sourceGeneration, source?.path == buffer.path, !Task.isCancelled else { return }
                syntaxError = error.localizedDescription
            }
            if generation == sourceGeneration { isParsingSource = false }
        }
    }

    func updatePosition(path: String, byteOffset: Int, line: Int) {
        guard source?.path == path else { return }
        let location = SourceLocation(path: path, byteOffset: byteOffset)
        positions[path] = location
        currentLine = line
    }

    func preview(_ symbol: DocumentSymbol) {
        guard let path = source?.path else { return }
        let location = SourceLocation(path: path, byteOffset: symbol.selectionByteRange.lowerBound)
        guard navigationTarget != location else { return }
        navigationSelectsText = false
        navigationTarget = location
        navigationRevision += 1
    }

    func commit(_ symbol: DocumentSymbol, highlight: Bool = false) {
        guard let path = source?.path else { return }
        let location = SourceLocation(path: path, byteOffset: symbol.selectionByteRange.lowerBound)
        navigate(to: location)
        if highlight {
            jumpHighlightTarget = location
            jumpHighlightRevision += 1
        }
    }

    func foldToDefinitions() { foldToDefinitionsRevision += 1 }
    func collapseFunctions() { collapseFunctionsRevision += 1 }

    var canCollapseFunctions: Bool {
        syntax?.folds.contains { $0.kind == "function" } == true
    }

    var enclosingSymbols: [DocumentSymbol] {
        guard let source, let symbols = syntax?.symbols else { return [] }
        let byte = positions[source.path]?.byteOffset ?? navigationTarget?.byteOffset ?? 0
        return symbols.filter { $0.byteRange.contains(byte) }
            .sorted { $0.byteRange.count > $1.byteRange.count }
    }

    var activeSymbol: DocumentSymbol? { enclosingSymbols.last }

    func goBack() {
        if let location = history.back() {
            currentHistoryEntryTracksPassivePosition = false
            navigate(to: location, recordHistory: false)
        }
    }
    func goForward() {
        if let location = history.forward() {
            currentHistoryEntryTracksPassivePosition = false
            navigate(to: location, recordHistory: false)
        }
    }
    func showFiles() { sheet = .files }
    func focusSource() { sourceFocusRevision += 1 }

    func selectOccurrences(at byte: Int?) {
        semantics.selectOccurrences(at: byte)
        guard let byte, let source, let syntax else {
            syntacticOccurrenceSelection = nil
            return
        }
        let syntactic = syntax.localIdentifierSelection(at: byte, in: source)
        // Prefer SCIP when it represents the complete local spelling set. If
        // cfg-gated or shadowed tokens are absent, use the explicitly
        // non-semantic function-local decoration the user requested.
        if let semantic = semantics.occurrenceSelection,
           syntactic?.byteRanges.allSatisfy(semantic.byteRanges.contains) == true {
            syntacticOccurrenceSelection = nil
        } else {
            syntacticOccurrenceSelection = syntactic
        }
    }

    func togglePinnedOccurrences(at byte: Int?) {
        guard let byte, let source, let sourceContentIdentity,
              let group = resolvedOccurrenceGroup(at: byte, source: source) else { return }
        var pins = occurrencePins
        pins.toggle(group, path: source.path, sourceIdentity: sourceContentIdentity, clickedByte: byte)
        occurrencePins = pins
        // The first click in AppKit's double-click sequence may have selected
        // this transiently. A pin owns its own appearance; an unpin must leave
        // no transient wash behind.
        semantics.selectOccurrences(at: nil)
        syntacticOccurrenceSelection = nil
    }

    var pinnedOccurrenceGroups: [PinnedOccurrenceGroup] {
        guard let source, let sourceContentIdentity else { return [] }
        return occurrencePins.groups(path: source.path, sourceIdentity: sourceContentIdentity)
    }

    private func resolvedOccurrenceGroup(at byte: Int, source: SourceBuffer) -> OccurrenceGroup? {
        semantics.selectOccurrences(at: byte)
        let semantic = semantics.occurrenceSelection
        let syntactic = syntax?.localIdentifierSelection(at: byte, in: source)
        if let semantic, syntactic?.byteRanges.allSatisfy(semantic.byteRanges.contains) == true {
            return OccurrenceGroup(identity: .semantic(semantic.symbol), activeByteRange: semantic.activeByteRange,
                                   byteRanges: semantic.byteRanges)
        }
        if let syntactic {
            return OccurrenceGroup(identity: .syntactic(scope: syntactic.scopeByteRange, spelling: syntactic.spelling),
                                   activeByteRange: syntactic.activeByteRange, byteRanges: syntactic.byteRanges)
        }
        if let semantic {
            return OccurrenceGroup(identity: .semantic(semantic.symbol), activeByteRange: semantic.activeByteRange,
                                   byteRanges: semantic.byteRanges)
        }
        return nil
    }
    func showSearch() { mode = .search; focusRevision += 1 }
    func showGoToLine() { lineInput = currentLine; sheet = .line }
    func goToLine() {
        guard let source else { return }
        navigate(to: SourceLocation(path: source.path, byteOffset: source.byteOffset(line: lineInput)))
        sheet = nil
    }
    func refresh() {
        guard let root = repository?.root else { return }
        let location = source.map { positions[$0.path] ?? SourceLocation(path: $0.path, byteOffset: 0) }
        openRepository(root)
        let task = repositoryTask
        let generation = repositoryGeneration
        Task {
            await task?.value
            if generation == repositoryGeneration, repository?.root == root, let location { navigate(to: location) }
        }
    }
    func filterFiles() {
        let all = repository?.files ?? []
        filteredFiles = fileQuery.isEmpty ? all : all.filter { $0.path.localizedStandardContains(fileQuery) }
    }
    func performSearch() {
        cancelSearch()
        matches = []
        searchError = nil
        searchLimited = false
        guard let root = repository?.root, !searchOptions.query.isEmpty else { return }
        searchGeneration = UUID()
        let generation = searchGeneration
        let options = searchOptions
        isSearching = true
        searchTask = Task { [self] in
            do {
                try await Task.sleep(for: .milliseconds(200))
                let limited = try await search.search(root: root, options: options) { [weak self] batch in
                    await self?.appendMatches(batch, generation: generation)
                }
                guard generation == searchGeneration, !Task.isCancelled else { return }
                searchLimited = limited
            } catch {
                guard generation == searchGeneration, !Task.isCancelled else { return }
                searchError = error.localizedDescription
            }
            if generation == searchGeneration { isSearching = false }
        }
    }
    private func appendMatches(_ batch: [SearchMatch], generation: UUID) {
        if generation == searchGeneration { matches.append(contentsOf: batch) }
    }
    func cancelSearch() {
        searchTask?.cancel()
        searchGeneration = UUID()
        isSearching = false
    }
    func increaseFontSize() { sourceFontSize = min(sourceFontSize + 1, 28) }
    func decreaseFontSize() { sourceFontSize = max(sourceFontSize - 1, 11) }
}
