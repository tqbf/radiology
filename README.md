# Radiology

Radiology is a native, read-only macOS code browser for understanding unfamiliar repositories. It combines Git-aware file discovery, a TextKit source reader, ripgrep search, Tree-sitter structure, and optional SCIP semantic navigation. It is intentionally not an editor and does not run language servers.

## Requirements and quick start

- macOS 14 or newer
- Swift 6.2 or newer (Xcode or a standalone Swift toolchain)
- `ripgrep` (`rg`) for repository-wide text search; browsing and reading work without it
- language-specific SCIP indexers only when semantic navigation is wanted (see below)

```sh
make run       # debug build, assemble/sign build/Radiology.app, then open it
make build     # debug build and assemble/sign build/Radiology.app
make check     # compile with SwiftPM; no app bundle or signing
make test      # run the Swift Testing suite
make release   # release build into build/Radiology.app
make help      # all build/install/distribution targets
```

The active project is this root Swift package, tracked at [tqbf/radiology](https://github.com/tqbf/radiology). An inherited local `repo/` starter copy is ignored by Git and must not be edited. Release targets require the matching Git tag and any configured signing/notarization credentials described in [the build guide](plans/build-system.md).

## Open and navigate

Open a folder with **File > Open Repository…**, a recent-folder entry, Finder drag and drop, or the development launch arguments below. Repository discovery uses `git ls-files` when possible and otherwise walks the folder while excluding common generated/vendor directories.

The primary workflows are:

- Browse or filter the repository tree, or use fuzzy **Go to File**. Queries are ordered subsequences: for example, `engrs` can match `engine-foo.rs`.
- Read syntax-highlighted source with original line numbers, outline, breadcrumbs, default-collapsed function bodies, and exact Back/Forward history.
- Search the current file with the native Find panel or the repository with ripgrep literal/regex, case, and glob controls.
- With a SCIP index, Command-hover a resolvable occurrence, Command-click or invoke Go to Definition, inspect references, and search repository symbols.
- Single-click a symbol to highlight its current-file occurrences. Double-click locks an occurrence group; several teal/amber/violet/rose groups may coexist, and double-clicking any member unlocks only that group. When SCIP omits cfg-inactive code, a Tree-sitter fallback highlights exact same-spelled identifiers inside the innermost function only; it is never used to guess definitions or references.

### Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| ⌘O | Open repository/folder |
| ⌘K / ⌘P | Go to file (fuzzy) |
| ⌘T | Go to semantic symbol |
| ⌘L | Go to line |
| ⌘[ / ⌘] | Back / Forward |
| ⌘F, ⌘G, ⇧⌘G | Find in file / next / previous |
| ⇧⌘F | Search repository |
| ⌃⌘J | Go to definition at caret |
| ⌃⌘R | Find references at caret |
| ⌃⌘I | Reindex repository |
| ⌘R | Reload repository |
| ⌥⌘0 | Fold to Definitions |
| ⇧⌘0 | Collapse Functions |
| ⌘+ / ⌘− | Increase / decrease source text size |

Outline Up/Down previews a declaration and Return commits it to navigation history. Clicking an outline item commits immediately and unfolds any ancestors that hide the destination. Fold disclosure targets occupy a 28-point gutter lane; collapsed functions also show an exact hidden-line badge and a logarithmic size meter.

## Syntax languages

Tree-sitter highlighting, declarations/scopes, outline, breadcrumbs, and folding are bundled for:

| Language | Extensions |
| --- | --- |
| Swift | `.swift` |
| Rust | `.rs` |
| Go | `.go` |
| Python | `.py`, `.pyi` |
| JavaScript / JSX | `.js`, `.jsx`, `.mjs`, `.cjs` |
| TypeScript | `.ts`, `.mts`, `.cts` |
| TSX | `.tsx` |
| Kotlin | `.kt`, `.kts` |

These are eight grammar registrations backed by 31 Radiology query resources. Unsupported extensions remain readable as plain UTF-8 text. Files over 16 MiB are rejected. Source locations are canonical UTF-8 byte offsets; conversion to UTF-16 happens only at TextKit and semantic-index boundaries.

## Semantic indexing

Radiology detects projects, runs batch SCIP generators outside the UI process, caches successful data, and reports **No Index**, **Indexing**, **Current**, **Possibly Stale**, **Failed**, or **Partial**. A stale cached index remains usable while refresh runs. Indexing failures do not block browsing.

| Project evidence | Indexer | Installation behavior |
| --- | --- | --- |
| `Cargo.toml` | `rust-analyzer scip` | Radiology can run `rustup component add rust-analyzer` when `rustup` exists |
| `go.mod` | `scip-go` 0.2.7 | Radiology can install with Go into its private tools directory |
| `tsconfig.json` / JS/TS `package.json` | `scip-typescript` 0.4.0 | Radiology can install with Node/npm; project dependencies are still needed |
| Python project markers | `scip-python` 0.6.6 | Radiology can install with Node/npm; Python 3.10+ is required |
| `compile_commands.json` | `scip-clang` 0.4.0 | Manual binary installation only |

Swift, Kotlin, and Java have no semantic indexer adapter in the current implementation. Syntax structure still works for Swift and Kotlin. `rust-analyzer scip` is a batch index generator here, not a persistent LSP backend.

Generated indexes and metadata live outside the repository at `~/Library/Caches/Radiology/repositories/<repository-id>/`. Provisioned executables and per-run support files live at `~/Library/Application Support/Radiology/tools/`.

Radiology discovers at most 32 project strategies, shallowest first, and explicitly reports skipped projects. Independent project failures preserve successful indexes. A degraded Rust source-only result remains **Partial**, never **Current**.

## Development launch and diagnostics

```sh
build/Radiology.app/Contents/MacOS/Radiology \
  --repository /absolute/path/to/repository \
  --file relative/path/to/file.rs

build/Radiology.app/Contents/MacOS/Radiology --verify-resources
```

`--repository PATH` opens a folder, `--file RELATIVE_PATH` selects a file inside it, and `--verify-resources` compiles every bundled grammar/query combination and exits before opening a window.

For problems:

- Open the index-status popover for indexer name/version, command, exit status, bounded diagnostic head/tail, missing-file reports, Reindex, Cancel, and Install actions.
- If repository search is unavailable, install `rg`; Finder launches also check the build-recorded path and standard Homebrew/PATH locations.
- If an index is Possibly Stale, use Reindex. Partial may still provide useful intra-crate navigation.
- Python indexing needs Python 3.10+ even if its npm package installs. C/C++ needs both `compile_commands.json` and a manually installed `scip-clang`.
- Tree-sitter failures degrade to plain text or partial structure. Unsupported languages never gain semantic behavior by textual guessing.
- The local bundle is ad-hoc signed and intentionally not App Sandbox enabled because it launches Git, ripgrep, and indexers.

## Honest limitations

- Read-only: no editing, refactoring, LSP sessions, filesystem watching, or language injection.
- Parsing is whole-file and fold state is session-local. Some grammar constructs (notably Go grouped declarations/interfaces and JSX elements) have no fold capture.
- SCIP quality is bounded by project manifests, installed tools, dependencies, cfg/features, and each indexer's behavior. Multiple definitions default to the first, with alternatives shown in the inspector.
- Locked occurrence fallback is deliberately spelling-based within one parsed function and includes shadowed locals; semantic navigation remains SCIP-only.
- The large-file fold optimization has an isolated real-source TextKit benchmark, but its recorded numbers are not a full-app pointer latency guarantee on other machines.
- Dark-mode pin colors follow a deterministic appearance-aware path but were not visually verified in the recorded development round.

## Documentation

Start with [PLAN.md](PLAN.md) and [PROGRESS.md](PROGRESS.md). Then use:

- [Development history](plans/development-history.md) — chronological requests, changes, bugs, acceptance, and historical evidence
- [Future-agent handoff](plans/agent-handoff.md) — current state, architecture, invariants, entry points, validation, and pitfalls
- [Architecture](plans/architecture.md), [design system](plans/design-system.md), and [build system](plans/build-system.md)
- [Tree-sitter](plans/tree-sitter.md), [structural navigation](plans/structural-navigation.md), [SCIP](plans/scip-semantic-navigation.md), and [quick file picker](plans/quick-file-picker.md)
- [Grammar scanner provenance](Sources/GrammarScanners/PROVENANCE.md)
