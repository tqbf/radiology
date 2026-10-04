import Foundation

/// `scip-clang` for C, C++, and CUDA. It only works from a JSON compilation
/// database, so the strategy exists only when `compile_commands.json` is
/// present. Emits UTF-8 offsets. Radiology does not download this binary
/// itself in the current cut; the release asset has no published checksum.
struct ScipClangIndexer: SemanticIndexer {
    let id = "scip-clang"
    let displayName = "scip-clang"
    let defaultEncoding = ColumnEncoding.utf8
    let pinnedVersion: String? = "0.4.0"
    let manualInstallation = "Download scip-clang for arm64 macOS from https://github.com/sourcegraph/scip-clang/releases and place it on PATH or in Radiology's tools/bin directory."

    func strategies(for inspection: RepositoryInspection) -> [IndexingStrategy] {
        guard let database = inspection.first(named: "compile_commands.json") else { return [] }
        return [IndexingStrategy(indexerID: id, projectDirectory: "", evidence: [database], languages: ["C", "C++"])]
    }

    func locate(in tools: ToolDirectory) -> URL? {
        tools.locate("scip-clang", candidates: [tools.bin.appending(path: "scip-clang")])
    }

    func command(for strategy: IndexingStrategy, inspection: RepositoryInspection, executable: URL, output: URL, tools: ToolDirectory) -> IndexCommand {
        IndexCommand(executable: executable,
                     arguments: ["--compdb-path", strategy.evidence.first ?? "compile_commands.json", "--index-output-path", output.path, "--no-progress-report"],
                     directory: inspection.root, environment: ToolDirectory.childEnvironment())
    }

    func provisioning(in tools: ToolDirectory) -> ProvisioningPlan? { nil }
}
