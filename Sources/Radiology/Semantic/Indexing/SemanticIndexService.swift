import Foundation

/// Owns index generation for the open repository: inspection, cache loading,
/// freshness checks, running indexers out of process, and atomic publication.
/// All disk, subprocess, and decoding work happens here, never on MainActor.
actor SemanticIndexService {
    typealias Publish = @Sendable (SemanticPublication) async -> Void

    private let indexers: [any SemanticIndexer]
    private let defaultCache: IndexCache
    /// The cache for the current open: the default, or a revision's flat cache.
    private var cache: IndexCache
    private var options = IndexOpenOptions()
    private let provisioner: ToolProvisioner
    private let commands = CommandRunner()
    private var currentTask: Task<Void, Never>?
    private var generation = UUID()
    private var publish: Publish?

    /// The latest consistent state, kept so reindex can build on it.
    private var inspection: RepositoryInspection?
    private var selected: [IndexingStrategy] = []
    private var skipped: [IndexingStrategy] = []
    private var unsupported: [String] = []
    private var loaded: [String: SemanticIndex.Input] = [:]
    private var publishedIndex = SemanticIndex.empty
    private var publishedIndexIsDirty = false
    private var outcomes: [StrategyOutcome] = []
    private var metadata: IndexMetadata?

    init(indexers: [any SemanticIndexer] = SemanticIndexerRegistry.all, cache: IndexCache = .default, tools: ToolDirectory = .default) {
        self.indexers = indexers
        defaultCache = cache
        self.cache = cache
        provisioner = ToolProvisioner(tools: tools)
    }

    // MARK: - Lifecycle

    /// Starts work for a newly opened repository. Any previous run is cancelled
    /// first, and its late results can no longer be published. `options`
    /// selects a revision cache, reuse sources, and exact-snapshot provenance.
    func open(_ snapshot: RepositorySnapshot, options: IndexOpenOptions = IndexOpenOptions(), publish: @escaping Publish) {
        cancelCurrent()
        self.publish = publish
        let generation = UUID()
        self.generation = generation
        self.options = options
        cache = options.cache ?? defaultCache
        var inspected = RepositoryInspection(root: snapshot.root, paths: snapshot.files.map(\.path), isGit: snapshot.isGit)
        inspected.blobIDs = options.blobIDs
        inspection = inspected
        loaded = [:]
        publishedIndex = .empty
        publishedIndexIsDirty = false
        outcomes = []
        metadata = nil
        currentTask = Task { [weak self] in
            await self?.run(generation: generation, force: false)
        }
    }

    /// Regenerates every strategy regardless of freshness and re-probes tools.
    func reindex() {
        guard inspection != nil else { return }
        cancelCurrent()
        let generation = UUID()
        self.generation = generation
        currentTask = Task { [weak self] in
            await self?.run(generation: generation, force: true)
        }
    }

    /// Re-inspects after a repository reload: regenerate only when fingerprints moved.
    func refresh(_ snapshot: RepositorySnapshot, publish: @escaping Publish) {
        open(snapshot, options: options, publish: publish)
    }

    /// Stops the running generation. Cached or previous data stays published.
    func cancel() {
        guard currentTask != nil else { return }
        cancelCurrent()
        generation = UUID()
        let generation = generation
        for index in outcomes.indices where outcomes[index].result == .pending { outcomes[index].result = .cancelled }
        let status: SemanticIndexStatus = loaded.isEmpty ? .noIndex(reason: "Indexing was cancelled.") : .possiblyStale(reason: "Indexing was cancelled before the index could be refreshed.")
        currentTask = Task { [weak self] in
            await self?.emit(status: status, generation: generation)
        }
    }

    func close() {
        cancelCurrent()
        generation = UUID()
        publish = nil
        inspection = nil
        loaded = [:]
        publishedIndex = .empty
        publishedIndexIsDirty = false
        outcomes = []
    }

    /// Installs a missing indexer, then regenerates.
    func install(indexerID: String) {
        guard let indexer = indexers.first(where: { $0.id == indexerID }), inspection != nil else { return }
        cancelCurrent()
        let generation = UUID()
        self.generation = generation
        currentTask = Task { [weak self] in
            guard let self else { return }
            do {
                await self.emit(status: .indexing(IndexingProgress(phase: .installing, strategy: nil, step: 0, total: 1, message: "Installing \(indexer.displayName)…")), generation: generation)
                _ = try await self.provisioner.provision(indexer) { line in
                    Task { await self.emit(status: .indexing(IndexingProgress(phase: .installing, strategy: nil, step: 0, total: 1, message: line)), generation: generation) }
                }
                await self.run(generation: generation, force: true)
            } catch is CancellationError {
                return
            } catch {
                let failure = IndexingFailure(kind: .installationFailed, indexerID: indexer.id, indexerName: indexer.displayName, indexerVersion: nil,
                                              strategy: nil, commandLine: indexer.provisioning(in: self.provisioner.tools)?.steps.first?.commandLine,
                                              exitStatus: nil, signal: nil, stdout: "", stderr: "", message: error.localizedDescription)
                await self.emit(status: .failed(failure), generation: generation)
            }
        }
    }

    private func cancelCurrent() {
        currentTask?.cancel()
        currentTask = nil
    }

    /// Mutates one outcome only while this run is still the current generation
    /// and the array still describes this run's strategies.
    private func update(_ position: Int, generation: UUID, _ body: (inout StrategyOutcome) -> Void) {
        guard generation == self.generation, outcomes.indices.contains(position) else { return }
        body(&outcomes[position])
    }

    // MARK: - The run

    private func run(generation: UUID, force: Bool) async {
        guard let inspection else { return }
        let plan = SemanticIndexerRegistry.strategies(for: inspection, indexers: indexers)
        selected = plan.selected
        skipped = plan.skipped
        unsupported = Self.unsupportedLanguages(in: inspection, covered: selected)
        if selected.isEmpty {
            loaded = [:]
            publishedIndex = .empty
            publishedIndexIsDirty = false
            outcomes = []
            let languages = unsupported.isEmpty ? "" : " Files here are \(unsupported.formatted(.list(type: .and)))."
            await emit(status: .noIndex(reason: "No supported build files were found.\(languages)"), generation: generation)
            return
        }
        await emit(status: .indexing(IndexingProgress(phase: .inspecting, strategy: nil, step: 0, total: selected.count, message: "Checking the repository…")), generation: generation)

        // Fingerprint and cached metadata decide what can be reused.
        let head = await headCommit(inspection)
        guard generation == self.generation else { return }
        var buildInputPaths = inspection.paths
        var buildInputError: String?
        if let ids = inspection.blobIDs {
            buildInputPaths = Array(Set(buildInputPaths).union(ids.keys))
        } else if inspection.isGit, selected.contains(where: { strategy in
            indexers.contains { $0.id == strategy.indexerID && $0.requiresIsolatedWorkspace }
        }) {
            do {
                guard let git = ToolLocator.executable("git") else { throw BrowserError.message("Git is unavailable for compiler input discovery.") }
                let listed = try await commands.run(git, arguments: ["ls-files", "-z", "--cached", "--others", "--exclude-standard"], directory: inspection.root)
                let paths = listed.split(separator: 0).compactMap { String(data: Data($0), encoding: .utf8) }
                buildInputPaths = Array(Set(buildInputPaths).union(paths))
            } catch is CancellationError {
                return
            } catch {
                buildInputError = error.localizedDescription
            }
        }
        guard !Task.isCancelled, generation == self.generation else { return }
        let fingerprint = RepositoryFingerprint.compute(root: inspection.root, paths: buildInputPaths, headCommit: head)
        guard !Task.isCancelled, generation == self.generation else { return }
        let cached = cache.loadMetadata(for: inspection.root)
        // Exact snapshots compare per-strategy content digests; a working
        // tree compares the coarse repository fingerprint, as before.
        let snapshotDigests: [String: String]? = inspection.blobIDs.map { ids in
            Dictionary(uniqueKeysWithValues: selected.map { ($0.id, ContentDigest.digest(for: $0, blobIDs: ids)) })
        }
        let fingerprintStaleness: String? = cached.flatMap { fingerprint.stalenessReason(comparedTo: $0) }
        func isCurrent(_ strategy: IndexingStrategy) -> Bool {
            guard !force, let cached, let record = cached.strategies.first(where: { $0.strategy == strategy }) else { return false }
            if let snapshotDigests {
                return record.contentDigest != nil && record.contentDigest == snapshotDigests[strategy.id]
            }
            return fingerprintStaleness == nil
        }
        let staleness: String? = {
            guard let cached else { return nil }
            if snapshotDigests != nil {
                return selected.allSatisfy(isCurrent) ? nil : "Some projects' files differ from the bytes the cached index describes."
            }
            return fingerprintStaleness ?? (cached.strategies.isEmpty ? "The cached index is empty." : nil)
        }()
        let cacheIsCurrent = cached != nil && !force && selected.allSatisfy(isCurrent)
        metadata = cached
        if outcomes.isEmpty || force {
            outcomes = selected.map { StrategyOutcome(strategy: $0, result: .pending, indexerVersion: nil, commandLine: nil, documentCount: 0, duration: nil) }
        }

        // Load every cached strategy file first so navigation works immediately.
        if loaded.isEmpty, let cached {
            await emit(status: .indexing(IndexingProgress(phase: .loadingCache, strategy: nil, step: 0, total: selected.count, message: "Loading the cached index…")), generation: generation)
            for (position, strategy) in selected.enumerated() {
                guard let record = cached.strategies.first(where: { $0.strategy == strategy }) else { continue }
                let url = cache.indexURL(for: inspection.root, strategy: strategy)
                guard let data = try? Data(contentsOf: url), let raw = try? SCIPDecoder.decode(data) else { continue }
                let decoded = Self.snapshotDocuments(raw, strategy: strategy, inspection: inspection)
                guard !decoded.documents.isEmpty else { continue }
                guard !Task.isCancelled, generation == self.generation else { return }
                guard generation == self.generation else { return }
                loaded[strategy.id] = SemanticIndex.Input(index: decoded, projectDirectory: strategy.projectDirectory,
                                                         defaultEncoding: indexers.first { $0.id == strategy.indexerID }?.defaultEncoding)
                publishedIndexIsDirty = true
                update(position, generation: generation) {
                    $0.result = .cached(stale: !isCurrent(strategy))
                    $0.indexerVersion = record.indexerVersion
                    $0.commandLine = record.commandLine
                    $0.documentCount = decoded.documents.count
                    // Recompute against the current repository inventory so
                    // the list and reason classes never become stale even
                    // while the semantic coordinates themselves are cached.
                    $0.missingFiles = Self.missingFiles(for: strategy, inspection: inspection, index: decoded)
                    $0.capability = record.capability
                    $0.cargoError = record.cargoError
                    $0.diagnostics = record.diagnostics
                    $0.duration = .seconds(record.duration)
                }
            }
            let everythingCached = selected.allSatisfy { loaded[$0.id] != nil }
            if everythingCached, cacheIsCurrent {
                let status: SemanticIndexStatus = cachedCoverageStatus() // Persisted reuse provenance survives reload.
                await emit(status: status, generation: generation)
                return
            }
            if !loaded.isEmpty {
                await emit(status: .possiblyStale(reason: staleness ?? "Some parts of the repository have not been indexed yet."), generation: generation)
            }
        } else if cacheIsCurrent, selected.allSatisfy({ loaded[$0.id] != nil }) {
            let status = cachedCoverageStatus()
            await emit(status: status, generation: generation)
            return
        }

        // Generate what is missing or stale, one strategy at a time. Records
        // of strategies whose cached file is still exact are carried over.
        var records: [IndexMetadata.StrategyRecord] = (cached?.strategies ?? []).filter { isCurrent($0.strategy) && loaded[$0.strategy.id] != nil }
        var firstFailure: IndexingFailure?
        // Working-tree blob ids are hashed once, only when something is generated.
        var workingTreeBlobIDs: [String: String]?
        func digest(for strategy: IndexingStrategy) -> String {
            if let snapshotDigests, let digest = snapshotDigests[strategy.id] { return digest }
            if workingTreeBlobIDs == nil { workingTreeBlobIDs = ContentDigest.workingTreeBlobIDs(root: inspection.root, paths: buildInputPaths) }
            return ContentDigest.digest(for: strategy, blobIDs: workingTreeBlobIDs ?? [:])
        }
        for (position, strategy) in selected.enumerated() {
            guard !Task.isCancelled, generation == self.generation else { return }
            if isCurrent(strategy), loaded[strategy.id] != nil { continue }
            guard let indexer = indexers.first(where: { $0.id == strategy.indexerID }) else { continue }
            let total = selected.count
            let progress = { @Sendable (message: String) -> IndexingProgress in
                IndexingProgress(phase: .indexing, strategy: strategy, step: position + 1, total: total, message: message)
            }
            // Identical bytes elsewhere: copy that strategy's index instead of
            // running the tool. Only format-3 records with a digest qualify.
            let contentDigest = digest(for: strategy)
            if !force, let reused = reuse(strategy, digest: contentDigest, inspection: inspection) {
                guard !Task.isCancelled, generation == self.generation else { return }
                let decoded = Self.snapshotDocuments(reused.index, strategy: strategy, inspection: inspection)
                loaded[strategy.id] = SemanticIndex.Input(index: decoded, projectDirectory: strategy.projectDirectory,
                                                         defaultEncoding: indexer.defaultEncoding)
                publishedIndexIsDirty = true
                let missingFiles = Self.missingFiles(for: strategy, inspection: inspection, index: decoded)
                update(position, generation: generation) {
                    $0.result = .reused(from: reused.label)
                    $0.indexerVersion = reused.record.indexerVersion
                    $0.commandLine = reused.record.commandLine
                    $0.documentCount = decoded.documents.count
                    $0.missingFiles = missingFiles
                    $0.capability = reused.record.capability
                    $0.cargoError = reused.record.cargoError
                    $0.diagnostics = reused.record.diagnostics
                    $0.duration = .seconds(reused.record.duration)
                }
                records.removeAll { $0.strategy == strategy }
                var record = reused.record
                record.contentDigest = contentDigest
                record.reusedFrom = reused.label
                record = IndexMetadata.StrategyRecord(strategy: strategy, indexerVersion: record.indexerVersion, commandLine: record.commandLine,
                                                      fileName: strategy.cacheFileName, documentCount: decoded.documents.count,
                                                      duration: record.duration, missingFiles: missingFiles, capability: record.capability,
                                                      cargoError: record.cargoError, diagnostics: record.diagnostics,
                                                      contentDigest: contentDigest, reusedFrom: reused.label)
                records.append(record)
                await emit(status: .indexing(progress("Reused \(decoded.documents.count) files from \(reused.label).")), generation: generation)
                continue
            }
            await emit(status: .indexing(progress("Checking \(indexer.displayName)…")), generation: generation)
            let availability = await provisioner.availability(of: indexer, refresh: force)
            guard case .available(let executable, let version) = availability else {
                let canInstall = indexer.provisioning(in: provisioner.tools) != nil
                let failure = IndexingFailure(kind: .toolMissing(canInstall: canInstall), indexerID: indexer.id, indexerName: indexer.displayName,
                                              indexerVersion: nil, strategy: strategy, commandLine: nil, exitStatus: nil, signal: nil,
                                              stdout: "", stderr: "", message: availability.reasonText + (canInstall ? "" : " " + indexer.manualInstallation))
                update(position, generation: generation) { $0.result = .failed(failure) }
                firstFailure = firstFailure ?? failure
                continue
            }
            let output = FileManager.default.temporaryDirectory.appending(path: "radiology-\(UUID().uuidString).scip")
            defer { try? FileManager.default.removeItem(at: output) }
            let workspace: IndexingWorkspace?
            do {
                if indexer.requiresIsolatedWorkspace, let buildInputError { throw BrowserError.message(buildInputError) }
                var inputs = inspection
                inputs.blobIDs = inspection.blobIDs ?? workingTreeBlobIDs
                workspace = indexer.requiresIsolatedWorkspace
                    ? try IndexingWorkspace.make(inspection: inputs, parent: cache.directory(for: inspection.root)) : nil
            } catch is CancellationError {
                update(position, generation: generation) { $0.result = .cancelled }
                return
            } catch {
                let failure = IndexingFailure(kind: .processFailed, indexerID: indexer.id, indexerName: indexer.displayName,
                                              indexerVersion: version, strategy: strategy, commandLine: nil, exitStatus: nil, signal: nil,
                                              stdout: "", stderr: "", message: error.localizedDescription)
                update(position, generation: generation) { $0.result = .failed(failure) }
                firstFailure = firstFailure ?? failure
                continue
            }
            defer { workspace?.remove() }
            let command = indexer.command(for: strategy, inspection: workspace?.inspection(from: inspection) ?? inspection,
                                          executable: executable, output: output, tools: provisioner.tools)
            update(position, generation: generation) { $0.indexerVersion = version; $0.commandLine = command.commandLine }
            await emit(status: .indexing(progress("Running \(indexer.displayName)…")), generation: generation)
            let process = IndexerProcess(executable: command.executable, arguments: command.arguments, directory: command.directory, environment: command.environment)
            let result: IndexerRunResult
            do {
                result = try await process.run { [weak self] line in
                    guard let self else { return }
                    if strategy.indexerID == "scip-kotlin", line.hasPrefix("methodDisambiguator:") { return }
                    Task { await self.emit(status: .indexing(progress(line)), generation: generation) }
                }
            } catch is CancellationError {
                update(position, generation: generation) { $0.result = .cancelled }
                return
            } catch {
                let failure = IndexingFailure(kind: .processFailed, indexerID: indexer.id, indexerName: indexer.displayName, indexerVersion: version,
                                              strategy: strategy, commandLine: command.commandLine, exitStatus: nil, signal: nil, stdout: "", stderr: "", message: error.localizedDescription)
                update(position, generation: generation) { $0.result = .failed(failure) }
                firstFailure = firstFailure ?? failure
                continue
            }
            guard !Task.isCancelled, generation == self.generation else { update(position, generation: generation) { $0.result = .cancelled }; return }
            update(position, generation: generation) { $0.duration = result.duration }
            guard result.succeeded else {
                let failure = IndexingFailure(kind: .processFailed, indexerID: indexer.id, indexerName: indexer.displayName, indexerVersion: version,
                                              strategy: strategy, commandLine: command.commandLine, exitStatus: result.exitStatus, signal: result.terminatedBySignal,
                                              stdout: result.stdoutTail, stderr: Self.joinedOutput(result.stderrHead, result.stderrTail),
                                              message: result.terminatedBySignal.map { "\(indexer.displayName) was terminated by signal \($0)." }
                                                ?? "\(indexer.displayName) exited with status \(result.exitStatus).")
                update(position, generation: generation) { $0.result = .failed(failure) }
                firstFailure = firstFailure ?? failure
                continue
            }
            await emit(status: .indexing(progress("Reading the generated index…")), generation: generation)
            var decoded: SCIPIndex
            do {
                try workspace?.verifyInputs()
                decoded = try SCIPDecoder.decode(try Data(contentsOf: output))
                decoded = Self.snapshotDocuments(decoded, strategy: strategy, inspection: inspection)
            } catch {
                let failure = IndexingFailure(kind: .invalidOutput, indexerID: indexer.id, indexerName: indexer.displayName, indexerVersion: version,
                                              strategy: strategy, commandLine: command.commandLine, exitStatus: result.exitStatus, signal: nil,
                                              stdout: result.stdoutTail, stderr: Self.joinedOutput(result.stderrHead, result.stderrTail), message: "The indexer finished but its output could not be read: \(error.localizedDescription)")
                update(position, generation: generation) { $0.result = .failed(failure) }
                firstFailure = firstFailure ?? failure
                continue
            }
            let effectiveCommandLine = command.commandLine
            let effectiveDuration = result.duration
            let diagnostics = Self.importantDiagnostics(result.stderrHead, result.stderrTail)
            let degraded = strategy.indexerID == "rust-analyzer"
                && (result.stderrHead.contains("`cargo metadata` failed")
                    || result.stderrHead.contains("--no-deps")
                    || result.stderrTail.contains("`cargo metadata` failed")
                    || result.stderrTail.contains("--no-deps"))
            let kotlinPartial = strategy.indexerID == "scip-kotlin"
                && (result.stderrTail.contains("RADIOLOGY_KOTLIN_PARTIAL_BUILD")
                    || !Self.missingFiles(for: strategy, inspection: inspection, index: decoded).isEmpty)
            let capability: SemanticCoverageCapability = degraded ? .sourceOnlyNoDeps : (kotlinPartial ? .partialBuild : .fullWorkspace)
            let cargoError = degraded ? Self.firstCargoError(in: result.stderrHead + "\n" + result.stderrTail) : nil
            guard !decoded.documents.isEmpty else {
                let failure = IndexingFailure(kind: .invalidOutput, indexerID: indexer.id, indexerName: indexer.displayName, indexerVersion: version,
                                              strategy: strategy, commandLine: command.commandLine, exitStatus: result.exitStatus, signal: nil,
                                              stdout: result.stdoutTail, stderr: Self.joinedOutput(result.stderrHead, result.stderrTail), message: "\(indexer.displayName) produced an index with no documents.")
                update(position, generation: generation) { $0.result = .failed(failure) }
                firstFailure = firstFailure ?? failure
                continue
            }
            guard !Task.isCancelled, generation == self.generation else { update(position, generation: generation) { $0.result = .cancelled }; return }
            // Only now does the result enter the cache and the published model.
            let destination = cache.indexURL(for: inspection.root, strategy: strategy)
            do {
                try FileManager.default.createDirectory(at: cache.directory(for: inspection.root), withIntermediateDirectories: true)
                if FileManager.default.fileExists(atPath: destination.path) { try FileManager.default.removeItem(at: destination) }
                try FileManager.default.moveItem(at: output, to: destination)
            } catch {
                // The index is still usable this session even if the cache write failed.
            }
            guard generation == self.generation else { return }
            loaded[strategy.id] = SemanticIndex.Input(index: decoded, projectDirectory: strategy.projectDirectory,
                                                     defaultEncoding: indexer.defaultEncoding)
            publishedIndexIsDirty = true
            let missingFiles = Self.missingFiles(for: strategy, inspection: inspection, index: decoded)
            update(position, generation: generation) {
                $0.result = .generated
                $0.documentCount = decoded.documents.count
                $0.commandLine = effectiveCommandLine
                $0.duration = effectiveDuration
                $0.missingFiles = missingFiles
                $0.capability = capability
                $0.cargoError = cargoError
                $0.diagnostics = diagnostics
            }
            records.removeAll { $0.strategy == strategy }
            records.append(IndexMetadata.StrategyRecord(strategy: strategy, indexerVersion: version, commandLine: effectiveCommandLine,
                                                        fileName: strategy.cacheFileName, documentCount: decoded.documents.count,
                                                        duration: Double(effectiveDuration.components.seconds) + Double(effectiveDuration.components.attoseconds) / 1e18,
                                                        missingFiles: missingFiles, capability: capability,
                                                        cargoError: cargoError, diagnostics: diagnostics,
                                                        contentDigest: contentDigest, reusedFrom: nil))
            await emit(status: .indexing(progress("Indexed \(decoded.documents.count) files.")), generation: generation)
        }
        guard !Task.isCancelled, generation == self.generation else { return }
        let succeeded = selected.filter { loaded[$0.id] != nil }
        if !records.isEmpty {
            let updated = IndexMetadata(repositoryRoot: inspection.root.path, headCommit: head, workingTreeFingerprint: fingerprint.workingTree,
                                        buildFingerprint: fingerprint.build, generatedAt: .now, strategies: records.filter { record in selected.contains(record.strategy) },
                                        skippedStrategies: skipped, revision: options.revision)
            try? cache.save(updated, for: inspection.root)
            metadata = updated
        }
        let hasDegradedCoverage = outcomes.contains { $0.capability != .fullWorkspace }
        let reuseWarning = mixedReuseReason(records: metadata?.strategies ?? records)
        if let firstFailure, loaded.isEmpty {
            await emit(status: .failed(firstFailure), generation: generation)
        } else if firstFailure != nil || hasDegradedCoverage {
            await emit(status: .partial(reason: "Some projects failed or have incomplete compiler coverage. Covered files remain navigable; inspect each project below."), generation: generation)
        } else if let reuseWarning {
            await emit(status: .partial(reason: reuseWarning), generation: generation)
        } else if succeeded.count == selected.count {
            await emit(status: .current, generation: generation)
        } else {
            await emit(status: .noIndex(reason: "Indexing did not produce any documents."), generation: generation)
        }
    }

    /// Disk records retain provenance even when all this run's outcomes are cached.
    private func mixedReuseReason(records: [IndexMetadata.StrategyRecord]) -> String? {
        let origins = Set(records.map { $0.reusedFrom ?? "generated here" })
        guard origins.count > 1, records.contains(where: { $0.reusedFrom != nil }) else { return nil }
        return "Projects were reused and regenerated, or reused from different revisions. Cross-project references may be outdated; Reindex regenerates everything."
    }

    private func cachedCoverageStatus() -> SemanticIndexStatus {
        if let reason = mixedReuseReason(records: metadata?.strategies ?? []) { return .partial(reason: reason) }
        return outcomes.contains { $0.capability != .fullWorkspace }
            ? .partial(reason: "Some projects have incomplete compiler coverage. Covered files remain navigable; inspect each project below.")
            : .current
    }

    private func emit(status: SemanticIndexStatus, generation: UUID) async {
        guard generation == self.generation, let publish, let inspection else { return }
        if publishedIndexIsDirty {
            publishedIndex = loaded.isEmpty ? .empty : SemanticIndex(inputs: selected.compactMap { loaded[$0.id] })
            publishedIndexIsDirty = false
        }
        await publish(SemanticPublication(repositoryRoot: inspection.root, index: publishedIndex, status: status, outcomes: outcomes, skipped: skipped,
                                          unsupportedLanguages: unsupported, metadata: metadata, cacheDirectory: cache.directory(for: inspection.root)))
    }

    /// A strategy file from another cache whose recorded digest equals
    /// `digest`, copied into this run's cache directory. The current cache's
    /// own stale record is never a candidate (its digest already mismatched).
    private struct ReusedStrategy {
        let index: SCIPIndex
        let record: IndexMetadata.StrategyRecord
        let label: String
    }

    private func reuse(_ strategy: IndexingStrategy, digest: String, inspection: RepositoryInspection) -> ReusedStrategy? {
        for source in options.reuseSources {
            guard source.cache != cache || source.root != inspection.root,
                  let metadata = source.cache.loadMetadata(for: source.root),
                  let record = metadata.strategies.first(where: { $0.strategy.id == strategy.id && $0.contentDigest == digest }) else { continue }
            let origin = source.cache.directory(for: source.root).appending(path: record.fileName)
            guard let data = try? Data(contentsOf: origin), let raw = try? SCIPDecoder.decode(data) else { continue }
            let decoded = Self.snapshotDocuments(raw, strategy: strategy, inspection: inspection)
            guard !decoded.documents.isEmpty else { continue }
            let destination = cache.indexURL(for: inspection.root, strategy: strategy)
            do {
                try FileManager.default.createDirectory(at: cache.directory(for: inspection.root), withIntermediateDirectories: true)
                if FileManager.default.fileExists(atPath: destination.path) { try FileManager.default.removeItem(at: destination) }
                try FileManager.default.copyItem(at: origin, to: destination)
            } catch {
                continue
            }
            return ReusedStrategy(index: decoded, record: record, label: record.reusedFrom ?? source.label)
        }
        return nil
    }

    private func headCommit(_ inspection: RepositoryInspection) async -> String? {
        guard inspection.isGit, let git = ToolLocator.executable("git") else { return nil }
        guard let data = try? await commands.run(git, arguments: ["rev-parse", "HEAD"], directory: inspection.root) else { return nil }
        let text = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private static func missingFiles(for strategy: IndexingStrategy, inspection: RepositoryInspection, index: SCIPIndex) -> [MissingSourceFile] {
        let extensions = SemanticIndexerRegistry.extensions(for: strategy.languages)
        let prefix = strategy.projectDirectory.isEmpty ? "" : strategy.projectDirectory + "/"
        let expected = inspection.paths.filter {
            $0.hasPrefix(prefix) && extensions.contains(URL(filePath: $0).pathExtension.lowercased())
        }
        let covered = Set(index.documents.map { prefix + $0.relativePath })
        let rustTexts: [String] = strategy.indexerID == "rust-analyzer" ? expected.compactMap {
            try? String(contentsOf: inspection.root.appending(path: $0), encoding: .utf8)
        } : []
        return expected.filter { !covered.contains($0) }.sorted().map { path in
            let components = path.split(separator: "/")
            let reason: MissingSourceFile.Reason
            if components.contains("vendor") || components.contains("vendored") {
                reason = .excludedVendored
            } else if strategy.indexerID == "rust-analyzer" {
                let stem = URL(filePath: path).deletingPathExtension().lastPathComponent
                let declarations = rustTexts.compactMap { text -> Bool? in
                    let lines = text.split(whereSeparator: \.isNewline).map(String.init)
                    guard let line = lines.firstIndex(where: {
                        $0.contains("mod \(stem);") || $0.contains("mod \(stem) {")
                    }) else { return nil }
                    let context = lines[max(0, line - 2)...line].joined(separator: "\n")
                    return context.contains("#[cfg")
                }
                if declarations.isEmpty { reason = .orphan }
                else if declarations.allSatisfy({ $0 }) { reason = .inactiveConfiguration }
                else { reason = .unknown }
            } else {
                reason = .unknown
            }
            return MissingSourceFile(path: path, reason: reason)
        }
    }

    private static func importantDiagnostics(_ head: String, _ tail: String) -> String {
        let stderr = joinedOutput(head, tail)
        guard !stderr.isEmpty else { return "" }
        let lines = stderr.split(whereSeparator: \.isNewline).map(String.init)
        let important = lines.filter {
            let line = $0.lowercased()
            return line.contains("failed") || line.contains("warning") || line.contains("error") || line.contains("duplicate")
        }
        return important.suffix(80).joined(separator: "\n")
    }

    private static func joinedOutput(_ head: String, _ tail: String) -> String {
        head + (head == tail || tail.isEmpty ? "" : "\n…\n" + tail)
    }

    private static func firstCargoError(in stderr: String) -> String? {
        let lines = stderr.split(whereSeparator: \.isNewline).map {
            String($0).trimmingCharacters(in: .whitespaces)
        }
        return lines.first { $0.hasPrefix("error:") }
    }

    /// Generated Gradle files live only in the disposable build copy. They
    /// cannot be opened in the pinned source snapshot and must not become
    /// navigable definitions. Apply the same boundary on generation/cache/reuse.
    private static func snapshotDocuments(_ index: SCIPIndex, strategy: IndexingStrategy, inspection: RepositoryInspection) -> SCIPIndex {
        guard strategy.indexerID == "scip-kotlin" else { return index }
        let paths = Set(inspection.paths)
        let prefix = strategy.projectDirectory.isEmpty ? "" : strategy.projectDirectory + "/"
        var result = index
        result.documents.removeAll { !paths.contains(prefix + $0.relativePath) }
        return result
    }

    /// Parsed languages present in the repository that no selected strategy covers.
    static func unsupportedLanguages(in inspection: RepositoryInspection, covered: [IndexingStrategy]) -> [String] {
        let coveredNames = Set(covered.flatMap(\.languages))
        var present = Set<String>()
        for path in inspection.paths {
            let language = RepositoryFile(path: path).language
            if language != "Plain text" { present.insert(language) }
        }
        return present.subtracting(coveredNames).subtracting(["Markdown", "JSON", "YAML", "TOML", "HTML", "CSS", "Shell", "SQL"]).sorted()
    }
}

extension SemanticIndexerRegistry {
    static func extensions(for languages: [String]) -> Set<String> {
        var extensions = Set<String>()
        for language in languages {
            switch language {
            case "Rust": extensions.insert("rs")
            case "Go": extensions.insert("go")
            case "TypeScript": extensions.formUnion(["ts", "tsx", "mts", "cts"])
            case "JavaScript": extensions.formUnion(["js", "jsx", "mjs", "cjs"])
            case "Python": extensions.formUnion(["py", "pyi"])
            case "Kotlin": extensions.insert("kt")
            case "Java": extensions.insert("java")
            case "C": extensions.formUnion(["c", "h"])
            case "C++": extensions.formUnion(["cpp", "cc", "cxx", "hpp", "hh", "hxx"])
            default: break
            }
        }
        return extensions
    }

    /// Shallow project directories first so a monorepo's main projects win the
    /// cap, with registry order breaking ties between indexers at one depth.
    static func strategies(for inspection: RepositoryInspection, indexers: [any SemanticIndexer], limit: Int = 32) -> (selected: [IndexingStrategy], skipped: [IndexingStrategy]) {
        let ordered = indexers.enumerated().flatMap { order, indexer in
            indexer.strategies(for: inspection).map { strategy -> (order: Int, strategy: IndexingStrategy) in
                var counted = strategy
                counted.sourceFileCount = inspection.count(extensions: Self.extensions(for: strategy.languages), under: strategy.projectDirectory)
                return (order, counted)
            }
        }.sorted { lhs, rhs in
            let lhsDepth = lhs.strategy.projectDirectory.isEmpty ? 0 : lhs.strategy.projectDirectory.split(separator: "/").count
            let rhsDepth = rhs.strategy.projectDirectory.isEmpty ? 0 : rhs.strategy.projectDirectory.split(separator: "/").count
            if lhsDepth != rhsDepth { return lhsDepth < rhsDepth }
            if lhs.order != rhs.order { return lhs.order < rhs.order }
            return lhs.strategy.projectDirectory < rhs.strategy.projectDirectory
        }.map(\.strategy)
        return (Array(ordered.prefix(limit)), Array(ordered.dropFirst(limit)))
    }
}
