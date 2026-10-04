# Future-agent handoff

## Reading order and workspace status

Read `README.md`, `PLAN.md`, the top of `PROGRESS.md`, this file, and `plans/development-history.md`, then the subsystem document for the requested task. The newest accepted state is that the user confirmed the large-function folding latency is fixed and asked to settle/document; there is no active implementation request or heartbeat.

The root SwiftPM package is the only active codebase, now tracked in Git on `main` for [tqbf/radiology](https://github.com/tqbf/radiology). The user explicitly authorized Git initialization, committing the project, and publishing it after the documentation round. Any local nested `repo/` is an inactive starter copy, ignored by Git; never edit it. Preserve unrelated workspace changes. Commits and PRs are allowed within the requested task, but agents must never merge to `main`.

## Architecture map

Radiology is a read-only repository browser, not an editor or LSP client.

| Area | Key entry points | Contract |
| --- | --- | --- |
| App/state | `RadiologyApp.swift`, `AppModel.swift`, `AppModel+Semantics.swift` | Main-actor orchestration; generation guards prevent stale async publication |
| Repository | `RepositoryWorker.swift`, `RepositorySnapshot.swift`, `CommandRunner.swift` | Git-aware discovery with filesystem fallback; browsing survives tool failure |
| Source | `SourceBuffer.swift`, `SourceStore.swift`, `ReaderTextView.swift`, `SourceViewerCoordinator.swift` | Immutable canonical UTF-8 bytes; UTF-16 only at TextKit boundaries; 16 MiB limit |
| Structure | `SourceLanguage.swift`, `SyntaxWorker.swift`, `SyntaxSnapshot.swift`, `Queries/` | Actor-isolated Tree-sitter; source publishes before parsing; malformed/unsupported files remain readable |
| Navigation/folds | `NavigationHistory.swift`, `DocumentOutlineView.swift`, `SourceBreadcrumbs.swift`, `LineNumberGutter.swift` | Exact pinned destinations; passive scrolling does not add history; reveal removes enclosing folds |
| Search | `SearchWorker.swift`, `RepositorySearchView.swift` | Cancellable ripgrep process; optional dependency |
| File picker | `QuickFileSearch.swift`, `QuickFilePicker.swift` | Off-main cancellable fuzzy ranking; max 100 shown with truthful total |
| Semantics | `SemanticIndexService.swift`, `SemanticIndex.swift`, `SCIP/`, `Indexers/` | App-owned batch SCIP, normalized model, cached stale data, independent strategy outcomes |
| Occurrences | `DocumentSemantics.swift`, `OccurrencePinning.swift`, `ReaderTextView.swift` | Semantic identity first; local syntax fallback is drawing-only; pins are document/source-identity scoped |

## Invariants and pitfalls

1. **Bytes are canonical.** Tree-sitter and app navigation use UTF-8 byte offsets. SCIP UTF-8/16/32 positions are converted against the loaded `SourceBuffer`. TextKit uses UTF-16 only at its boundary. Test emoji/non-ASCII whenever ranges change.
2. **Browsing never waits for analysis.** Publish source immediately; syntax and semantics arrive asynchronously with cancellation and generation/repository guards.
3. **Semantic actions never guess.** The cfg-inactive exact-identifier fallback may decorate same-spelled tokens inside one function/closure, including shadowed locals, but may not supply definition/reference targets.
4. **Folding does not alter backing text.** Null glyphs/zero advancement hide effective disjoint outer folds. The gutter enumerates actual visible TextKit fragments. Preserve original line numbers, copy/find ranges, pins, history, and canonical bytes.
5. **Fold performance is range-indexed.** Effective ranges are sorted/disjoint, membership is binary search, and updates diff old/new unions. Avoid whole-document glyph regeneration and per-character linear fold scans.
6. **Reveal before scroll.** Outline/semantic/history targets must unfold all hiding ancestors, force the necessary layout, then reveal with revision guards. Passive synchronization must not overwrite committed history.
7. **Indexer failures are isolated.** Successful strategy output survives another strategy's failure. Degraded Rust output remains Partial. Diagnostics retain bounded head and tail so the first Cargo error is not lost.
8. **Repositories are never modified for indexing.** Use real manifests/features/cfg identity. Do not vendor tkos or create synthetic shadow manifests.
9. **Pins have stable identity/color.** Key them by document plus source byte count/checksum and canonical ranges; changed content invalidates them. Removing a group must not recolor remaining groups.

## Current implementation facts

- Syntax: Swift, Rust, Go, Python, JavaScript/JSX, TypeScript/TSX, Kotlin; eight grammar registrations and 31 Radiology `.scm` resources.
- Semantics: adapters for Rust, Go, TypeScript/JavaScript, Python, and C/C++. No Swift/Kotlin/Java adapter. C/C++ requires `compile_commands.json` and manual `scip-clang`; Python needs 3.10+.
- Cache: `~/Library/Caches/Radiology/repositories/<repo-id>/`. Provisioned tools/support: `~/Library/Application Support/Radiology/tools/`.
- Gutter: 104 points, distinct 28-point disclosure/count/line-number lanes, 3-point logarithmic 6–22-point meter, 9-point medium tabular exact-count capsule.
- Latest recorded baseline: 97 tests/16 suites from the final performance round. Treat it as historical until rerun.
- User acceptance: after the isolated benchmark and CUA attachment limitation, the user independently confirmed the folding fix works.

## Validation commands

Choose checks proportional to the change:

```sh
make check
make test
make build
codesign --verify --deep --strict build/Radiology.app
build/Radiology.app/Contents/MacOS/Radiology --verify-resources
```

The opt-in real-source folding probe requires the external tkos checkout:

```sh
RADIOLOGY_REAL_FOLD_BENCHMARK=1 swift test --filter realAppFoldPerformanceProbe
```

Do not describe its timings as full-app pointer latency. For indexing, distinguish fixture generation, product-code lookup against a cache, and a controlled cold app run on untouched tkos. Only the latter satisfied the user's real-repository gate.

## Known gaps and evidence boundaries

- No editing, LSP, filesystem watcher, incremental parse cache, or language injection.
- Semantic completeness varies with project/indexer/toolchain. The recorded tkos run covered 338/340 Rust files, but that is one historical controlled run, not a universal guarantee.
- Engine Rust indexing was source-only/no-deps because `deno_core` vendor inputs were absent. `snapshot_profiles_test.rs` was an undeclared orphan. `tkreplica/test_support/fixture_paths.rs` was omitted through a path-module shape; its deeper cause remains uncertain.
- Python 3.10 was required while the development machine had 3.9; scip-clang still needed metadata and a manually installed binary.
- Go grouped declarations/interfaces and JSX elements are not foldable; expression-bodied functions naturally have no body to hide.
- Dark pin palette logic was not live visually verified in its implementation round.
- Native automation availability varied. Do not repeat stale claims that CUA always attaches; the final performance pass ended with `cgWindowNotFound`. The user's later acceptance is the strongest final interaction evidence.

## Evidence and sensible next work

- Exact chronology and acceptance: `plans/development-history.md` and `PROGRESS.md`.
- Syntax/query provenance: `plans/tree-sitter.md`, `Package.resolved`, `Sources/GrammarScanners/PROVENANCE.md`.
- Folding and benchmark: `plans/structural-navigation.md`, `SourceScrollViewTests.swift`.
- Indexing/support: `plans/scip-semantic-navigation.md`, `SemanticIndexService.swift`, `Indexers/`.
- Real tkos measurements: 2026-10-03 entries in `PROGRESS.md` and prior Paseo agent `fd0b558f-487f-4faa-8a95-c579f6a95eed`.

There is no urgent product follow-up. Sensible future slices, only when requested, are filesystem-driven invalidation, deeper indexer coverage/robustness, multiple-definition chooser UX, and accessibility/dark-mode visual verification. Apply `swiftui-pro` before/after code decisions, `macos-design` for UI changes, and `typography-designer` for any new or changed type role.
