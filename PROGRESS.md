# Progress

## 2026-10-04 — Git initialization and GitHub publication

The user requested committing the completed project, creating `tqbf/radiology`,
and pushing it. This explicitly supersedes the earlier documentation-only
restriction against initializing Git. Initialized the active root package on
`main` for publication to [tqbf/radiology](https://github.com/tqbf/radiology).
The initial snapshot includes source, tests, resources, package resolution,
build scripts, and the full documentation handoff. Generated build output,
machine-local files, and the inactive nested `repo/` starter copy are ignored.
The nested copy and its existing metadata remain untouched.

Updated README, PLAN, the agent handoff, and the build guide to remove obsolete
claims that the active root has no version control. Git commits use the `tqbf`
account's GitHub noreply identity. This publication round changes no application
behavior and does not rerun the already recorded implementation checks.

## 2026-10-04 — User acceptance and documentation handoff (current state)

The user confirmed the latest large-file folding result in the running product:
“yeah you fixed it, you can settle at this point.” This is direct acceptance of
the interaction issue and is separate from the preceding isolated TextKit
benchmark and its final `cgWindowNotFound` automation limitation. No further
product change is requested. The recurring status heartbeat `10e731d2` was
deleted after that instruction and was not recreated.

Completed the documentation/handoff round. `README.md` now documents actual
requirements, commands, launch arguments, shortcuts, workflows, languages,
semantic indexers, caches, diagnostics and limitations.
`plans/development-history.md` preserves each development round and its user
feedback, superseded behavior, evidence and limits. `plans/agent-handoff.md`
gives future agents a reading order, architecture map, invariants, entry
points, validation commands, evidence boundaries and sensible future work.
`PLAN.md` is the master index and current-state summary.

This round was documentation-only: no application code, tests, tkos files,
external tools, Git metadata, agents, schedules, or behavior changed. No build
or test suite was rerun. Claims were checked against `AGENTS.md`, `Makefile`,
`Package.swift`, launch arguments, menu commands, language/query resources,
semantic indexer/cache/provisioning code, source limits, relevant plans and the
prior Paseo record. Local Markdown links and referenced repository paths were
checked. Thus **97 tests in 16 suites** remains a historical result of the
preceding implementation round, not a fresh documentation-round result.

## 2026-10-03 — Interactive large-file folding (current state)

Fixed the reported multi-second expand/collapse latency on untouched tkos
`modules/agent/ffi/src/app.rs` without changing the TextKit folding model. The
hot path was measured rather than inferred: every glyph and every hidden
control character performed a linear search through all active function ranges,
and every toggle invalidated glyph properties for the entire 4,880-line file.
That made even a seven-line function nearly as expensive as a 279-line one.

Folded ranges remain sorted/disjoint but now use binary-search membership in
the glyph delegate. `applyFoldAttributes` diffs the previous and next effective
ranges, returns immediately when a nested toggle cannot affect visible layout,
regenerates glyph properties only for the changed union, and invalidates layout
only from that point downstream. Render completion is still awaited in the
probe—work was not merely deferred. Canonical bytes, null-glyph compaction,
zero-advancement hidden newlines, visible-fragment gutter enumeration, exact
badges, source restoration, and default folds are unchanged.

Real-source rendered-completion timings on this machine (three expand/collapse
pairs each) changed as follows: large line-1453 function median about
0.52/0.33 s to 0.062/0.057 s; medium line-1734 function 0.34/0.31 s to
0.051/0.050 s; tiny line-1812 function 0.30/0.29 s to 0.048/0.047 s. The probe
uses the real 4,880-line file and forces `ensureLayout`, so values include the
downstream rendered layout, not only click dispatch. The user's observed UI
was slower than this stripped TextKit probe because syntax decoration and the
full app surface add work, but the eliminated whole-document glyph scan was the
dominant scaling defect.

Native CUA could not attach for the final pointer repetition: it listed the
running signed Radiology process but `getApp` returned `cgWindowNotFound` by
both display name and bundle identifier. The immediately preceding layout pass
had native screenshot evidence on this exact file; this performance pass relies
on the real-source AppKit rendered-completion probe and does not claim new
pointer timing evidence. Current validation and build results are recorded
below after the final gates. `make check`, **97 tests in 16 suites**, signed
`make build`, strict codesign verification, and packaged verification of all
eight grammars/31 query files pass. The real-source benchmark is opt-in with
`RADIOLOGY_REAL_FOLD_BENCHMARK=1 swift test --filter realAppFoldPerformanceProbe`
so an external tkos path and full-file AppKit layout do not destabilize ordinary
parallel test runs.

## 2026-10-03 — Correct large folded layout and salient size cues (current UI)

The previous faint 2-point meter/68-point gutter description immediately below
is historical and superseded. The shipping gutter is 104 points with separate
28-point disclosure, exact-count badge, and canonical line-number lanes. It
uses a 3-point secondary-label logarithmic meter (6–22 points) plus a neutral
9-point medium tabular count capsule. Fold layout uses visible TextKit fragments,
disjoint outermost ranges, null glyphs, and zero-advancement hidden newlines.
The real `app.rs` 1453→1734→1812→1829→1941→2062→2075 region is compact and
correct at normal and enlarged text sizes. The completed baseline before this
performance pass was 96 tests in 16 suites.

## 2026-10-03 — Collapsed-function size cues

Collapsed function headers now show a restrained two-point neutral meter below
the existing chevron. Width follows a capped logarithmic 4–18 point scale
(`log2(hidden lines + 1)`, capped at 256), making 2-, 20-, and 200-line bodies
visibly different without widening the gutter or reducing its 28-point
full-line hit target. Tooltip and gutter accessibility help provide the exact
“Collapsed function — N lines hidden” description. Expanded functions and
non-function folds show no meter; hidden nested function headers cannot stack a
cue on the surviving parent row.

Counts come only from canonical source line boundaries, independent of TextKit
glyph height, wrapping, font size, and viewport. Delimited bodies retain their
header row and count subsequent removed source rows; indentation-delimited
bodies count every captured row. The latter now anchor their fold affordance to
the preceding visible signature, fixing the prior Python/Kotlin possibility of
a control originating on a hidden first-body row. Tests cover CRLF, Unicode,
multiline signatures, indentation bodies, empty/one-line functions, the
2/20/200 progression, and the 256-line cap.

Native CUA on untouched `tkos/engine/rust/src/app_image.rs` showed short meters
for the tiny `image` methods, progressively longer meters for `section`,
`sources`, and `compatibility`, clean original line numbers, and no source
column shift. Clicking within the left side of the 28-point gutter expanded
`section`; clicking the same region re-collapsed it and restored only its size
meter. Two source-size increases preserved chevron/meter alignment and the
distinctions. Screenshots were captured for default, expanded, re-collapsed,
and enlarged-text states. CUA exposes no pointer-move primitive, so the native
hover tooltip itself was not held onscreen for screenshot evidence; its exact
registered string and accessibility summary are covered by implementation and
counting tests.

Post-decision swiftui-pro/macOS-design review found no additional accessibility,
layout, color, or rendering-ownership defect. `make check`, **95 tests in 16
suites**, and `make build` pass; strict deep signing and the minimal-environment
packaged check for all eight grammars/query roles pass. The first parallel full
test run hit the pre-existing asynchronous repository-switch expectation once;
that test passed immediately in isolation and the subsequent complete 95-test
run passed.

## 2026-10-03 — Double-click occurrence locks

An unmodified double-click now toggles a persistent, document-scoped occurrence
lock using the existing semantic-first and Tree-sitter function-local fallback
resolution. Multiple groups can remain locked while another symbol is selected,
whitespace is clicked, native word selection remains active, Find runs, or the
reader scrolls, folds, changes font, or changes appearance. Double-clicking any
occurrence of a locked group removes only that group and clears the transient
wash from the first click. Command-click definition navigation never toggles a
lock.

Pins retain canonical UTF-8 byte ranges and live in bounded repository-session
state keyed by file path plus source byte count and checksum. Revisiting an
unchanged file restores its pins; changed bytes invalidate them. Semantic IDs
remain authoritative, while equal range sets safely reconcile a cfg-inactive
syntactic pin if semantic data later arrives. Stable monotonically allocated
palette slots mean removing one pin does not recolor another; teal, amber,
violet, and rose fills cycle without limiting pin count. Separately tuned
light/dark translucency plus a 1.4-point stroke distinguishes locked groups
from the ordinary accent wash without changing text attributes or layout.

Regression tests cover two simultaneous pins, independent unpin, stable color
slots, per-file revisit, changed-source invalidation, syntax-to-semantic
reconciliation, Unicode/fold-safe drawing ownership, and the exact four-token
`android_log/message` fallback while transient-selecting another identifier and
then clearing on whitespace. Native CUA on the packaged app expanded untouched
`engine/rust/src/app_image.rs`, double-clicked the cfg-inactive local `message`,
and accessibility reported **1 pinned symbol group, 4 pinned occurrences**;
the light-appearance screenshot showed all four teal translucent fills with
outlined edges while the clicked word retained native blue selection. A single
click on `CString` left the four teal locks in place. Double-clicking `CString`
added an amber outlined group and accessibility reported **2 groups / 6
occurrences**. Double-clicking a different `message` occurrence removed only
the teal group, left the two amber `CString` occurrences visible, preserved
native word selection, and reported **1 group / 2 occurrences**. This is actual
pointer-event evidence on the packaged application, including independent
multi-pin removal rather than model-only coverage.

Post-decision swiftui-pro and macOS-design review found no additional data-flow,
accessibility, layout, or color-ownership issue. `make check`, **93 tests in 16
suites**, and `make build` pass. Strict deep code-sign verification passes, and
the packaged minimal-environment resource check loads all eight grammars and
all query roles. Native screenshots covered the dynamic palette in light
appearance; dark alpha selection is deterministic and tested through the same
appearance-aware drawing path, but this pass did not restart the app in dark
appearance because doing so would discard the document-session pins under test.

## 2026-10-03 — Cmd-K fuzzy file picker and cfg-inactive occurrence fix

Cmd-K now opens a compact native Go to File sheet backed only by repository file
discovery; Cmd-P remains an alias. Case/diacritic-insensitive ordered-subsequence
matching makes `engrs` find `engine-foo.rs`. Exact, prefix, contiguous, boundary,
gap, and filename-versus-path signals produce deterministic ranking without a
full per-keystroke sort. The best 100 remain visible with the true total and a
refinement hint. Filename/path hierarchy, focused typing, Up/Down selection,
Return, Escape, mouse activation, stale query/repository guards, empty states,
and source-focus restoration use native controls and the existing history-aware
open path. Details are in `plans/quick-file-picker.md`.

The reported real-source occurrence bug is fixed end to end. The cause was both
interaction and data coverage: double-click word selection bypassed the old
single-click callback, and host SCIP correctly omitted Android-only tokens in
`#[cfg(target_os = "android")] fn android_log`. Single- and double-click now
refresh decoration after AppKit selection. When SCIP does not cover all parsed
local occurrences, a drawing-only Tree-sitter fallback matches exact identifier
tokens inside the innermost function/closure, excluding strings, comments, and
other functions. It deliberately includes the `message` parameter and shadowing
local requested by the user, but never supplies semantic navigation or reference
targets.

Native CUA exercised the latest packaged app on untouched real tkos. Cmd-K
focused its field immediately, reported `Showing 100 of 6721 matches`, and query
`apimgrs` ranked `app_image.rs` first with secondary path `engine/rust/src` and
89 total matches; keyboard selection and Return opened a result and restored
source focus. Pointer activation of the selected `app_image.rs` row dismissed
the sheet, kept that file open, and returned focus to the source. In the exact screenshot case, CUA expanded `android_log`,
double-clicked the local-binding `message`, and the real source accessibility
state reported **4 occurrences highlighted** while the dynamic accent marks were
visibly present on the parameter and uses. Clicking whitespace removed the
state and all marks. This is actual pointer/source/parser/index integration on
`engine/rust/src/app_image.rs`, not fixture-only evidence.

Regression coverage includes fuzzy ranking/lifecycle bounds and the exact
cfg-gated Rust shape: parameter, shadowing binding, initializer use, and call use
are the four matches; a string, comment, and same spelling in another function
are excluded. `make check`, **89 tests in 15 suites**, and `make build` pass.
Strict deep code-sign verification passes, and the packaged minimal-environment
resource check loads all eight grammars and their query roles.

## 2026-10-03 — Semantic occurrence highlighting

An ordinary primary click on an indexed source occurrence now selects its exact
SCIP symbol identity and persistently decorates every occurrence of that identity
in the current document. The clicked occurrence uses a stronger system-accent
fill and stroke; definitions and other references use a restrained accent wash.
This is drawing-only TextKit presentation: canonical UTF-8 bytes, syntax
attributes, native selection/copy, Find, destination flashes, and Cmd-hover
temporary attributes remain independent. Clicking whitespace clears the set,
another symbol replaces it, and file/repository/index replacement clears stale
semantic state. Hidden fold glyphs are excluded from drawing, while expanding a
fold naturally reveals their still-valid ranges.

Selection is identity-based, not spelling-based. Regression coverage includes a
Rust shorthand-field collision where the field's definition/references are
selected but a same-spelling local is not; a known external symbol with no
repository definition; definition-plus-reference inclusion; UTF-8 byte ranges
containing emoji/accented text converted to UTF-16 only at the TextKit boundary;
whitespace clearing, file switching, and drawing ownership that does not mutate
text, selection, or temporary attributes. The suite now passes **83 tests in 14
suites** (baseline 79).

Native CUA attached to the packaged app on the real untouched tkos repository,
opened `engine/rust/src/app_image.rs`, confirmed the real **Index Partial** state,
the compact default-folded source, the visible **Collapse Functions** control,
and the semantic outline containing both `PreparedApp` declarations. Outline
activation navigated to `PreparedApp` with the process remaining responsive.
CUA exposes the entire TextKit source as one accessibility element, not individual
tokens, and this environment's Screen Recording capture remains denied
(`screencapture: could not create image from display`), so an actual coordinate
token click and visual pixel comparison could not be captured honestly. The
pointer path is nevertheless exercised at the `ReaderTextView.mouseDown` boundary
by the focused TextKit/model tests above; token-level screenshot evidence remains
the sole UI-validation limitation.

Validation: `make check`, `make test` (**83 tests in 14 suites**), and `make
build` pass. One pre-existing asynchronous repository-switch assertion flaked in
the first combined run and passed on the immediate complete rerun. Strict deep
code-sign verification passes, and the packaged minimal-environment resource
check loads all eight grammars and all query roles.

## 2026-10-03 — Real tkos Rust acceptance implemented and measured

Radiology's packaged app completed a cold, app-controlled semantic run over the
untouched `/Users/agentzero/codebase/tkos` repository. It selected all 11 Cargo
project directories (the discovery bound is now 32), emitted real rust-analyzer
indexes for **338 of 340 Rust files**, and preserved the real Cargo package
identities. Directory coverage: `engine/rust` 28/29, `tools/phone-provisioner`
1/1, `modules/agent/ffi` 71/71, `modules/agent/harness` 151/151,
`modules/game/rust` 3/3, `modules/imap/rust` 3/3, `modules/mls/rust` 11/11,
`modules/scene3d/rust` 3/3, `modules/spotify/rust` 5/5,
`modules/storage/rust` 2/2, and `modules/tkreplica/rust` 60/61. No Cargo
project returned zero documents or crashed. tkos remained Git-clean.

The engine result is deliberately **Partial / sourceOnlyNoDeps**, never
Current: Cargo cannot resolve `deno_core` because the repository's patched
vendor tree has not been prepared. Radiology now writes a project-specific,
nested rust-analyzer config using all real manifest features as cfg overrides,
captures stderr head and tail, persists capability/cargo-error provenance, and
reports the exact error (`failed to select a version for deno_core`). That
indexes the real `tk-js-runtime 0.1.0` crate and 28/29 files, including
`src/app_image.rs` (935 occurrences and 152 definitions). The sole missing
engine file, `src/snapshot_profiles_test.rs`, is reported as an orphan because
no crate root declares it. The one tkreplica omission is the shared
`test_support/fixture_paths.rs` loaded through several `#[path]` test modules;
its omission is reported conservatively as unknown rather than guessed.
Successful-but-important rust-analyzer warnings remain inspectable and bounded.
No synthetic manifest, copied source tree, LSP, or tkos modification ships.

An opt-in decode/normalize probe over the generated cache measured 389 total
mixed-language documents, 63,224 symbols, and 16,615 search entries. Against
the real `app_image.rs`, the `PreparedApp` use in `restore_app` resolves to one
in-repository real definition and Find References returns 11 occurrences.
Repeated progress publications now reuse the normalized index until inputs
change, avoiding the high CPU cost observed while generating the large tkos
cache. Cached degraded strategies restore as Partial, and an independent
strategy failure no longer discards successful semantic data.

During final launch validation, the app exposed a caught TextKit folding
warning while laying out the heavily folded file. Default fold state now
resolves the pending destination before the first glyph invalidation, and fold
discovery never touches a layout manager before the new buffer is installed;
regressions cover both ordering rules. AppKit still logs and ignores two
`NSRunStorage` range exceptions on this 511-line folded file. The process stays
alive and prior native inspection showed correct layout, but the console noise
remains a concrete TextKit limitation rather than being claimed fixed.
The final native CUA bridge repeatedly returned `cgWindowNotFound` for the
running foreground Radiology process, so direct tkos status-popover and
app-image click/Back interaction could not be visually re-verified in this
last build. Earlier in this same pass, native CUA did verify cross-file
definition/Back, references, Cmd-T, folded-target reveal, and destination
highlight on `/tmp/demo-crate`; tkos semantic coordinates are verified
headlessly as described above. This is the remaining UI-evidence limitation,
not an indexing limitation.

Validation: `make check` passes; **79 tests in 14 suites pass**; the real
rust-analyzer generation test passes; the tkos performance/semantic probe
passes; `make build` assembles and ad-hoc signs the app; strict codesign and the
packaged minimal-environment eight-grammar resource check pass.

## 2026-10-03 — Acceptance gate: real tkos Rust indexing

The user requires useful Rust indexing of `/Users/agentzero/codebase/tkos`
before moving on. A few uncovered files may be acceptable only with inspectable
missing paths and reasons. Crashes, no usable index, or missing most Rust files
in a substantial directory are hard failures. Previously documented engine
coverage of 3/15 files fails this gate; fixture/agent-copy success does not
satisfy it. The SCIP milestone remains incomplete until this is resolved.

Sent the updated gate to active Sol agent
`fd0b558f-487f-4faa-8a95-c579f6a95eed`: audit real tkos manifests/features and
warnings, fix sparse coverage and independent-strategy failure handling, expose
missing/failed files, and verify per-directory coverage plus actual semantic
navigation in important engine code. Preserve Fable's architecture; raise major
decisions to parent for Fable if necessary. No LSPs or invasive tkos edits.
Required evidence is real app-controlled tkos indexing and useful directory-level
coverage, not merely an indexer exit code or passing tests. Status updates remain
active.

## 2026-10-03 — Sol SCIP UI verification and refinement started

Fable agent `5e1e19a7-8874-4cc9-b13e-04c96161f4b0` finished and is idle.
Parent resumed GPT Sol agent `fd0b558f-487f-4faa-8a95-c579f6a95eed` through
Paseo for the user-authorized native UI testing and refinement phase, using
`plans/scip-ui-handoff.md`. Sol will test real app-generated data and all semantic
navigation/index lifecycle interactions, fix concrete defects, preserve Fable's
architecture, and report actual evidence and limitations. Baseline for this pass
is 76 tests in 14 suites. Native semantic UI validation is pending; the entire
milestone is not yet complete. Five-minute status updates remain active.

## 2026-10-03 — Fable first cut ready for Sol UI pass: app-owned SCIP indexing and semantic navigation

Radiology now generates and consumes SCIP indexes itself. On repository open,
`SemanticIndexService` inspects build files, selects indexer strategies
(rust-analyzer, scip-go, scip-typescript, scip-python, scip-clang), loads any
cached index immediately, compares HEAD/working-tree/build fingerprints, and
regenerates out of process in a dedicated process group with bounded,
file-backed diagnostics. Generated `index.scip` files and `index-metadata.json`
live under `~/Library/Caches/Radiology/repositories/<id>/`, never in the
repository. Missing tools are reported with an Install action that runs the
verified install command into `~/Library/Application Support/Radiology/tools/`
(rust-analyzer via `rustup component add`). States: No Index, Indexing,
Current, Possibly Stale, Failed, each inspectable from the footer popover with
indexer, version, command line, exit status, and output tails.

A hand-written protobuf reader decodes the official `scip.proto` (typed and
packed ranges, roles, kinds, relationships, unknown fields skipped). The
normalized `SemanticIndex` namespaces document-local symbols, follows
`is_definition` relationships, and ranks ⌘T entries. SCIP coordinates convert
to canonical bytes only against the loaded `SourceBuffer`, honoring UTF-8/16/32
position encodings and rejecting out-of-bounds data. Navigation: ⌘-hover
underline and pointing hand only for resolvable targets, ⌘-click, ⌃⌘J, context
menu, Find References grouped by file in the new Symbol inspector pane, ⌘T
symbol search, exact-byte Back via a recorded departure entry that preserves
pinned structural anchors. Architecture, decisions, support matrix and limits
are in `plans/scip-semantic-navigation.md`; the UI handoff is
`plans/scip-ui-handoff.md`.

Validation: `make check` passes; **76 tests in 14 suites pass** (56 baseline + 1 opt-in performance probe +
19 new: decoder and typed ranges, encodings, half-open caret resolution,
shorthand/local disambiguation, path validation, ranking, process exit/tail
capture, process-group cancellation, generate→cache→reload→stale→failure,
missing tools and supersession, nested-project prefixes, AppModel ⌘-click and
exact Back, references and ⌘T, repository switching). The real rust-analyzer
generation test passes (2.1 s). `make build` assembles and ad-hoc signs the
app; `codesign --verify --deep --strict` passes; the packaged
`--verify-resources` run loads all 8 grammars. The built app, launched on a
fresh Git copy of the fixture crate with no prebuilt data, generated
`rust-analyzer.scip` (2 documents) in 2.6 s with HEAD recorded, and a relaunch
reused the cache without regenerating. On a Git copy of `tkos/modules/agent` (222 Rust files in two Cargo
workspaces, `ffi` and `harness`), the app selected two rust-analyzer strategies
and generated both: `ffi` 71 of 71 files in 39.5 s (9.0 MB), `harness` 151 of
151 files in 31.8 s (19.8 MB), merged with project-directory prefixes and HEAD
`14bb8cb83b` recorded. A first attempt on a copy of `harness` alone failed
inside `cargo metadata` because the workspace references `../ffi`; that is the
Failed state doing its job, and the copy was widened. Decoding those two cached
files (28.8 MB) takes 0.34 s and normalizing 0.42 s in a debug build (222
documents, 40,256 symbols, 10,285 ⌘T entries); a ⌘T query over them takes
0.13 s off the main actor (`IndexPerformanceProbe`, opt-in via
`RADIOLOGY_INDEX_PROBE`).

At this first-cut checkpoint, only rust-analyzer was proven end to end; the Go,
TypeScript, Python, and C/C++ adapters had only verified commands. The later
Sol acceptance entry at the top supersedes this snapshot: Go and TypeScript
were exercised, native fixture UI was tested, and real tkos engine coverage
rose from the then-failing sparse result to 28/29 including `app_image.rs`.
Python still needs Python 3.10+ (this machine has 3.9.1), scip-clang still needs
`compile_commands.json` and a manual binary, and Kotlin, Java, and Swift have no
semantic indexer in this cut.

## 2026-10-03 — SCIP indexing and semantic navigation started

The user authorized the next milestone: app-owned SCIP generation, cache and
freshness tracking, out-of-process indexing/cancellation/diagnostics, normalized
semantic locations, cross-file definition navigation and exact Back/Forward,
references, Cmd-T symbol search, and genuine Cmd-hover affordances. No LSPs.

Paseo Fable 5.1 agent `5e1e19a7-8874-4cc9-b13e-04c96161f4b0`
(`Radiology: SCIP Architecture and Implementation`) is running in the root
workspace. Fable owns the architecture decisions and first-cut implementation,
including research of real tooling, supported-indexer decisions, meaningful
tests, and demonstration of actual index generation from a repository with no
prebuilt data. Baseline is 56 passing tests in 10 suites.

Required next phase: once Fable finishes its first cut, parent must resume GPT Sol
agent `fd0b558f-487f-4faa-8a95-c579f6a95eed` for native UI testing and refinement.
Fable is instructed to write `plans/scip-semantic-navigation.md` and a concrete
`plans/scip-ui-handoff.md`, and mark the first cut ready for Sol rather than claim
the full milestone complete. Sol should verify generation/status/freshness,
Cmd-hover/click, keyboard/context actions, exact Back, references, Cmd-T, reindex
and cancellation with real generated data, including folded targets and font
scaling. Preserve Fable's architectural decisions unless a proven defect needs
discussion. Implementation and semantic validation remain pending. Keep the
existing five-minute status heartbeat active and include this new phase in updates.

## 2026-10-03 — Function bodies collapse by default across all grammars

Newly loaded supported source now collapses Tree-sitter function bodies once,
after asynchronous structure arrives. Containers stay open so nested signatures
remain readable. A pending navigation is revealed after the defaults apply, and
ordinary SwiftUI updates, font changes, and resizing do not re-collapse a body
the user expanded. The source header now exposes an accessible **Collapse
Functions** control; `⌘⇧0` provides the same menu action. It re-adds function
folds without changing bytes or history, while the broader Fold to Definitions
command remains available.

Coverage asserts function folds for Swift, Rust, Go, Python, JavaScript/JSX,
TypeScript/TSX, Kotlin, and Kotlin scripts, plus default-once behavior, open
containers, manual expansion persistence, explicit re-collapse, and navigation
reveal ordering. `make check` passes; **56 tests in 10 suites pass**; `make
build` assembles and ad-hoc signs the app with all eight grammar bundles.

Native CUA inspection verified the real 511-line Rust `app_image.rs` opens as a
compact signature scan with clean original-number gaps, full `extern C`
signature visibility, and open impl containers. A gutter click expanded
`android_log`; the visible header control re-collapsed it. Clicking nested
`PreparedApp > image` still jumped to line 57 with breadcrumbs and destination
feedback. Representative Swift showed initializer/method bodies collapsed with
protocol/struct/class shapes open; TSX showed its block-bodied `ScanList` arrow
collapsed while the expression-bodied one-line `Badge` remained visible, as
documented. No type role changed.

## 2026-10-03 — Reliable outline activation and destination feedback

Fixed the follow-up outline-click failure. Row buttons now commit synchronously
on every activation, including an already-selected row; the list's preview path
recognizes the same committed target and cannot overwrite it. Navigation removes
all enclosing folds before jumping. A revision-guarded second main-actor layout
pass handles TextKit geometry that changes after unfolding, Fold to Definitions,
or font scaling, without allowing stale jumps or passive-history feedback.

Added a transient full-line destination highlight for pointer outline jumps. It
uses the dynamic system accent color at 18% opacity, leaves backing text and
attributes untouched, restarts on repeat clicks, cancels on any newer navigation
or file, fades after a short hold, and skips fading under Reduce Motion. No type
role or font changed.

Native CUA verification on the real 511-line `app_image.rs` covered: collapsing
the `PreparedApp` implementation with the gutter, clicking its hidden nested
`image` row and observing the parent unfold plus line-57 jump; clicking `image`
again and seeing the highlight restart; Fold to Definitions; and repeating at
two source-size increments. The first live stress pass exposed pre-collapse
TextKit geometry clamping the viewport below line 57; the guarded settling pass
fixed it, and the final view placed line 57 at the top with the breadcrumb and
footer agreeing. Existing nonoverlapping gutter labels and 28-point fold targets
remain intact.

Regression coverage now includes nested-parent reveal, repeat activation without
duplicate history, highlight restart/cleanup without text mutation, and stale
navigation cancellation behavior. `make check` passes; **54 tests in 10 suites
pass**; `make build` assembles and ad-hoc signs the app; strict code-signature
verification passes; and the packaged minimal-environment resource check loads
all 8 grammars and all four query roles.

## 2026-10-03 — Structural navigation completed and visually verified

Implemented the pre-SCIP structural-navigation slice in the active root package.
The outline now uses strict declaration containment and source order; native
selection previews with Up/Down and Return commits, while pointer activation
commits directly. Source scrolling updates the active declaration and path/scope
breadcrumbs without generating history. Committed structural anchors remain
exact across Back/Forward, while ordinary file visits retain per-file passive
positions. Programmatic jumps preserve focus, reveal a genuinely hidden target,
and suppress their one synchronization callback to avoid near-EOF retargeting.

Added Navigate > Fold to Definitions (`⌘⌥0`). It folds function bodies and leaf
types while keeping declaration containers open, signatures visible, and source
bytes/copy/find coordinates unchanged. Fixed the reported collapsed-gutter bug:
hidden/null glyph lines no longer draw all their numbers on one visible fragment.
Fold controls are now 11-point medium chevrons centered in a 28-point-wide,
full-line hit area with pointing-hand cursor and gutter accessibility help.

Native CUA permissions worked. On the real 511-line
`tkos/engine/rust/src/app_image.rs`, visually verified the hierarchical Rust
outline, path and `SnapshotBootstrapGlobals` breadcrumb, pointer outline jump,
Fold to Definitions, clean original-number gaps across multiple adjacent folds,
scrolling, expanding `hide` through the gutter, and the same layout after two
font-size increases. Light-mode contrast, unclipped source/gutter prefixes, and
three-pane geometry were inspected. Headless regressions cover Rust containment,
passive-versus-pinned history, definition folding, unfold-on-hidden-target, and
suppression of line labels for folded glyphs.

Validation: `make check` passes; **52 tests in 10 suites pass** (49 baseline plus
3 structural regressions); `make build` assembles and ad-hoc signs the app;
`codesign --verify --deep --strict` passes; a minimal-environment packaged
`--verify-resources` launch loads all 8 grammars and four query roles. SCIP/LSP
was not added. Concrete grammar folding limits are in
`plans/structural-navigation.md`.

## 2026-10-03 — Structural navigation and UI refinement handed to GPT Sol

At the user's request, stopped Fable agent `267f6c85-7da4-41ac-80f4-d78239343721`
and launched Paseo GPT-5.6 Sol agent `fd0b558f-487f-4faa-8a95-c579f6a95eed`
in the same root workspace. Fable's latest report covered orientation and 49 passing
baseline tests; it had not reported implementation delivery. Sol is instructed to
inspect actual workspace changes, complete and refine the five structural-navigation
features, and verify the native UI. The user reports granting Paseo's requested
permissions, so Sol will retry UI access. Implementation and UI validation remain
pending. SCIP stays deferred; five-minute status updates remain active.

## 2026-10-03 — Structural navigation delegated to Fable

Started Paseo agent `267f6c85-7da4-41ac-80f4-d78239343721`
(`Radiology: Structural Navigation`, `claude/claude-fable-5-1`) in the active root
workspace. Its authorized scope is hierarchical outlines, outline/source and keyboard
synchronization, Tree-sitter structural breadcrumbs, Fold to Definitions, and accurate
Back/Forward trails. SCIP is deferred. Implementation and validation are pending;
the agent is instructed to preserve all existing language support, document its work,
and report concrete limitations. The recurring five-minute status schedule remains active.

## 2026-10-03 — Rust, Go, Python, JavaScript/JSX, TypeScript/TSX, and Kotlin Tree-sitter support delivered

Extended the Tree-sitter slice from Swift alone to eight grammars in the active root
package. Swift behaviour is preserved. The inherited `repo/` copy is untouched, and no
Git repository, branch, commit, PR, or merge was created.

Delivered:

- Registered real native upstream grammars, resolved by SwiftPM and pinned to exact
  versions: `tree-sitter-rust` 0.24.2, `tree-sitter-go` 0.25.0, `tree-sitter-python`
  0.25.0, `tree-sitter-javascript` 0.25.0, `tree-sitter-typescript` 0.23.2 (both the
  `typescript` and `tsx` parsers), and `fwcd/tree-sitter-kotlin` 0.3.8, alongside the
  existing Swift grammar. Extensions: `.rs`, `.go`, `.py`/`.pyi`, `.js`/`.jsx`/`.mjs`/`.cjs`,
  `.ts`/`.mts`/`.cts`, `.tsx`, `.kt`/`.kts`, `.swift`. All grammars are MIT-licensed and
  report ABI 14–15, inside the 0.25 runtime's range.
- `.tsx` uses the dedicated TSX grammar and `.jsx` the JSX-capable JavaScript grammar,
  because the dialects are different languages rather than supersets.
- Replaced the per-language `SourceLanguage` protocol with a value-typed registry:
  one `SourceLanguage` record per grammar, extension lookup, and an ordered list of
  query directories. TSX composes `ecmascript` + `typescript` + `jsx` instead of
  duplicating the shared ECMAScript patterns.
- Moved queries out of Swift string literals into `Sources/Radiology/Queries/**.scm`,
  packaged as SwiftPM resources and read through `Bundle.module`. Wrote
  `highlights`/`folds`/`symbols`/`scopes` for every language against each grammar's
  `src/node-types.json`, informed by the upstream `queries/highlights.scm` of the same
  pinned version; each file records its source and licence.
- `SyntaxWorker` now caches compiled queries per grammar, evaluates `#eq?`/`#any-of?`/
  `#match?`-family predicates against canonical UTF-8 byte ranges, returns highlights in
  deterministic paint order, and resolves competing fold and symbol patterns by
  specificity. Parsers, trees, and queries stay actor-isolated; snapshots stay Sendable.
- `SyntaxSnapshot` carries the originating language; `RepositoryFile.language` and the
  outline's empty state derive from the registry, so there is one source of truth.
- Surfaced syntax failures that were previously stored but invisible: the source footer
  shows "Structure unavailable" (with the loader's message in its tooltip) or "Partial
  structure" for sources with parse errors, and the outline repeats the message.
- Extended `Theme.SyntaxColors` with constructor, namespace, tag, label, string-escape,
  and builtin-variable roles, all dynamic system colours. Added outline symbol icons for
  the new declaration kinds. No new type size or weight; no unrelated UI redesign.
- Made fold rendering delimiter-aware: brace-, bracket-, and quote-wrapped bodies keep
  their delimiters so a collapsed function still reads as `{}`, while indentation-delimited
  bodies (Python blocks, Kotlin and Swift `statements`) collapse whole instead of stranding
  their first character.
- Added `--file RELATIVE_PATH` and `--verify-resources` development launch arguments, and
  made `build.sh` fail if the query resources are absent from the assembled bundle.

Implementation findings:

- `tree-sitter-javascript` and `tree-sitter-python` publish SwiftPM manifests that probe
  for `src/scanner.c` with a path relative to the manifest process rather than the package,
  so their external scanners are never compiled and the grammars fail to link. Both
  scanners (and the three headers they include) are vendored byte-identically in
  `Sources/GrammarScanners`, with provenance and licences in `PROVENANCE.md` and the
  upstream-only `-Wshorten-64-to-32` warning suppressed at the target rather than in the
  vendored code. This is still upstream's bug at the pinned versions' HEAD.
- `tree-sitter-rust` and `tree-sitter-typescript` declare the pre-transfer
  `ChimeHQ/SwiftTreeSitter` while the others declare `tree-sitter/swift-tree-sitter`.
  SwiftPM prunes test-only dependencies of non-root packages, so the two identities never
  collide and resolution succeeds.
- SwiftTreeSitter's `QueryMatch.allowed(in:)` resolves predicate text through
  `Node.range`, which divides byte offsets by two because it assumes UTF-16 input.
  Radiology parses UTF-8, so predicates had to be evaluated against `node.byteRange`
  directly. `Predicate.evalulate(with:)` and `Predicate.captures(in:)` are public, which
  makes that straightforward.
- The TypeScript grammar's `class_declaration` names a `type_identifier` where JavaScript
  names an `identifier`, and JavaScript's `field_definition` is `public_field_definition`
  in TypeScript. Those two differences are the only ones across the node types the shared
  ECMAScript core needs, which is what makes the overlay composition safe.
- `Bundle.module` resolves inside the test target and inside the assembled `.app`, but a
  test's `Bundle.module` is the *test* bundle, so query-resource assertions have to go
  through `SyntaxQueryLoader`.
- Rust's `crate` is a named node, not an anonymous token; Kotlin's `jump_expression` spans
  the whole returned expression, so capturing it painted entire `when` blocks as keywords.
  Both were found by running queries against fixtures rather than by reading grammars.
- Several grammars have no delimiter-wrapped node for constructs that look foldable (Go
  interface bodies and grouped `const`/`var`, JSX elements). Those folds were removed
  rather than left to render as mangled fragments.

Validation performed:

- `make check` — passes, Swift 6 strict concurrency, no warnings after a clean
  `.build/out` rebuild.
- `make test` — **49 tests in 10 suites pass**, up from the 22-test baseline, which is
  retained in full. New coverage: query compilation for all 8 grammars; query-resource
  reachability and overlay concatenation; a diagnosable error for missing resources;
  per-language highlights/declarations/scopes/folds fixtures for Rust, Go, Python,
  JavaScript, JSX, TypeScript, TSX, Kotlin, and Kotlin scripts; JS-versus-JSX and
  TS-versus-TSX grammar routing (including that the TypeScript grammar rejects JSX and the
  TSX grammar rejects `<T>` casts); UTF-8 byte-range and UTF-16 round-trip checks over
  every fixture; astral-character capture ranges; malformed source for all ten file kinds;
  empty sources; extension classification for all 15 registered extensions; cross-language
  snapshot replacement and unsupported-file fallback; and delimiter-aware fold rendering.
- `make build` — assembles and ad-hoc signs `build/Radiology.app`; `codesign --verify`
  passes. The bundle contains the Radiology query bundle plus all eight grammar resource
  bundles, and `build.sh` verified 31 `.scm` files.
- Packaged-app resource load under a Finder-style launch: running
  `build/Radiology.app/Contents/MacOS/Radiology --verify-resources` under `env -i` with a
  minimal `PATH` reported all 8 grammars loading all 4 query roles, exit 0.
- Packaged-app GUI launch: `open -n build/Radiology.app --args --repository … --file …`
  under `env -i` for each of the nine language fixtures; the app stayed alive in every
  case and wrote no crash reports.
- Applied swiftui-pro before and after writing the code, macos-design for the colour and
  outline work, and typography-designer (which confirmed no new type role was needed —
  the existing body/callout roles cover the outline and footer).

Not validated, and stated plainly: **no visual inspection of the running UI was
performed.** Screen recording and UI-automation (`screencapture`, System Events) are both
denied to this environment, so there are no screenshots of the highlighted source,
outline, or fold markers for the new languages. The evidence above is process-level and
headless. The colour palette, outline icons, and fold-marker placement for the new
languages are unverified visually.

Remaining limits: symbols are syntactic, not semantic; folding is session-local; no
breadcrumbs, fold-all, or language injection; parses are whole-file with no cross-file
tree cache; Go interface bodies, Go grouped `const`/`var`, and JSX elements are not
foldable; Python and Kotlin folds that begin on a body line put the gutter marker on that
line. Next useful step is still SCIP definition/reference navigation on the same canonical
byte-coordinate contract, then filesystem-driven invalidation.

## 2026-10-03 — Major-language Tree-sitter support delegated through Paseo

Started **Radiology: Major-language Tree-sitter** with **claude/claude-opus-5**, as authorized by the user after provider discovery showed no Opus 5.5. Paseo confirmed agent `a3627f41-39ea-4082-bc06-fa1e365bc7e5` is running in the existing root workspace (`wks_f438c91353bec4ec`). This is a delegation record, not a completion claim.

Requested Rust, Go, Python, JavaScript/JSX, TypeScript/TSX, and Kotlin grammars with highlighting, outlines, scopes, and folding. The agent must preserve Swift and the existing byte-coordinate, asynchronous parsing, navigation, and TextKit contracts; retain the 22-test baseline; validate every language and bundled resources; apply required skills; and update the documentation with actual results and limitations. The nested `repo/` remains untouched and merges are prohibited.

Use the bundled `/Applications/Paseo.app/Contents/Resources/bin/paseo` CLI with this agent ID for follow-up. The earlier Swift implementation agent is finished and idle.

## 2026-10-02 — Swift Tree-sitter structure delivered

Completed the delegated Tree-sitter slice in the active root package; the inherited `repo/` copy remains untouched and no Git repository, branch, PR, or merge was created.

Delivered:

- Added the Tree-sitter 0.25 C runtime, official `SwiftTreeSitter` wrapper, and the Swift grammar's `0.7.3-with-generated-files` revision, locked in `Package.resolved`.
- Added a small `SourceLanguage` registry and real Swift Tree-sitter queries for syntax roles, declarations, lexical scopes, and multiline function/type/block/comment folds. No regex syntax substitute, SCIP, or LSP behavior was added.
- `SyntaxWorker` parses UTF-8 on an actor and returns Sendable byte-range snapshots. Source text publishes first; parsing follows asynchronously. Cancellation plus the source generation guard prevents a superseded parse from repainting the next file.
- TextKit highlighting converts captures through SourceBuffer only. Unsupported files and parser/query failures keep readable plain text. Malformed Swift can provide partial results with a parse-error flag.
- Added a native SwiftUI document-outline inspector with history-aware symbol navigation and a toolbar visibility control. Added gutter disclosure markers; folding suppresses structural interior glyphs without modifying the backing source or canonical positions.
- Kept new colors, font sizes, hit areas, indent, and inspector widths in Theme. The existing source layout-before-scroll and history coordinate paths were not replaced.
- Added `plans/tree-sitter.md` and updated the master index, architecture, design, build, roadmap, and README documentation.

Validation:

- `make check` passes under Swift 6 strict concurrency with no warnings.
- `make test` passes 22 tests across seven suites. New regressions cover Swift query captures and declarations/scopes/folds, Unicode byte ranges at the TextKit boundary, malformed and unsupported source fallback, stale parse races, and structural glyph folding. The original repository/search/navigation/layout tests remain green.
- `make build` assembles and ad-hoc signs `build/Radiology.app`; `codesign` validates the bundle and the dependency resource bundle is included.
- Live app inspection verified query-colored Swift, source beginning at column one, the native outline and its declarations, normal read-only selection surface, and the outline toolbar control.
- Applied swiftui-pro before implementation and in final review; used macos-design, typography-designer, SwiftPM, and AppKit interop guidance. The final review found no new SwiftUI API, data-flow, accessibility, or typography violations.

Remaining limits and next useful step: only Swift is registered; highlight coverage favors common constructs; symbols are syntactic, folding is session-local, and breadcrumbs/fold-all/parser caching are absent. Implement SCIP definition/reference navigation next, using the same canonical byte-coordinate contract. Multi-language grammars and filesystem-driven parse invalidation remain later work.

## 2026-10-03 — Large folded Rust layout and salient size cues

Fixed the blocking default-fold regression reproduced in the packaged app on untouched tkos `modules/agent/ffi/src/app.rs` around lines 1450–2220. Hidden newline glyphs had retained line-break behavior, overlapping fold ranges could replace the same glyph run twice, and the gutter enumerated canonical hidden line starts that TextKit aliases onto surviving fragments. Together those produced hundreds of blank rows, stacked/wrong line numbers, leaked nested markers, and mismatched signatures/braces.

- Hidden control characters now use TextKit zero advancement while retaining their original glyph properties plus `.null`; this compacts bodies without corrupting later glyph/character identity.
- Active folded ranges normalize to disjoint outermost ranges, source replacement is the only delegate-detachment boundary, and an update no longer regenerates the same large fold layout twice.
- The gutter now enumerates actual surviving line fragments and derives each original line number from its first visible glyph. It never measures hidden layout rows or mutates backing text.
- Fold size is deliberately more legible: the gutter widened from 68 to 104 points to provide separate control, count, and source-number lanes; a 3-point secondary-label meter grows logarithmically from 6–22 points; a neutral capsule shows the exact hidden-line count in 9-point medium tabular digits. Tooltip/accessibility retain the unabridged count. The 28-point fold hit area is unchanged.

Native CUA verification on the rebuilt app showed multiline `open` at 1453 compact to `{}` and then clean, distinct signatures/line numbers for `attach_session` 1734, `session_tools` 1812, `refresh_tool_definitions` 1829, `attach_worker` 1941, `complete_tool` 2062, and `request_observe` 2075. No blank body remained; no nested marker leaked; count badges `279`, `76`, `7`, `43`, `119`, and `11` were clearly distinguishable at the default scale. Two Cmd-plus steps preserved badge/number separation and source alignment at enlarged type. The test fixture exercises a 607-row multiline Rust function, nested closure text, enlarged then reduced fonts, expand/re-collapse, canonical Unicode coordinates, and asserts compact used layout plus zero-advancement hidden newlines. Targeted SourceScrollView tests pass without the former NSRunStorage warnings. Full validation: `make check`, 96 tests in 16 suites, signed `make build`, strict codesign verification, and packaged query verification for all eight grammars.

## 2026-10-02 — Tree-sitter implementation delegated through Paseo

Started **Radiology: Swift Tree-sitter** using Paseo's available **codex/gpt-5.6-sol** model in the existing local Radiology workspace (`wks_f438c91353bec4ec`). Agent ID: `d60a9896-8491-4d8c-b4da-979dcaa34b68`. The creation response confirmed it was running. Implementation is in progress; this entry does not claim completion.

The agent was instructed to read treesitter.plan.md, radiology.plan.md, AGENTS.md, PLAN.md, and PROGRESS.md; implement actual Swift parsing/highlighting/outline/folding; preserve the 16-test reader/search/history baseline and canonical byte coordinates; apply the required skills; run build/tests and inspect the live UI; and update the docs with results and limitations. No SCIP/LSP work or merges. The root workspace is shared with the delegated agent, and the nested repo/ remains untouched.

Paseo CLI is bundled at `/Applications/Paseo.app/Contents/Resources/bin/paseo`; it is not on this shell's PATH. Use `paseo inspect` or `paseo logs` with the agent ID via that binary for follow-up. The initial delegation used provider discovery because this bundled CLI exposes no named-profile command or profile configuration.

## 2026-10-02 — First working Radiology repository reader

Replaced the lorem-ipsum/table Starter scaffold with a native read-only code browser, following `radiology.plan.md`. The active implementation is the workspace root; `repo/` is an inherited duplicate and was left untouched. The root has no Git metadata and the duplicate's Git object store is incomplete. No commits, PRs, or merges were made.

Delivered milestone 1 and the core of milestone 3:

- Renamed SwiftPM executable, source/test directories, bundle identity, app name, and build targets to Radiology; retained the no-Xcode build workflow and raised the tools requirement to Swift 6.2.
- Repository/folder opening via native panel, recent repositories, Finder drops, and a `--repository PATH` development launch argument.
- Git root discovery plus NUL-delimited tracked/untracked file discovery with ignore handling; filesystem fallback, generated-directory exclusions, expandable file tree, and filename filter.
- Immutable SourceBuffer with canonical UTF-8 byte offsets, byte and UTF-16 line maps, centralized Unicode-safe conversion, and language classification. Binary/non-UTF-8 sources and files over 16 MB show local errors.
- AppKit/TextKit read-only source with native selection/copy, horizontal/vertical scrolling, current-line tint, separate line-number gutter, native in-file find, adjustable source text size, go-to-line, per-file line-position preservation, and browser-style navigation history.
- Cmd-P file picker and streaming ripgrep JSON search, with debounce, cancellation, literal/regex, case and include/exclude glob options, exact byte result locations, and a 5,000-result cap. Missing tools and invalid regexes show search-local errors.
- Actor-based repository, source, command, and search work; MainActor observable UI model; request generations prevent stale results. Tests use isolated preferences rather than polluting recent folders.
- Replaced PLAN.md, README.md, and architecture/design docs; added `plans/roadmap.md` and updated build documentation.

Implementation findings:

- The copied `.build` had empty files where SwiftPM needs directories, and scripts had lost executable bits. Moved the old generated cache to `/tmp/radiology-template-build-20261002`, restored executable permissions, and built fresh.
- macOS aliases `/var` and `/private/var` differently during URL enumeration. Relative filesystem enumeration avoids corrupting file paths; a regression test covers ordinary folders.
- A native ruler changed horizontal document coordinates and clipped source prefixes. The gutter now lives beside the scroll view with explicit clipping; visible text starts at column one.
- TextKit can clamp a new-file jump before it has sized the document. SourceScrollView ensures layout and document size before applying a pending location; an AppKit regression test checks the destination and prevents line drift on restoration.
- Finder launches have a minimal PATH. The built Info.plist records the build-time ripgrep installation; ToolLocator also checks PATH and standard Homebrew/cargo/system paths.
- Removed the template's App Sandbox entitlement for this local subprocess-based build. No distribution sandbox strategy or release was attempted.

Validation:

- Swift 6 strict-concurrency compile and ad-hoc signed app bundle succeed on macOS 26.6.2 / Swift 6.4, with no build warnings.
- Swift Testing: 16 tests across six suites cover Unicode/CRLF/empty and invalid sources, history branching, Git ignores and odd filenames, folder discovery, external symlink rejection, real ripgrep offsets/globs/no-match/errors/cancellation/limits, model navigation/opening races, and AppKit scrolling.
- Live app inspection through Computer Use verified repository opening, source/line-number rendering, Cmd-P, Cmd-Shift-F, ripgrep results, result-to-line jumps, Cmd-L, back/forward, source restoration, and native find/match navigation. Source readability and clipping were checked in screenshots.
- Applied swiftui-pro before implementation and again in the final review. Used macos-design and the local typography-designer skill; documented the type scale in `plans/design-system.md`. Also reviewed the available SwiftPM and AppKit interop skills.

Next work: Tree-sitter for Swift (accurate query-based highlighting, outline, breadcrumbs, folding), then SCIP loading/definition/reference navigation. Neither is faked in this delivery; source is plain text. Automatic filesystem watching, fuzzy ranking, pixel-exact/horizontal restoration, multi-language grammars, large-repository profiling, and macOS 14 runtime validation remain outstanding. Manual Cmd-R reload works today. No editing or LSPs.

---

Running log. Append an entry per meaningful change: what you did, what you
learned, what surprised you (`SWIFTUI-RULES.md` §10.1). Newest at the top.

> Once you've renamed the template, the entry below is history — leave it as
> the record of where the scaffold came from, and log your own work above it.

---

## 2026-06-28 — Metabolized learnings from the first app on this template

Folded `LEARNINGS.md` (general lessons from building the first app — an
outdoor-weather feature — on this scaffold) into the permanent docs, then
deleted the copy. Where each landed:

- `SWIFTUI-RULES.md` **§5.6** — `foregroundStyle` resolves innermost-wins (a
  tinted container can host a differently-colored inline child; the corollary
  bites the "explicit `.foregroundStyle(.primary)`" habit).
- `SWIFTUI-RULES.md` **§11 Swift Charts** (new) — overlaid lines need distinct
  `series:` or they merge into one path; the x-domain is the union of all
  plotted data, so clip overlays to the primary series' window.
- `SWIFTUI-RULES.md` **§12 Concurrency** (new) — a `@MainActor` type adopting a
  delegate protocol needs an isolated conformance (`@MainActor CLLocationManagerDelegate`).
- `plans/build-system.md` — new "Permissions & capabilities" section: usage
  prompts work in this ad-hoc-signed, no-Xcode bundle given the right
  `NS…UsageDescription` keys; the sandbox decides whether a `com.apple.security.*`
  entitlement is also needed; always design the denied path.

Appended §11/§12 rather than renumbering so the existing §9/§10 cross-references
in `PLAN.md` / `PROGRESS.md` stay valid.

## 2026-06-28 — Template scaffold (the "Starter" baseline)

Built the template this repo ships as:

- **Build system** lifted from the Casette app's SwiftPM-only setup and
  generalized: `Package.swift` (one exe + one test target, Swift 6 mode, no
  deps), `build.sh` (swift build → `.app` → codesign, ad-hoc fallback),
  `Makefile` (build/check/test/run/install + sign→notarize→staple→zip `dist`
  pipeline), `Resources/Info.plist`, sandboxed `Starter.entitlements`,
  `scripts/make-icon.swift` (pure-CoreGraphics doc-and-table glyph).
- **App**: `NavigationSplitView` with a `SidebarSection` enum driving a lorem
  reading column (`ReadingView`, measure-capped) and a native sortable `Table`
  (`DataTableView`) with a reusable `StatusBadge` and a footer count. State in
  one `@Observable @MainActor AppModel`; type/metrics centralized in `Theme`.
- **`scripts/rename.sh`** — the meta feature: `cp -R` then one command renames
  target, `.app`, bundle id, dirs, and file contents.
- **Tests**: swift-testing suite covering model load + status sort ordering.
- **Docs**: this file, `PLAN.md` (index, written for the fresh-copy workflow),
  `PROBLEMS.md`, and `plans/{architecture,build-system,design-system,renaming}.md`.

Gates run: `make check` ✓, `make test` ✓ (3 tests), `make build` ✓ (icon +
signed `.app`), live launch ✓ — both destinations render correctly, app stays
alive across a sidebar switch (no constraint crash).

Design work was driven through the macos-design, typography-designer, and
swiftui-pro skills per `CLAUDE.md`, before and after writing the views.
