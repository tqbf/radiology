# Radiology documentation index and current state

Radiology is a native, read-only macOS repository browser. The active implementation is the root SwiftPM package, now tracked in Git on `main` for [tqbf/radiology](https://github.com/tqbf/radiology). A local nested `repo/` directory is an inherited, inactive starter copy, excluded from version control: do not edit it. The user explicitly authorized initializing Git and publishing the project after the documentation handoff. Project policy permits commits and PRs but never permits an agent to merge to `main`.

## Current accepted state

The user confirmed on 2026-10-04 that the latest large-function folding fix works: “yeah you fixed it, you can settle at this point.” No additional product work is requested. The recurring status heartbeat was deleted and must not be recreated unless the user asks.

Delivered behavior includes repository opening/recent/drop/CLI launch, Git-aware discovery, read-only TextKit source, ripgrep search, exact history, Tree-sitter structure for eight grammars, structural navigation and folding, fuzzy file lookup, and app-owned SCIP generation/navigation. The current fold gutter is 104 points wide with separate 28-point disclosure, exact hidden-line count, and canonical line-number lanes; the earlier 68-point/faint 2-point meter was superseded. Large-fold membership is binary-searched and glyph/layout invalidation is limited to changed ranges. Ordinary and locked occurrence highlighting coexist with native selection; a function-local Tree-sitter fallback covers parsed occurrences absent from SCIP without becoming a semantic guess.

The latest recorded implementation gate—historical evidence, not a test run by the documentation agent—was `make check`, 97 tests in 16 suites, a signed build, strict code-sign verification, and packaged verification of eight grammars/31 query files. The user’s acceptance is separate evidence that the reported fold interaction is fixed. See PROGRESS.md and the development history for the exact boundary.

## Required reading order

1. [README.md](README.md) — product usage, requirements, commands, shortcuts, supported languages/indexers, caches, and troubleshooting.
2. [PROGRESS.md](PROGRESS.md) — newest-first evidence log, including user acceptance and historical validation counts.
3. [plans/agent-handoff.md](plans/agent-handoff.md) — architecture map, invariants, key files, validation, gaps, and working constraints.
4. [plans/development-history.md](plans/development-history.md) — chronological development rounds and superseded behavior.
5. The subsystem document relevant to the next task.

## Subsystem documentation

- [plans/architecture.md](plans/architecture.md) — layers, actors, canonical coordinates, and lifecycle.
- [plans/design-system.md](plans/design-system.md) — native macOS layout, type roles, color, source and gutter presentation.
- [plans/build-system.md](plans/build-system.md) — SwiftPM, bundle assembly, signing, optional release pipeline, and external tools.
- [plans/tree-sitter.md](plans/tree-sitter.md) — grammar versions, query resources, parsing contract, fallbacks, and syntax limits.
- [plans/structural-navigation.md](plans/structural-navigation.md) — outline synchronization, breadcrumbs, folding, reveal behavior, gutter geometry, and performance.
- [plans/scip-semantic-navigation.md](plans/scip-semantic-navigation.md) — SCIP decoder/model, strategy discovery, adapters, provisioning, cache/freshness, navigation, occurrence highlighting, and limits.
- [plans/scip-ui-handoff.md](plans/scip-ui-handoff.md) — historical first-cut UI test handoff; consult current PROGRESS/handoff before treating its open items as current.
- [plans/quick-file-picker.md](plans/quick-file-picker.md) — Cmd-K/Cmd-P search/ranking/lifecycle.
- [Sources/GrammarScanners/PROVENANCE.md](Sources/GrammarScanners/PROVENANCE.md) — vendored JavaScript/Python scanner sources.
- [radiology.plan.md](radiology.plan.md) — original long-form product specification; useful direction, not current completion status.
- [treesitter.plan.md](treesitter.plan.md) — original Swift-first Tree-sitter request, preserved as history.
- [plans/roadmap.md](plans/roadmap.md) — delivered scope and possible future slices.
- [SWIFTUI-RULES.md](SWIFTUI-RULES.md), [PROBLEMS.md](PROBLEMS.md) — inherited implementation lessons and pitfalls.
- [plans/renaming.md](plans/renaming.md) — historical template rename notes; not an onboarding step.

## Maintenance rules

- Keep this file the master index; put deep documentation under `plans/` and update PROGRESS.md after work.
- Read and follow AGENTS.md. Use `swiftui-pro` before and after code decisions, `macos-design` for UI decisions, and `typography-designer` whenever setting type. A documentation-only description of existing behavior does not authorize redesign.
- Preserve canonical UTF-8 byte locations and convert only at boundaries. Do not make semantic navigation guess from spelling.
- Never edit the viewed repository during indexing tests. In particular, do not vendor dependencies into tkos or synthesize shadow manifests to conceal real project failures.
- Do not present old test totals as current. Label every recorded count/timing by its development round and say when no fresh test run was performed.
