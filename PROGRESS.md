# Progress

## 2026-10-11 — GitHub publication preparation (Codex)

User authorized pushing all accumulated work to GitHub. Confirmed authenticated
origin tqbf/radiology, private visibility, main as default branch, no open PRs,
and local HEAD/main matching origin/main at2e02ae3. Created
codex/reader-review-and-bookmarks. Scope includes source/tests/docs/resources and
supplied icon artwork; existing ignore rules retain generated build artifacts
and the inactive repo/ starter locally. The most recent whole-package gates are
269 tests/57 suites, check/signed build/strict signing/resources from the bookmark
round, with no implementation changes afterward. Preparing the full snapshot
and PR. The user subsequently explicitly authorized merging this batch to main,
superseding the earlier prohibition for this publication; AGENTS.md is retained.
Marked SCIP fixtures binary through .gitattributes after Git's text whitespace
check misclassified protobuf bytes; fixture contents unchanged.
plans/github-publication.md will receive the confirmed link and merge status.

## 2026-10-11 — Repo/PR bookmarks and third inspector pane (Codex)

Implemented user's bookmark request: Bookmarks beneath Definition/Outline with
its own scrolling and movable divider. ⌘D/header/menu toggles the genuine caret;
first ten ordered entries map ⌘0…⌘9. Native List.onMove persists order; Move Up/
Down/Move to Shortcut context menus offer an alternative, with removal/native
delete and Return/whole-row buttons. More than ten entries remain clickable.
Normal/Critical moved to ⌥⌘1/⌥⌘2, freeing plain numbers. Body-medium names,
caption path/line/revision and tabular shortcut hints keep existing hierarchy;
PR/Checkout header and faint orange tint show scope. Skills SwiftUI before/after,
macos-design and typography-designer applied. Contract: plans/bookmarks.md.

BookmarkScope uses canonical attached root + optional PR number, never snapshot
root/head SHA; checkout, each PR and another repo isolate persistence. Codable
UUID/relative path/revision/exact UTF-8 byte/label/digest/bounded line anchors live
in injected UserDefaults. BookmarkModel owns observable order/selection/error;
BookmarkResolver reads/relocates off MainActor, using actual open bytes if present.
Unique matching anchors relocate after insertions; ambiguous/edited/missing targets
report locally without moving source/history. Successful relocation updates
coordinates/digest while keeping UUID/order/slot. Semantic navigation still forces
After but now delegates to navigateFromCaret; bookmarks use that shared exact-
caret history/highlight path with their explicit revision. Scope/root/navigation/
caret/cancellation/existence guards reject stale jumps; opening cancels work.

The flat three-pane SwiftUI split failed the second native divider test (middle
stayed at its minimum). Replaced it with nested native two-pane splits; both
dividers now resize affected panes and preserve context state. Minimum heights
150/100/100. macOS14 cannot use enumerated sequence as ForEach RandomAccessCollection;
BookmarkListEntry provides stable UUID/slot data instead. The preexisting fake
GitHub constructor traps for duplicate SHA pairs; new tests initialize one pair
and then add the other PR number. No shared fixture or deployment target changed.

Fresh full suite **269 tests /57 suites** passes. Six new tests cover persistent
scope/order/deletion/slot promotion beyond ten, Unicode/CRLF exact positions,
changed/ambiguous anchors, malformed storage/invalid moves, real AppModel shortcut
handlers and exact Back, relaunch, updated anchors and toggling relocated caret,
disposable real-Git checkout/PR1/PR2/repository scopes and Before/After navigation,
missing files and cancellation on repo switch. Existing context/semantic/PR
refresh suites pass. Native inspector test exercises both nested dividers.
Six production-row/header renders at220/280/420 light/dark verify long text,
Before/After, ⌘0…⌘9, and two unassigned entries; build/bookmarks-review/*.png.
Physical drag, menus and keyboard activation remain unverified because this
session lacks desktop automation. No live interaction or user-reader restart.

make check/build, strict deep codesign, empty-env /tmp packaged resources
(8 grammars/37 queries/3 scripts), diff check pass. Signed executable built
**2026-10-11 14:41:15 CDT**. Logs /tmp/radiology-bookmarks-{check,integration,
tests,build}.log. PLAN/README/architecture/design/handoff/Context and Critical
shortcut docs updated. Local/uncommitted; no merges or tkos writes.

## 2026-10-11 — Stable caller pills and stop before repeated functions (Codex)

User reported repeated launch entries within a chain, then requested a palette
and one pill per caller, selected by a hash of method name and file. Added
CallTreePalette with12 dynamic system hues and portable FNV-1a64 over UTF-8
name/NUL/full relative file path. Swift Hasher is deliberately avoided because
its seed changes between launches. Same method/file repeats on separate branches
keep their hue; differing files contribute to identity. ReferenceCallerPill is
a native capsule Button containing name/file/call-site line, with12/6-point
padding, light/dark12%/24% fills and30%/50% borders. System primary/secondary
text and existing callout semibold/caption regular scales stay legible.
Increased contrast/Differentiate Without Color strengthen border75%; the latter
also uses1.5-point width. Branch arrows/deep-level markers sit outside; boundary
notes stay below. Capsule-wide navigation uses existing exact-caret Back.

Cycle diagnosis: old code stopped recursion but rendered the repeated function
as a terminal row. It now filters incoming callers before enqueueing, using
both semantic identities and canonical declaration positions. The preceding
row notes Recursive branch stopped; sibling branches and separate same-named
functions remain. Added mutual launch→relay→launch and distinct launch fixtures;
existing self-cycle assertion now requires one middle entry. New golden palette
assignments verify portable name/file/Unicode/field-separator hashing. Skills
swiftui-pro applied before/after, macos-design and typography-designer reviewed.
Contract: plans/caller-pills.md; traversal details in plans/reference-call-trees.md.

Full suite **263 tests /55 suites** passes. Actual production-row renders at
220/280/420 in light/dark verify capsules/readability and matching brown entry
pills on separate branches. Artifacts build/callers-pill-review/{light,dark}-*.png.
make check/build, strict deep codesign, empty-env /tmp resources (8 grammars,
37 queries,3 scripts), diff check pass. Signed executable **13:47:46 CDT**.
Logs /tmp/radiology-callers-pills-{targeted,tests,build,check}.log. Initial targeted
compile reports the preexisting unused ts variable warning in extraction tests;
no production warnings. User requested automation retry: this session returns
Module not found: @oai/sky, including after resetting the Node kernel and checking
available tools. No native mouse actions or reader restart; GUI checks remain
unverified. PLAN/README/design/handoff and traversal docs updated. Changes local,
uncommitted; no merge or tkos writes.

## 2026-10-11 — Reference caller trees and resizable inspector (Codex)

Implemented the user's retry: expanding a reference reveals source context and
its containing callable's incoming caller tree. ReferenceCallTreeWorker runs
off MainActor, linking callable definitions by exact SCIP identity and following
only parsed call-name sites resolved to that identity. Iterative depth-first
traversal preserves repeated ancestors on separate branches, marks recursive
calls per path, and has no fixed depth cutoff. Initial 256-row work budgets
continue with Trace more callers. Closures/non-call references/unindexed owners
are explicit boundaries; unreadable/stale/parse gaps show partial coverage.
Per-request file caches are bounded to48; graph state never crosses roots.
ContextModel starts work on disclosure, cancels on collapse/invalidation, caches
loaded trees within the reference identity, and rejects superseded completions.
Caller buttons commit the actual call site through existing semantic navigation.

Restored native VSplitView between Symbol/References and Definition/Outline,
with independent scrolling and150/100-point minimum pane heights. Removed the
outer ScrollView/fixed320-point list budgets. Existing title/section hierarchy,
exact-identity name deduplication and appearance-aware tints remain. Caller names
use existing callout monospace semibold; caption regular metadata/boundaries and
tabular line numbers remain quiet. Indentation caps at four levels, with explicit
level markers deeper; full path/depth are accessible. Applied swiftui-pro before
code decisions and again for final review, plus macos-design/typography-designer.
Current contract: plans/reference-call-trees.md, superseding prior layout docs.

Fresh full suite: **260 tests /54 suites**, all pass. Seven added tests cover
cross-file branching/shared ancestors, UTF-16/emoji/accented names, closures,
callbacks, nested functions, recursion, gaps/cancellation, lazy loading/caching/
reset during work, a270-level tree continued beyond256 rows, no navigation on
disclosure, caller/Back exact-caret restoration, and native divider resizing.
Actual ContextInspectorView/NSSplitView divider350→230 resizes both panes120
points without disturbing selection or disclosure. Native split decoration adds
an extra subview; the test correctly checks its two arrangedSubviews.
Six actual-row renders at220/280/420 light/dark pass; artifacts
build/callers-review/{light,dark}-*.png. Physical mouse drag, live List scrolling
and caller clicks remain unverified: Sky native pipe startup failed. No live app
or tkos interaction was attempted; user's reader was not restarted.

make check/build, strict deep codesign, empty-env /tmp packaged resource probe
(8 grammars/37 queries/3 scripts), and diff check pass. Signed executable built
**2026-10-11 13:31:01 CDT**. Logs /tmp/radiology-callers-{check,tests,integration,
layout,build}.log. PLAN, README, architecture/design/handoff and current Context
docs updated. Changes local/uncommitted; no merge.

## 2026-10-08 — Inspector typography and section cues (Codex)

User requested the inspector critique plus faint background cues. Replaced
forced vertical split/minimum panes with top-aligned scrolling sections, dominant
title3 semibold symbol/kind/file:line, caption section headings, primary snippet
text, and blue/teal/purple/neutral backgrounds at2.5% light/5.5% dark. Native
reference/outline lists receive bounded content budgets; short content no longer
pushes Definition down. Exact SCIP equality suppresses duplicate Definition
name; different caret targets remain identified. Location now includes file:line
or file:line/Here. ContextSymbolRow removed; InspectorSymbolSummary owns the hero.
UnderCaretDetailView now takes natural disclosure height; short/empty outline
states compact. References/outline keep native Lists with capped content budgets
(320 points), rather than exact measured intrinsic heights. Section titles/
dividers provide meaning without relying on color; decorative tints hidden from
accessibility. Model/navigation semantics retained. Required skills applied
before/after. Contract: plans/inspector-refinement.md.

Six actual-component renders at220/280/420 light/dark verify hierarchy/snippet
contrast/tints. Native PR758 admit_call: title/kind/file:145,4 references plus
definition occurrence, stacked Definition/location/Here, same name omitted,
no large inter-section gap. Reference selection stays145; Right disclosure
expands, Return→127, Cmd-[→145 exact. Screenshot
build/inspector-review/native-definition.jpeg. Different-target native check
unverified after selection/offscreen click failures; no claim for that case.

First full suite hit existing SourceScrollView highlight timer assertions (fade
alpha0.06 at deadline). Targeted test passed; unchanged full rerun passed all
**253 tests / 52 suites**. make check/build, strict deep codesign, empty-env /tmp
resources (8 grammars/37 queries/3 scripts), diff check pass. Built
**2026-10-08 22:59:05 CDT**. Logs /tmp/radiology-inspector-{check,build,tests,
tests-final,highlight-test}.log. Final separate review closed, no indexing active;
user's reader/tkos preserved. Current docs supersede fixed vertical-split layout.
Local/uncommitted; no merges/restarts.

## 2026-10-08 — Toolbar controls and Changes sidebar (Codex)

Implemented the user's dropdown Normal/Critical (default Normal), Before/After
beside it in the main toolbar, menu-only Source Files Only/Hide Tests. Removed
SourceFiltersMenu/SourceFilterToggles/SourceRevisionControls; new SourceModePicker
and SourceRevisionPicker, View Show All Files reset. Breadcrumb now has only
changed-block/collapse tools, freeing path width. Initial gates: 253 tests/52
suites, compile/build. Native PR758: Normal default, dropdown Critical, Cmd-1
Normal reset, Before/After and Source Files Only View menu26→30, caret1/After
preserved. Screenshot build/toolbar-controls-review/normal-after.jpeg.

User steered ongoing work to tighten Changes sidebar and replace Browse/segmented
selector with tabs. Added SidebarModeTabs native buttons, body semibold selected
label/accent underline/selected traits and keyboard Left/Right. ReviewChangeRow
and Status now separate files: body medium filename (selected semibold), caption
secondary paths/counts, tabular right-aligned min64-point count lane, M modified
glyph/circled plus additions, 8% selected tint plus2-point marker. Two-line rows
and native List selection retained. PR summary separates from list with12/8-point
spacing; duplicate file count moves to footer. Footer names Source only/Tests
hidden, with PR head SHA moved to Git-icon tooltip/accessibility.

Six actual-view renders at220/280/400 light/dark cover long names, varied counts,
modified/added/deleted/renamed/binary and selected row. Off-window List initially
deferred rows; final renderer uses production row views in a stack. Native PR758
verified tabs/no Browse, hierarchy/M/plus/right counts, selected Core.kt marker,
mouse mode switching, Source only Files5509/7019 and Changes26/30, both flags18/30.
Initial Right Arrow still reached source; explicit button focus fixed it. Final
Files click focuses tab, Right selects Search/focuses field; Changes restores list.
Removed duplicate mode accessibility label. Screenshots build/sidebar-review/
native-{combined,selected-core,source-only,both-filters,final-tabs}.jpeg.

Final gates: **253 tests / 52 suites**, make check/build, strict deep codesign,
empty-env /tmp resources (8 grammars/37 queries/3 scripts), diff check. Built
**2026-10-08 17:35:01 CDT**. Logs /tmp/radiology-sidebar-{check,tests,build}.log.
Required skills applied before/after; docs updated, current contract
plans/sidebar-refinement.md supersedes older filter icons/segmented mode/header
revision layout. Separate final review closed with no indexing active; user's
reader and tkos repository preserved. Local/uncommitted, no merges/restarts.

## 2026-10-08 — Source breadcrumb territory and more context (Codex)

User requested fixed right-aligned revision controls and preferential compaction
of intermediate paths in the existing second row. Added SourceRevisionControls
(194 points, native picker136 + changed-block50 + gap8); hidden visible Revision
label, status retained in help/accessibility. SourceBreadcrumbPath/Trail/Separator/
Overflow use ViewThatFits and a native full-path/declaration menu, keeping file
and final declaration legible with middle truncation only at extreme widths.
Semantic callout scale: regular secondary context, primary file, medium final
declaration. Required SwiftUI/macOS/type skills applied.

First header build passed 253 tests/52 suites, compile/build/sign/resources;
native isolated PR758/nomex.rs verified Before/After, Go to Line150's visible
file/Nomex/admit_call and the full-path/declaration menu. Screenshot
build/breadcrumb-review/native-pr758.jpeg. A sticky Repository menu held keyboard
input until its exposed Cancel accessibility action dismissed it. Test app
closed; user reader untouched.

User then steered the unfinished turn to retain a couple more entries when
possible. Granular alternatives drop far directories one by one, retain
declaration ancestors one by one, and use spare width for nearby directories.
The actual-view render probe caught nested ForEach IDs colliding inside
ViewThatFits; flattened options into uniquely identified SourceBreadcrumbVariant.
Ten production-view renders pass at1100/740/560/440/360 in light/dark: src + all
three declarations at740, file + two declarations at560, file/final at440,
complete final name at360, fixed controls throughout. make check passes.
Final native review at the same window size retains three extra nearby
directories: crates/harness-core/src/nomex.rs/Nomex/admit_call. Initial file
opening and Go to Line150 exercise zero-to-two declaration changes without the
ID collision. Screenshot build/breadcrumb-review/native-more-context-pr758.jpeg.
No indexing active at shutdown; separate review app closed, user's process kept.
Physical resize not attempted; actual-view renders cover narrow/light/dark.

Final gates: **253 tests / 52 suites**, make check/build, strict deep codesign,
empty-env /tmp bundled resources (8 grammars/37 queries/3 scripts), diff check.
Built **2026-10-08 17:02:10 CDT**. Logs /tmp/radiology-breadcrumb-{check,tests,
build}.log. Required skills reapplied in final review. PLAN/README/design/
navigation/handoff updated; contract plans/source-breadcrumbs.md. Artifacts and
renderer live in ignored build/. Changes local/uncommitted, no merges/restarts.

## 2026-10-08 — Remember the last repository and PR (Codex)

User requested last-PR persistence across relaunch. Added ReaderSession and
ReaderSessionStore: JSON Data in the injected UserDefaults, absolute attached
checkout path and optional positive PR number. AppModel persists confirmed
repository/PR opens; Exit PR explicitly records local checkout. Failed/cancelled
PR choices keep the last confirmed record. The window task now runs a one-time
launch routine: CLI intent/manual repository choice wins; ordinary launch
prepares the remembered checkout without saving temporary local mode, then
opens the PR through existing fresh metadata/worktree/indexing. Cancellation and
generation guards prevent stale restoration or CLI file navigation. PR-number
sheet defaults to the remembered PR after a failed restore.

Seven lifecycle tests pass with disposable Git, fake GitHub, isolated preferences
and separate models. They cover real PR preparation/restoration, attached root,
fresh metadata, exit/local, CLI/file overrides, failure/retry, failed/cancelled
choices, newer repository intent, startup replay, missing folders and bad data.
Initial tests exposed directory-URL equality affecting temporary-save suppression;
fixed with an explicit restoration marker and directory URL canonicalization.
A duplicate-SHA-pair fake-client fixture initialization was corrected as well.

Native separate-instance acceptance passed: tkos #758 opened with arguments,
review-only indexing cancelled, app quit, relaunched with no arguments. New PID
without arguments restored #758/Changes with fresh head 4106d3606a…. Screenshot
build/session-review/restored-pr758.jpeg. Review-only indexing cancelled again
and test app closed. Read current user UI/recent root to confirm tkos #758;
seeded that session into the real app's absent preference so its first upgraded
launch restores the review. User reader process and repository bytes untouched.

Final gates: **253 tests / 52 suites**, make check/build, strict deep codesign,
empty-env /tmp bundled resources (8 grammars/37 queries/3 scripts), diff check.
Built **2026-10-08 16:36:48 CDT**. Logs /tmp/radiology-session-{tests,full-tests,
check,build}.log. Applied swiftui-pro before/after; no type or UI surface changes.
PLAN/README/architecture/handoff and plans/session-restoration.md updated.
Changes local/uncommitted; no merge or user-reader restart.

## 2026-10-08 — Compact gutter and sparse numbering (Codex)

User steered the active toolbar task: gutter looked too wide; number only every
fifth line and the cursor line. Gutter width had not changed in the toolbar work
(104 points already committed). Now 72 points, 20-point disclosure lane, 6-point inset.
Native monospaced UI numbers 11pt regular/secondary, caret medium/primary,
independent of source zoom. Caret line derives directly from native selection
through SourceBuffer; removed duplicate stored gutter currentLine updates.
Visible glyphs/wrapped-line de-dup stay; PR bars/folds/test markers draw without
requiring numbered rows. Count badges fit spare width or retain exact counts
in tooltip/accessibility; function meter now fits the 20-point lane (6–16 points).

Both native NSView/TextKit bitmap-draw tests pass: initial/fifth labels, moving
caret 7, passive scroll preservation/offscreen clearing, folded line 10 exclusion,
expansion/canonical restoration with caret 18. Initial harness failures came from
an unspecified native selection and a document shorter than its scroll viewport;
fixed harness conditions, without loosening sparse-number expectations.

Live native PR758 review: Go to Line7 shows7 beside10/15/20/25/30/35; Down changes
only the non-fifth label to8 and clears7. The compact width/source type were
observed. Screenshots: build/toolbar-review/compact-gutter-caret7.jpeg and
compact-gutter-caret8.jpeg. Review app had a separate identity/preferences;
the user's reader was untouched. Physical folded-count/dark-mode/very-large-digit
acceptance remains manual; bitmap tests cover canonical folded/scroll behavior.

Final combined gates: **246 tests / 51 suites**, make check/build, strict deep
codesign, empty-env /tmp packaged resources (8 grammars/37 queries/3 scripts),
diff check. Signed **2026-10-08 16:10:23 CDT**. Logs:
/tmp/radiology-gutter-tests.log, /tmp/radiology-reader-ui-tests.log,
/tmp/radiology-reader-ui-build.log. Applied required skills before/after review.
README/design/navigation/handoff/index docs updated; changes local/uncommitted.
Scope: plans/source-gutter.md; toolbar task completed below.

## 2026-10-08 — Toolbar grouping (Codex)

User requested the attached toolbar critique: three groups, repository dropdown
owns Open Repository, PR dropdown owns Exit PR, visibly labeled PR selector,
and no duplicate PR title. Extracted native ReaderToolbar + RepositoryMenu,
SourceFiltersMenu, SourceSearchMenu and conditional title-item suppression.
Navigation/sidebar/history, PR context/icon refresh, and Normal/Critical +
filter/search/Context use existing actions/bindings; left SidebarCommands added,
right inspector recovery preserved. Full title remains in Changes/menu/help;
Before/After and changed-block controls stay in source header. Explicit PR
titleAndIcon fixes the prior icon-only upward-arrow label.

Applied swiftui-pro, macos-design, typography-designer and swiftui-patterns.
Native SF body/regular, semibold repo identity, system controls/materials. Native
computer-use review caught primaryAction tools over the sidebar and duplicate
automatic sidebar control. Moved toolbar/title modifiers into ReaderDetail and
removed default sidebar items inside both split columns. Real review now shows
one navigation toggle, repo/name, #758/refresh, Normal/Critical and trailing
filter/search/Context; no duplicate PR title or ordinary-width overflow.

Verified repository Open/Open Recent; PR first-level Exit/active number outside
recent25/refresh commands; related search actions. Toolbar Source Files Only
changed navigator state and Changes counts together. Left toggle collapsed the
sidebar; Ctrl-Cmd-S restored it with caret8 unchanged. Physically activated Exit
PR and confirmed selector Pull Request, Files/local checkout, refresh removed.
Native resize drag failed -10005:noWindowsAvailable for bundle id and full path;
state recovery worked, then resizing was stopped. Narrow acceptance unverified.
No user process interaction/restart. Canceled review-only indexing and closed
only review identity org.sockpuppet.radiology.toolbar-review. Same final246-test/
signed gates above. Full scope/screenshots: plans/toolbar-layout.md. No new tests
solely for reversible toolbar layout/menu edits.

## 2026-10-08 — Kotlin workspace links and complete build inputs (Codex)

User's PR758 screenshot reports scip-kotlin failed before compilation:
the file harness-development could not be opened. The tracked path
.agents/skills/harness-development is a directory symlink to
../../.claude/skills/harness-development. The copier materialized its directory,
then tried Data(contentsOf:) on the directory. Earlier manual compiler probes
skipped these directory links and did not validate this production preparation.

Internal file/directory/dangling links now rebase into the disposable copy and
use link-text hashes, including post-build kind/destination verification. Original
Git link bytes still verify snapshot identity. Literal destination
resolution also fixes the pinned tree's dangling external AGENTS.md link;
external Markdown link bytes are preserved without opening the target. Inputs
from the complete snapshot blob inventory include tracked vendor/build paths
omitted by the file browser. Git working-tree discovery similarly expands
compiler input fingerprints/digests, preserving cache invalidation for excluded
dependencies. Source publication still uses the browser's source inventory.

The complete real PR758 SemanticIndexService probe passed in **178.684s**:
repository listing, actual factory/installed adapter/bundled runner, compilation,
post-build byte checks, source filtering, cache metadata and workspace cleanup.
It publishes **2,088 source documents**, with real addSecrecyTag definition and
**18 references in 4 files**, no unreadable/unmapped refs. Kotlin outcome is
Generated with honest partialBuild coverage, rather than the reported Failed
preparation. Cache/probe are temporary; pinned head tree is read-only. No
handwritten-copy bypass this time. Initial full-service attempt exposed a second
dangling AGENTS.md resolution failure; corrected and covered by the regression.

Regression tests cover relative/absolute directory links, internal file links,
dangling Markdown/internal links, original checkout immutability, link/input
tampering, and copying tracked dependencies excluded by the browser. The actual
Git working-tree service test changes only a vendor input and proves regeneration,
rather than a false current cache. Focused **6 tests** and full **244 tests / 50
suites** pass; make check/build, strict deep codesign, empty-env packaged resources
(8 grammars/37 query files/3 scripts) and diff check pass. Signed
**2026-10-08 01:10:35 CDT**. Logs: /tmp/radiology-kotlin-service-probe.log,
/tmp/radiology-kotlin-directory-tests.log, /tmp/radiology-kotlin-link-tests.log,
/tmp/radiology-kotlin-link-build.log. Attached tkos Git status unchanged.

Applied swiftui-pro before/after review; actor/generation/cancellation boundaries
retained. No UI/type changes, user-app interaction or restart, commits/pushes, or
attached-checkout builds. Relaunch the new bundle and reopen PR758 to retry
Kotlin automatically. Partial coverage can remain for unavailable sources/build
variants. Updated PLAN/handoff and plans/kotlin-semantic-indexing.md; earlier
manual compiler evidence above/below does not replace this production-path proof.

## 2026-10-07 — Kotlin semantics in PR After (Codex)

User reported references and caret symbol state failing in PR mode. Screenshot
shows tkos PR #758 After, Kotlin Contacts source, and File not indexed. Root
cause for that example: registry has no Kotlin/JVM indexer; syntax declaration
tracking exists but semantic under-caret/definitions/references do not. User
explicitly selected Add Kotlin semantic support.

Added ScipKotlinIndexer, managed compiler-tool installation and bundled Gradle/
runner scripts. The pinned source `9f288dd339c7e9fc257a7b21714d9a402fd4d837`
supports Kotlin2.4.20; installed CLI reports `0.13.1-radiology-9f288dd339c7`.
AGP9 needs current compilerOptions and task discovery after projectsEvaluated:
ordinary afterEvaluate could report success without compiling Android sources.
Builds copy genuine inputs to a disposable index-cache workspace, preserve
paths/bytes/modes, reject unsafe links/traversal/stale inputs, and verify source
hashes again after compilation. No fake manifests or guessed symbol edges.
Successful compiler shards survive independent failures as persisted Partial.
Generation/cache/reuse exclude generated documents outside the reader snapshot.
Compiler data exposed a UTF-16-column/UTF-8-file mismatch: adapter defaultEncoding
now reaches SemanticIndex.Input on all three loading paths; explicit document
encoding wins. Existing Context, reference commits, definition and exact Back
use those identities. Before remains syntax-only; semantic destinations After.

Actual PR758 head `5d2ffdd2976c62a220118e30780edfe8fb6f2120`, compiled in
/private/tmp/radiology-kotlin-pr758 on AGP9.4.1/Kotlin2.4.20/Gradle9.7.1/JDK17.
Targeted Contacts/dependencies/tests: success, 112 compiler documents. Broader build:
2m03s, 1,276 Gradle tasks, 2,379 documents; installRustAndroidTarget/installUniffiBindgen
failed in the manual shell environment, so coverage is Partial. Read-only real
probe maps 1,355 Contacts occurrences; line 141 addSecrecyTag resolves to
core/src/main/kotlin/inc/tk/os/module/SecrecyCtx.kt:18, with 18 references in 4 files,
zero unreadable reference files/unmapped refs. One upstream generated-constructor
range stays unmapped; no ordinary call token omission is allowed by the probe.
All 10,394 copied tracked inputs are unchanged by compilation; attached tkos Git
status unchanged between checks. No build was run in the attached checkout.

A 4,119-byte actual Kotlin compiler fixture tests overloads, same-spelled unrelated
functions and emoji/accent offsets. PR tests drive native text-selection callbacks
on a changed call line through Context, Find References, definition/reference
commits, forced After despite Before preference, passive-scroll departure and
exact Back, Before clearing/After mapping and metadata-only refresh. Cache/reuse
tests retain UTF-16/Partial/inventory boundaries; isolation tests reject changes.

Gates: **241 tests / 50 suites**, make check/build, strict deep codesign,
env-i /tmp packaged verification (8 grammars/37 query files/3 indexing scripts),
diff check. Signed **2026-10-07 18:36:00 PDT**. Initial suite run during Gradle
hit an existing 5-second process deadline at 5.62s; idle full runs passed without
weakening it. Installed tool/version and actual compiler probes pass.
Applied swiftui-pro before/after, macos-design and typography-designer; the new
Partial explanation uses existing SF Pro callout regular/secondary metadata.

No physical UI launch, pointer navigation or screenshot recheck; user app left
running. Relaunch signed bundle to use new registry, then Kotlin index generation
runs automatically. Other compiler versions/scripts/non-JVM targets unclaimed.
Native setup failures and missing files stay inspectable; see exact contract,
logs and manual PR758 acceptance in plans/kotlin-semantic-indexing.md. README,
PLAN, SCIP support matrix, build/handoff docs updated. All changes local and
uncommitted; pre-existing work and the earlier inspector recovery preserved.

## 2026-10-07 — Restore Context after dragging it closed (Codex)

The right Context pane is a native SwiftUI inspector: dragging past its
collapse threshold hides it completely. Recovery previously depended on an
invariant "Toggle Context" toolbar label, disabled without a source file and
potentially in toolbar overflow at narrow widths. There was no menu or keyboard
recovery command.

RootView now publishes its existing presentation binding at scene scope via
an `@Entry` FocusedValues property in UI/ContextInspectorFocus.swift. The View
menu consumes the same binding with `@FocusedBinding`, offers Show/Hide Context
Inspector and ⌥⌘I, and works independently of source availability. The toolbar
has matching Show/Hide labels, shortcut help, and no source-dependent disabling.
Scene scope keeps recovery available across controls and while the inspector
is collapsed. The existing ⌃⌘I Reindex binding is preserved. Native collapse
and 220/280/420-point inspector sizing remain.

Applied local swiftui-pro before and after implementation and macos-design
layout/interaction guidance. The post-review replaced a manually declared focus
key with modern `@Entry`; no new type styles were set. Required skills were
found in /Users/tqbf/.claude/skills. Used swiftpm-macos for validation.

Validation: make check, **234 tests / 47 suites**, make build (swiftbuild),
strict deep codesign, empty-environment packaged-resource verification (all
eight grammars/calls queries), and git diff --check passed. The final @Entry
implementation compiled in both tests and the packaged build. Signed binary
**2026-10-07 17:47:35 PDT**. Logs: /tmp/radiology-inspector-tests.log and
/tmp/radiology-inspector-build.log. No new tests for this small
command/presentation change.
Physical divider drag, View-menu action, keyboard restoration, and narrow-window
toolbar behavior remain unverified. No user app was restarted or operated.
Exact acceptance steps and implementation contract: plans/context-sidebar.md.
README shortcuts and PLAN current state updated. Changes remain local; all
pre-existing work was preserved.

## 2026-10-06 — Refresh active PR without leaving review (GPT Sol)

Visible native Refresh PR beside selector/Exit PR, mirrored in PR menu/command
menu. One ⌘R binding routes to active-PR refresh; outside PR it remains repository
reload. Refresh List is separate. Button disables/coalesces while fetching, with
Refreshing… label/subtitle. Fresh gh metadata and merge base are always queried.
Same head AND base updates summary/recent row only: reader/history/folds/pins/
index stay. Changed base (even same head) follows the actual snapshot-update path.

Old reader stays usable until candidate worktree/listing/source/mapping succeeds.
Active and candidate worktree leases prevent eviction, including tested limit1
failure/cancellation. Failure keeps old state; native alert retry retains refresh
intent. Exit/cancel/differentPR/repository switch drop stale completion. An atomic
prepared swap clears SHA-obsolete history/semantic/hunk generations, keeping
latest commit-time reader and options. Pending source loads are awaited/rechecked.
Exact byte equality preserves caret/viewport offsets and only that document's
pins; otherwise Git blob hunks map lines (columns retained only on byte-equal
mapped lines). Proven rename deltas restore paths; unavailable revision switches
with notice; missing file falls to Changes with quiet reason. No spelling guesses.
Mode/font/filters/directory expansion/attached-root marks remain. Before syntax-only;
After indexes use existing whole-repository provenance/revision caches. Refreshed
viewport uses existing restoration, and subsequent navigation clears it.

Actual gates: **234 tests / 47 suites**, make check/build swiftbuild, strict deep
codesign, env-i /tmp eight-grammar/all-calls resources, clean diff check. Signed
binary **2026-10-06 20:52:31 PDT**. Seven refresh regressions use FakeGitHub plus
real temporary Git objects/worktrees: metadata no-op/coalesced command routing,
latest caret/viewport/options, changed-base Before and deletion, network/source
failure + refresh retry, limit1 canceled candidate, pending revision load, proven
rename/exact pin bytes/missing fallback, stale cancel/PR/repository/Exit. Attached
fixture checkout status remains unchanged. First failing wait was /var vs
/private/var test-path comparison, fixed by normalizing aliases.

No native launch/attachment: repeated old-reader selection makes further attempts
impractical under user's constraint. No visual/real-GitHub refresh claim; existing
UI gaps remain. Exact manual check and logs in plans/pull-request-ui-review.md.
No tkos/pin/mark/user-reader/GitHub/branch writes or commits/pushes; RADIO preserved.

## 2026-10-06 — PR defaults open changed functions/blocks (GPT Sol)

PR files/revisions now initially expand ordinary folds intersecting changed
ranges or containing empty-side hunk points, including enclosing ancestors.
Signature-only edits open the owning body via whole function/closure scopes;
Rust attached attributes and Python decorated definitions have separate parsed
header ownership, leaving lexical/call/semantic scopes unchanged. Sibling
closures and unchanged functions keep their normal defaults. Added/removed
functions use the actual After/Before ranges. An EOF point inside an unfinished
or indentation body can open it; a boundary after a closed braced function does
not implicate that unrelated neighbor. No invented line highlights.

One-time application waits for matching syntax and hunks in either async order,
keyed by review/path/revision/content. Manual fold choices and bulk commands
while diff is pending win; recollapse is not forced open by later updates.
Fresh coordinators adopt incoming command counters, avoiding replay of an old
Collapse/Fold to Definitions from another file. New loaded documents/revisions
reset default application; index/theme/font/filter/caret updates do not. Explicit
Hide Tests stays in force; normal fold expansion does not reveal test regions.

Fold state changes precede one combined layout, not model navigation. Late
layout preserves the visible source row/selection, cancels obsolete navigation
layout/position markers, suppresses restoration callbacks, and yields to a
newer explicit jump. Normal local fold defaults remain. No new control/toggle.

Actual gates: **227 tests / 46 suites**, check/build swiftbuild, strict deep
codesign, env-i /tmp eight-grammar/all-calls resources, clean diff check. Signed
binary **2026-10-06 14:47:45 PDT**. Native coordinator/parser/component regressions
cover async orders, nested/header/annotation/closure ownership, manual choices,
old/new bulk commands, new/stale identity/revision, empty sides/EOF/added/deleted,
Hide Tests, viewport/selection preservation, newer-jump priority and obsolete
marker then real scroll reporting actual viewport with unchanged caret line.

No app/UI launch or attachment this round: repeated older-reader selection made
another attempt impractical under user's bounded-tooling preference. No live
acceptance or new screenshots; prior gaps remain. Real PR anchors are manual,
not claimed new backend/GUI runs. Files and exact checks in
plans/pull-request-ui-review.md. User reader/pins/marks/tkos untouched; RADIO.png,
inactive repo/ and all prior work preserved. No branch/GitHub/commit/push changes.

## 2026-10-06 — Previous/next changed-block source controls (GPT Sol)

PR source header now has compact native up/down buttons beside Before/After,
with accessible Previous/Next Changed Block names and ⌥⌘↑/↓ tooltips. Existing
Navigate bindings remain; model-derived per-direction availability is shared by
menu and buttons. Long breadcrumbs/status horizontally scroll in a constrained
header, reserving fixed-size revision/navigation controls. No new sidebar/counter.

Distinct hunks are navigated in the exact current revision/path/content. Inside
a block, skip to adjacent block; in an unchanged gap, choose closest block in
direction; at ends, no wrap. Empty-side pure-add/delete anchors remain reachable,
including EOF without a final newline, without invented line washes. Caret at
EOF of an unterminated changed line counts inside that block; trailing empty
newline line is outside. Availability observes genuine caret revision (including
same-line changes), not passive scroll. Explicit jumps save exact departure
before navigate, reveal existing folds/test regions, highlight and focus source;
Back returns exact caret/revision even after passive scrolling.

Actual gates: **220 tests / 45 suites**, make check/build swiftbuild, strict deep
codesign, env-i /tmp resources (8 grammars/all calls), clean diff check. Signed
binary **2026-10-06 14:22:51 PDT**. Multi-hunk gaps/inside/bounds, Before/After,
empty-side EOF, unterminated EOF caret, stale identity/revision, binary/pending,
Observation invalidation and exact Back/test-region reveal regressions pass.

Native attachment plus one full-path recovery selected user's older #753 app.rs
reader instead of fresh snapshot_policy.rs instance. Stopped without actions or
screenshots; closed only review PID 49593, preserved user PID 33005. Live header,
narrow layout and pointer/keyboard behavior remain manual; prior UI limits remain.
No dataset/marks/pins/GitHub/branch changes or commits/pushes. Evidence/manual
steps: plans/pull-request-ui-review.md.

## 2026-10-05 — PR Changes respects source filters (GPT Sol)

User superseded the previous Files-only sidebar scope. Changes now uses shared
SourceFilters.includes for both Source Files Only and Hide Tests, preserving PR
order and full canonical review.changes. Deleted files use available Before
path; renames/copies remain when either available Before/After path passes both
active filters. Markdown additions/modifications disappear with Source Only;
source changes survive extension/source-set moves without inferred semantics.

Changes reuses compact filter toggles, shows visible-of-total changed-file counts
and visible text-file diff totals (binary counts unavailable). Filtered-empty
has No Changes to Show with Show All Files; genuinely empty remains No Changed
Files. Selection sync is limited to visible rows; filtering/current-file sync
does not reopen or navigate. Excluded current file/caret/history/revision stays.
Changes footer counts changes, not contradictory repository-tree files.

Actual gates: check, **216 tests / 44 suites**, swiftbuild signed build, strict
deep codesign, env-i /tmp resources (8 grammars/all calls queries), clean diff
check. Binary **2026-10-05 19:00:13 PDT**. Regressions cover mixed markdown/code/
test/build rows, both independent filters, deletions, rename directions, totals,
filtered versus genuine empty, visible selection/reset, canonical data and an
excluded Before Markdown reader preserving navigation/history. No native attempt
per user constraint; previous old-reader attachment/PR visual limitations remain.
Manual check/evidence in plans/source-filters-ui-review.md. No dataset, pins,
marks, branch, GitHub or user-reader changes; no commits/pushes.

## 2026-10-04 — Source filter acceptance repairs (GPT Sol)

Native attachment and single full-path recovery selected the user's old #691
nomex_e2e.rs review rather than the fresh app.rs instance. Stopped without UI
actions/screenshots; closed only review PID 60963, preserved user PID 31152.
Live filter appearance/discoverability, pointer reveal, narrow/dark layout and
PR coexistence remain manual. Previous PR/outline/physical-hover limits remain.

Fixed four concrete source-review edges: pytest functions require test_ prefix
(not testing_helper/testify/testConnection); Vitest if statements with an else
stay visible to preserve production; painted label hit IDs always refresh even
when geometry is identical; labels reject the actual hidden/null header glyph,
not a character-range mapping expanded to a surviving parent fold row. AppKit
regression reproduced that fold-row mapping bug, with no label/hit when folded
and label restored when outer function expands. Geometry/identity and detector
positive/negative regressions pass. Cleaned extra EOF blank line in history doc.

Actual final gates: check, **213 tests / 43 suites**, swiftbuild signed build,
strict deep codesign, env-i /tmp eight-grammar/all-calls verification, clean
git diff --check. Binary **2026-10-04 23:23:22 CDT**. Independently reran the two
targeted real tkos probes (inline anchors and Files counts), both pass; did not
repeat Opus's 63-second repository sweep. Model/AppKit tests are separate from
live UI evidence. Required SwiftUI/native/type guidance reviewed; no speculative
visual redesign. Dataset/user pins/marks/older reader untouched; no commits/pushes.
See plans/source-filters-ui-review.md for exact manual screenshots and limits.

## 2026-10-04 — Source filters: Hide Tests and Source Files Only (Opus 5.5; UI acceptance pending with GPT Sol)

Request: hide test code, including Rust test blocks in the middle of
ordinary files (at least Rust, Kotlin, Python best effort, TypeScript), and
filter the Files sidebar down to source code. Design recorded first in
[plans/source-filters.md](plans/source-filters.md).

**Options and location.** Two independent icon toggles beside the Files
**Filter files** field (Xcode navigator idiom), mirrored as checkmarked View
menu toggles: **Source Files Only** (⌃⌘O) and **Hide Tests** (⌃⌘T). Both
persist app-wide in UserDefaults (`sourceFilesOnly`, `hideTests`) and are off
by default. Toggling never touches the repository model, caret, history,
pins, marks, folds or source bytes.

**Files tree.** Rebuilt from included files, so empty directories prune. It
keeps Finder order, and directory expansion is now explicit, path-keyed state
(`FileTreeExpansion`, recursive DisclosureGroups replacing OutlineGroup). Test
paths match exact components and names: `tests/`, `src/test`, `src/*Test`
source sets, `__tests__`, `*.test.ts`, `*_test.go`, `test_*.py`, `*_tests.rs`,
and so on. `contest.rs`, `testing/` and `src/main/**/SpeedTest.kt` stay.
Source Files Only rejects artifact, dependency, cache and hidden directories
by component (a `.rs` under `target/` is not source), generated names,
manifests/configs, docs and data. The filter field's flat list follows the
options. ⌘K, Search, the Changes list, Go to Symbol and indexing are
deliberately unfiltered. The open file is never closed; the sidebar footer
reads “N of M files · open file hidden by filters”. **Show All Files** appears
when nothing passes.

**Inline detection** runs in `SyntaxWorker` from real node shapes, dumped
from the pinned grammars, never braces or strings:

- **Rust:** outer attribute siblings, with `cfg` parsed from the token tree
  and evaluated in three-valued logic. Code hides only when it is false
  without `test` and not always false; `any(test, feature)`, `not(test)` and
  `cfg_attr` stay visible. Also `#[test]`/`tokio::test`/`rstest`/`test_case`,
  and `#![cfg(test)]` modules or files.
- **Kotlin:** test annotations, test classes, and Kotest specs.
- **TS/TSX/JS:** top-level framework calls with function arguments, checked
  against file bindings and test-module imports or `require`, plus Vitest
  in-source blocks.
- **Python:** `TestCase` subclasses, and pytest conventions only when the
  module imports pytest.

Regions expand to whole lines, keep adjacent doc comments, merge across blank
gaps, and use an explicit stack (no recursion).

**Presentation.** Hidden test text joins the existing fold machinery as one
sorted disjoint UTF-16 union; the fold reducer now merges overlaps. Each
region keeps its first line, dimmed through the draw-time receded alpha and
merged with Critical Lens ranges. The gutter shows ▶ with the existing 9-pt
hidden-line capsule, and a quiet clickable label reads “Test code · N lines
hidden” (or “Hide test code” once revealed); its type is the source size − 3,
system regular, secondary. Reveal state (`revealedTestRegions`) belongs to the
loaded document and resets on another document (identical bytes elsewhere,
Before/After), on repository open/reload, and when Hide Tests turns on.
Explicit navigation reveals its target's region, also when syntax arrives
later (pending reveal). A plain top-of-file open does not. Back is exact.
Hidden declarations leave the outline. Test documents opened explicitly show
in full with a **Test file** footer note; other files show “N test regions
hidden”.

**Actual gates (this round):** `make check`; `make test` **210 tests / 43
suites**, including 3 opt-in tkos probes that skip by default; `make build`
(swiftbuild) signed bundle; `codesign --verify --deep --strict`; `env -i`
`--verify-resources` from `/tmp` (8 grammars, all calls queries). Signed
binary **2026-10-04 23:16:01 CDT**. New suites:

- `TestRegionDetectorTests` (12): per-language positives and negatives, the
  mid-impl boundary, cfg logic, CRLF/Unicode bytes, and 4,000-deep nesting.
- `TestCodePresentationTests` (5): header and hidden ranges, TextKit null
  glyphs with gutter-equivalent canonical lines `[1,2,3,8…]`, exact pasteboard
  bytes, union with default and manual folds across toggling, fold reveal
  inside revealed tests, model reveal on navigation, Back, Go to Line,
  toggle reset, pending cross-file reveal, identical-bytes identity, and test
  documents.
- `SourceFilterTests` (4): classifier positives and negatives, artifacts,
  pruning and order, independence, persistence, open-file retention, the
  field list, expansion, and reload.

The PR flow test now also asserts the filtered tree follows the head snapshot
and returns to the attached checkout.

**Real tkos (read-only, `RADIOLOGY_REAL_TEST_FILTER_PROBE=1`, passed):**

- `app.rs` regions 35–43, 803–833 (834 `create_durable_agent` outside) and
  3424–4709.
- `snapshot_policy.rs` 16–108, with `configure` at 9 visible.
- `FontFilesTest.kt` 9–87, `test_pr_local.py` 22–179 and
  `home-design-inspect.test.ts` 22–58; their production counterparts have no
  regions.
- Files: Hide Tests shows 4,842 of 6,846 files, Source Files Only 5,198, both
  3,256.
- The whole-repository sweep took 63 s with no failures. Among non-test
  paths, Rust had 183 of 289 files with test code; non-Rust hits were 6
  Python files with in-script `unittest.TestCase` classes and 1 bun preload
  `beforeEach`, all inspected as true positives.

tkos HEAD/status unchanged.

**Not verified:** any live UI. No launch, screenshot or native inspection in
this round, per ownership split. Limits:

- Copy across a hidden region copies the hidden bytes, and find searches
  them, as with folds.
- Python is best effort.
- JS/TS tests inside functions or custom wrappers are not detected.
- Go/Swift have only path rules.

Sol's checklist: [plans/source-filters-ui-review.md](plans/source-filters-ui-review.md).
No commits/pushes; RADIO.png, nested `repo/` and earlier dirty work untouched.

## 2026-10-04 — Visible Exit PR toolbar action (GPT Sol)

A text-labelled native **Exit PR** button with arrow.uturn.backward now sits
immediately beside the PR selector, outside the menu, while a review is active
or loading. Explicit titleAndIcon keeps the label visible. It uses the existing
exitPullRequest route: cancel a pending load or return from the snapshot to the
attached local checkout. Tooltip names local checkout; it does not claim main
or switch Git branches. Menu Local Checkout remains. Cancellation clears pending
load errors/failed number; regression confirms aborted retry cannot publish a
late error or disturb the current local reader/history.

Actual gates: check, **186 tests / 39 suites**, swiftbuild signed build, strict
deep codesign and env-i /tmp resource verification (8 grammars/all calls queries).
Binary **2026-10-04 20:18:12 CDT**. No native attempt per user instruction; no
reader/pin/mark/dataset interaction. One manual check: open or start loading a PR,
confirm visible Exit PR beside the selector, activate it, and confirm local
checkout browsing with no stale alert or branch change. Previous UI/hover/outline
limits remain; see plans/pull-request-ui-review.md. No commits/pushes.

## 2026-10-04 — PR acceptance repairs and real snapshot Rust smoke (GPT Sol)

Fixed five root-review findings: full 40-character blob-to-blob per-file hunks
(added/deleted use app-owned empty blob); repository-wide/versioned dependency
context for honest reuse; persisted mixed-reuse Partial on reload/refresh;
global native PR failure alert with retry/number recovery; Cmd-K guidance.
Also fixed refresh dropping revision cache options. Meaningful regressions cover
R100 rename plus old-path directory child, sibling source/include invalidation,
actual tool-run count, stored provenance reload/refresh and failed-number retry.
An existing external-definition navigation test now waits for correct document
semantics after Back, instead of racing load completion.

Final gates: make check; **186 tests / 39 suites**; signed swiftbuild bundle;
strict deep codesign; env-i /tmp resources (8 grammars/all calls queries).
Binary **2026-10-04 20:07:43 CDT**. Real probes pass for #724 merged head
f11c99e3d6/base 488d8768d5 (9 files), #723 merged f4082f9e3a/base 8368298660
(12), #725 open 3dd325f6b0/base e7380c8269 (744, seven renames).
Current all-repository policy finds 0/16 matching #724 head/base strategy digests;
the former 15/16 comparison is historical and not a current reuse claim.
Actual #724 phone-provisioner After rust-analyzer 1.97.1 generated one document in
7.48s, mapped 3,711 occurrences with zero unmapped, reused in 0.063 s, rejected a
simulated sibling-context change and regenerated in 2.47 s. Temporary app-owned
cache, no dependency fixes; not all 16 projects or a real edited second revision.

Native attempt plus single full-path recovery selected old app.rs:3026 pinned
reader rather than fresh instance. Stopped without UI action; closed only review
PID 78172, preserved user PID 87944. NO new screenshot or PR UI verification; prior
hover/outline limitations remain explicit. TkOS HEAD/status unchanged; no marks,
pins, RADIO.png, dataset or GitHub writes/commits/pushes. Full UI/manual checklist,
actual backend boundaries and logs: [plans/pull-request-ui-review.md](plans/pull-request-ui-review.md).
Handoff/subsystem/index updated. Full snapshot GUI responsiveness/cancellation,
dark/narrow visuals and semantic pointer/history flow remain manual.

## 2026-10-04 — Pull request review (Fable 5.1; UI acceptance pending with GPT Sol)

Radiology now reads GitHub pull requests of the attached repository. The
toolbar **Pull Request** menu lists the last 25 (open, merged, closed) via
read-only `gh`; ⌘P opens any number (the ⌘P file-picker alias was removed;
⌘K remains). After is the pinned head SHA checked out into an app-owned
worktree; Before is GitHub's `merge_base_commit`, materialized per changed
file from the base blob. A **Changes** sidebar segment lists files with
status, `+n −m` and rename pairs; the file tree and the outline's callables
carry accent dots where lines changed; added lines get a green gutter bar
and faint wash in After, removed lines red in Before; a per-file
**Before | After** control (⌥⌘B) maps the caret through the hunks and
records history so ⌘[ returns exactly; ⌥⌘↓/↑ step through changes;
`--pull-request N` launches straight into a review. Design, measured facts
and contracts: [plans/pull-request-review.md](plans/pull-request-review.md).

Index: the After snapshot is indexed with per-strategy exact-bytes reuse.
Metadata is format 3 (per-strategy git-blob content digests, `reusedFrom`);
a strategy is copied from the working-tree cache or another revision only
when digests match, otherwise regenerated whole (rust-analyzer and the other
indexers accept nothing smaller than a project). Mixed runs are **Partial**
with the reason; format-2 caches are never reused for a review. **Before is
syntax-only**: `Not Indexed (Before)`, no index mapped onto Before bytes.
GitHub metadata and Git objects are read only; nothing is written to GitHub
or under the attached folder (bare repo with alternates, fetch by SHA at
depth 1, `refs/pull/N/head` fallback that still verifies the pinned SHA).

Gates (actual, this round): `make check`, `make test` **184 tests / 39
suites**, `make build` (swiftbuild) signed bundle, `codesign --verify
--deep --strict`, `env -i` `--verify-resources` from `/tmp` (8 grammars,
all calls queries). Signed binary **2026-10-04 19:56:31 CDT**. New tests:
hunk parsing (CRLF, Unicode, no-newline, pure add/delete, binary, headers
after CRLF content), raw/numstat records (rename R099, delete), line maps,
gh JSON decoding, command timeouts, a local-origin Git fixture (fetch by
SHA without touching the attached clone, name-status/counts/hunks, Before
blobs, worktrees, blob ids, eviction), digest rules, reuse/regeneration/
Partial with a fake indexer, legacy format-2 rejection, and an AppModel
flow: open PR, After highlights `[6..<12]`, changed callables `b`,`c`,
toggle to Before at the mapped line, Back to the After caret, deleted and
renamed files, search hits forcing After, superseded loads, repository
switch mid-load, Local Checkout. A main-actor starvation (git fixtures) and
a `\r\n` grapheme bug in the parser were found by the full suite and fixed.

Real data (read-only, `RADIOLOGY_REAL_PR_PROBE=1 swift test --filter
PullRequestRealDataProbe`, temporary cache, tkos status/HEAD verified
unchanged): `tktkinc/tkos`, 25 recent PRs (9 open, 15 merged, 1 closed,
newest #734). **#724** had merged since the root's preflight: head
`f11c99e3d6`, merge base `488d8768d5`, 9 files (7 M, 2 A), fetch 1.3 s;
`DesktopRuntimeSession.kt` removed lines `[3..<5, 11..<64]`, 238 → 183
lines, After anchors `[3, 9]`; `RuntimeSmoke.kt` 17 hunks +117 −205; 16
strategies at head, 15 byte-identical to the merge base (would reuse).
**#723** merged, head `f4082f9e3a`, 12 files (5 M, 5 A, 2 D). **#725**
open, head now `3dd325f6b0`, 744 files (390 M, 336 A, 11 D, 7 R, incl.
`SegmentedJournal.kt` renamed and modified). The app's own index of the
head worktree was not generated in this round (no rust-analyzer run on a
snapshot); the reuse path is proven by tests, not by a tkos timing.

Not verified: any UI. Sol's checks: menu/sheet flows and errors (gh missing,
unknown number), Changes list and dots, gutter/wash in both revisions and
dark mode, Before/After control states (Added/Deleted/Unchanged/Renamed/
Binary), ⌥⌘B and ⌘[ round trip, ⌥⌘↓/↑, window subtitle, Local Checkout,
footer `Not Indexed (Before)`, index popover "Reused from …" rows, and that
the first review's indexing (regeneration of changed projects) stays
cancellable and never blocks reading. RADIO.png icon preserved; no commits,
pushes, tkos writes, or GitHub writes.

## 2026-10-04 — Function-first outline by source size

Ordinary Outline now surfaces all callable declarations, including methods and
nested functions, before non-callable declarations. Functions sort descending
by true signature-to-end line span, source-order ties, using half-open UTF-8
ranges. Original symbols/IDs preserve selection and navigation. Non-callables
remain in a native Declarations hierarchy without duplicated functions.
One-line body names use middle truncation; quiet `n L` trailing counts use the
existing metadata role with tabular digits, full help and accessibility labels.
Cached derivation refreshes on source/syntax paths, content identity and symbols,
including switches between identical-content files. Normal/Critical share this
outline; source-order context/gutter and removed lens sidebar content are unchanged.

Gates: make check, **169 tests / 34 suites**, swiftbuild signed bundle, strict
deep codesign, empty-env resources from /tmp (8 grammars/all calls queries).
Signed binary **2026-10-04 17:35:04 CDT**. New regressions cover flattening,
span ordering/ties, nested non-callable access, Unicode/half-open endings and
identical-content path invalidation. Existing navigation tests pass.
Native attachment selected the user's old app.rs reader instead of the fresh
app_image instance. Stopped immediately without clicks/recovery; terminated only
review PID 79127, leaving user PID 24145, pins and marks alone. No new live
outline evidence or screenshots; previous hover physical-click limitation remains.
See plans/critical-lens-ui-review.md for manual checks. No tkos writes/commits/pushes.

## 2026-10-04 — Hover popup click targets and native retention repair

The user reported unclickable symbol popups. Source inspection found the custom
Critical NSPopover is the only source-symbol popup: titles/call names were Text,
with only small trailing links actionable. Navigable titles and whole rows are
now semantic Buttons; external/missing targets remain unavailable. Stable
observable content avoids hosting-root replacement during loading. Native
full-area activeAlways tracking, a source→popup transit region and 700ms grace
retain entry; crossing tokens while inside cannot replace the popup. Existing
exact-caret definition/Back path remains. No sidebar lens depiction restored.

Actual final gates: check, **166 tests / 33 suites**, swiftbuild signed build,
strict deep codesign, empty-env 8-grammar resources. Binary **17:21:39**. Native
host/event/transit regressions and model destination/Back tests pass. Live
click verification was blocked: the native tool selected the old app.rs:316
reader despite a separate fresh app_image review instance; single full-path
recovery did the same. Stopped, terminated only the review process, preserved
the user's reader/pins/marks. No popup screenshots or physical click evidence;
[review](plans/critical-lens-ui-review.md) has exact manual steps and limits.
No tkos writes, commits/pushes; RADIO.png and aggressive rendering preserved.

## 2026-10-04 — Remove Critical Lens sidebar depiction

GPT Sol implemented the user's focused removal: no upper Critical calls/status/
unknown/conditional/frontier section, lower callable frontier, or outline density
counts. Normal and Critical now share the concise declaration/references and
Definition/outline sidebar with existing disclosures/navigation. No replacement
summary. Call-focused source, mode control, persistent marks, hover frontier and
source gutter counts remain. Sidebar-only components/tasks/state/row dispatch
were removed; gutter work visits only fold-bearing callables and pointer dwell
retains on-demand hover computation/priming.

Meaningful regressions verify mode-independent context/reference identities,
selection/disclosures and activation/Back, no new graph requests on caret moves,
no outline-only annotation work, and surviving hover/gutter behavior. Actual
final gates pass: make check, **164 tests / 32 suites**, make build swiftbuild,
strict deep codesign, env-i resources from /tmp (8 grammars). Signed binary
**2026-10-04 17:05:05**. No native relaunch/check was attempted while the user
was browsing the shared reader; no new screenshots or visual claims. See
[the review](plans/critical-lens-ui-review.md). README/design contracts updated;
earlier automatic sidebar/count descriptions are superseded. RADIO.png/icon
pipeline and tkos data preserved; no marks changed, commits or pushes.

## 2026-10-04 — Critical Lens call-focused rendering, user accepted

The user superseded protecting syntax/literals/locals at full contrast: only
actual call names should pop. GPT Sol implemented a complemented Tree-sitter
call-name projection: critical/unknown calls remain prominent, proven ordinary
calls and all non-call source recede. Unresolved syntactic names never create
semantic identities/edges; unindexed files can render when call syntax exists.
Context opacity is 30% light / 38% dark; Normal and drawing-only coordinate/
reader contracts remain intact. RADIO.png/icon generation preserved.

Actual native attachment succeeded. Same-viewport Normal/Critical captures of
read-only tkos `app.rs:115–139 execute_future` visibly show quiet strings,
control words, declarations, receivers/locals/types and a call-name foreground;
existing pins and line tint survive. Upper concise Critical call names and
independent lower Definition were observed. Separately the user said “this is
much better”, accepting the aggressive rendering. Live work stopped when the
shared reader was being used, rather than compete. No marks changed. Dark mode,
new mark toggle, hover navigation/Back and folded-count semantics remain
unverified. [Review and actual artifacts](plans/critical-lens-ui-review.md).

Final actual gates: make check, **163 tests / 32 suites**, make build swiftbuild,
strict deep codesign, empty-env packaged resource verification (8 grammars).
Signed binary **2026-10-04 16:53:36**. Rendering tests replaced obsolete syntax-
protection assertions and cover Unicode/non-call/ordinary/unknown distinctions;
a timing-sensitive pre-existing cache test now prepares parsed bytes before
its artificial-delay race (assertions unchanged). No production graph changes,
tkos writes, commits or pushes.

The parent preserved the supplied screenshot and both native comparison
captures under `build/critical-lens-ui-review/call-focus/`, verified review
links, and confirmed tkos Git status still exactly matches the starting status.
Only evidence/documentation changed after Sol's final gates.

## 2026-10-04 — App icon from RADIO.png

The supplied root `RADIO.png` is now the app-icon source. The icon script
resizes the complete artwork into the ten standard macOS variants without
cropping or added decoration; Make tracks both the PNG and script so future
changes regenerate `build/AppIcon.icns`. Info.plist already points at AppIcon.
The rebuilt signed bundle (binary copy timestamp **16:42:51**) includes the
new ICNS and was registered with LaunchServices. The original PNG is unchanged.

Validation: `make build`, `make check`, **161 tests in 32 suites**, strict deep
codesign, and packaged resource verification from `/tmp` with `env -i` all
pass. The bundled icon matches the generated file exactly and decodes into
ten variants spanning 16–1024 pixels; the generated 512-pixel artwork was
visually checked. No new tests were added for this asset change. No application
source changed, and no native UI test was attempted; the preceding Critical
Lens final-UI limitations remain. See [the build guide](plans/build-system.md)
for the asset pipeline. Nothing was committed or pushed.

## 2026-10-04 — Critical Lens final native acceptance blocked

GPT Sol launched the signed **16:19:59** build on untouched tkos. Native attachment failed with `Computer Use server error -10005: cgWindowNotFound`; the single full-app-path recovery failed identically. UI work stopped within the requested budget. No final screenshot/AX evidence, source fixes, tests or rebuild; reported 161 tests / 32 suites and signing/resource gates remain separate evidence. Original absent override state was snapshotted and unchanged. Stage-one visual acceptance stands; final summaries/frontier/hover/counts remain unverified. [The review](plans/critical-lens-ui-review.md) has exact manual cases and screenshot requests; do not call the full milestone visually accepted yet.

The parent confirmed tkos Git status exactly matches the starting status and
independently reverified strict deep signing. Stage-one captures remain
preserved under `build/critical-lens-ui-review/stage1/`; no final captures
exist. PLAN, implementation design, and handoff now record the blocked final
review and manual checks. Only documentation changed after the build; no
product code changed and the passing suite was not rerun. Nothing was
committed or pushed. The final app is left available for manual inspection.

## 2026-10-04 — Critical Lens, stages two and three: summaries, frontier, sidebar, hover, counts

The user handed source ownership back after Sol's successful stage-one
review and asked for the rest of the milestone in one turn. Fable 5.1
implemented it; no UI was launched by the implementer. Details in
[plans/critical-lens.md](plans/critical-lens.md) §5–§8.

- **Call sites:** a fifth query role, `calls`, for all eight grammars.
  Named shapes carry the callee token; a fallback over every call node
  keeps unsupported shapes (`(f)(x)`) as unresolved sites. Sites inside
  closures and nested named functions belong to those nodes and never
  become the outer function's edges.
- **Edges:** a site is an edge only when its callee token is a SCIP
  occurrence (`CallGraphWorker.resolve`); never by spelling. rust-analyzer
  emits no relationships, so this is the only edge source. Bodies are
  located by the Tree-sitter declaration at the definition byte, with the
  indexer's enclosing range as a bounds-only fallback.
- **Frontier:** bounded BFS (depth 4, 48 bodies). Critical emits, ordinary
  with a body traverses transparently as a via step, unknown is listed and
  makes coverage partial, closures make it partial too. Cycles,
  self-recursion, and diamonds terminate; the first path wins; the count
  is the distinct union of direct and frontier callees.
- **Coverage:** complete, partial (unresolved, macros, missing bodies,
  truncated, parse errors, unknown callees, conditional sites), or no body
  (external, abstract, no syntax, unreadable, not indexed, unsupported).
  Proven zero requires complete coverage.
- **Caches:** worker configured by root/index/policy revisions with a work
  epoch advanced on reconfiguration and on byte invalidation; in-flight
  operations never store stale results; a disk load that finishes after
  the same path was primed yields to the primed bytes. Review findings on
  prime ordering, dependent frontiers, mid-operation reconfiguration, and
  unknown/conditional proven-zero were each fixed with a regression.
- **Sidebar:** Critical mode puts a **Critical** section ahead of the
  reference list: status line, direct critical calls, frontier rows with
  via chains, unknown/conditional lines; References follow unchanged. The
  lower Definition row gains a compact bounded frontier for callables.
  Requests follow the two Context identities, never a caret timer.
- **Hover:** automatic popover after 350 ms on a callable with a body or a
  critical external callable; stays open while the pointer moves into it;
  closes on leaving, click, key, scroll, mode/file/index/repository
  change. Rows navigate through the exact-caret history path; external
  rows say "external" and do nothing.
- **Gutter and outline:** collapsed functions show the reachable count in
  an accent-stroked rounded square (`3`, `3+`, `–`) instead of the neutral
  hidden-line capsule, which stays in the tooltip/accessibility; outline
  rows get a trailing caption count in source order. Both are generic
  `CountAnnotation` values; the gutter and reader know nothing about
  classification.
- **Real tkos (read-only probe):** `restore_app`→`restore` direct,
  complete; with `restore` marked ordinary (probe-local): `section via
  restore` and `compatibility via restore`, section's three sites collapsed
  to one path, partial (6 unresolved dependency calls, 2 macros).
  `read_observation`: `observe_session`, complete. `publish_instructions`:
  6 direct critical, 7 closure sites, 5 unknown, partial. `open`: 39 direct
  critical, 23 closure sites, partial. Marks were never persisted.
- **Tests:** `CallSiteExtractionTests` (4), `CriticalFrontierTests` (3),
  `CallGraphWorkerTests` (5), `CriticalSummaryModelTests` (3); the Rust
  fixture and synthetic graphs cover ownership, dynamic sites, dedup,
  caps, invalidation, and reconfiguration races.
- **Gates:** `make check`, **161 tests in 32 suites** via `make test`,
  `make build` (swiftbuild), `codesign --verify --deep --strict`, and
  packaged `--verify-resources` from `/tmp` with `env -i` (8 grammars, now
  `highlights+folds+symbols+scopes+calls`) all pass. Binary
  `build/Radiology.app/Contents/MacOS/Radiology` built 2026-10-04 16:19:59.
- **Live check pending (Sol).** Short checks on untouched tkos:
  1. `engine/rust/src/app_image.rs`, caret inside `restore_app` (401),
     Critical: the upper region's Critical section lists `restore` →
     line 404; References follow. Caret into `restore` (404): `section`
     ×3 and `compatibility` rows, status "2 direct · partial"; expanding
     nothing is needed to read the names. Return on a row jumps; ⌘[
     returns to the caret.
  2. Right-click `restore` → Mark “restore” ▸ Non-Critical: `restore_app`'s
     section now shows `section via restore` and `compatibility via
     restore` with the chevron revealing the chain; Built-In restores.
  3. Hover `section` on line 413 (no modifier): after a beat a popover
     with "section", Definition link, "0 direct · proven"; move the pointer
     into the popover, click Definition: jump; ⌘[ back. Hover `ok_or` or
     a local: no popover. Hover `libc::flock` in
     `modules/agent/ffi/src/store_owner.rs:48`: popover says "external",
     no link, no navigation.
  4. Collapse `restore` (gutter): the count lane shows `2+` in an
     accent-stroked square; tooltip includes the hidden-line count; expand
     and the normal capsule returns in Normal mode. Outline rows show
     trailing counts in source order; a proven-zero row reads a quiet `0`.
  5. `modules/agent/ffi/src/app.rs`: caret in `open` (1343): the Critical
     section lists `optional_string`, `bad`, `prepare_catalog`, … with a
     "23 calls in closures" line and "partial" status; scrolling the list
     stays responsive while the gutter counts fill in.
  6. ⌘1: Critical section, popover, and counts disappear; references and
     Definition are exactly as before. Dark mode legibility of the gutter
     badge and popover.

## 2026-10-04 — Critical Lens stage-one native UI checkpoint

GPT Sol reviewed the signed **15:43:16** build on read-only tkos through native Computer Use. Actual on-screen dimming worked; repository/system operations remained prominent, unresolved dependencies neutral, and syntax/caret/function shade legible. Cmd1/Cmd2 preserved observed caret, viewport, word selection, existing folds and history. Native copy of a dimmed token worked. Symbol/package mark precedence worked in opposing directions, with persistence across relaunch; the original absent repository override file was restored after stopping the review app. No source changes or rebuild; handed-off gates remain 146 tests / 28 suites. Light-mode contrast accepted as-is. Dark mode, pin overlays and other explicit coverage limits remain unverified, not failures. See [the native review](plans/critical-lens-ui-review.md) for actual screenshots and stage-two handoff. Fable can resume summaries/call graph/frontier before hover/gutter/outline counts.

## 2026-10-04 — Critical Lens, stage one: classification, marks, Critical source rendering

The user asked for a Critical Lens source projection for skimming meaningful
operations, in stages. Fable 5.1 wrote the system design
([plans/critical-lens.md](plans/critical-lens.md)) and implemented stage one
only. GPT Sol owns the live UI check; the implementer launched nothing.

- **Measured first (read-only tkos cache, 13 rust-analyzer 1.97.1
  strategies):** rust-analyzer emits **no** SCIP relationships, so there are
  no call edges in the index; `enclosing_range` exists on every indexed
  definition (whole item) and `enclosing_symbol` on every local; external
  symbols (`core`, `std`, `serde_json`, `libc`…) carry no kind or signature,
  only their symbol string; operators, `?`, brackets, and even spaces are
  `core ops/…` occurrences; 222 repository signatures contain `extern`.
  Opt-in probe: `RADIOLOGY_CONTEXT_PROBE=<cache> swift test --filter
  CriticalRealDataProbe`.
- **Mode:** `SourceMode` (`normal`, `critical`), a segmented
  Normal | Critical control in the toolbar's principal position, and View
  menu items with ⌘1 / ⌘2. Per session, not persisted.
- **Classification** (`Critical/CriticalityPolicy.swift`): deterministic
  precedence — symbol mark, package mark, local → unknown, explicit
  binding-package list or `ffi/`/`os/` descriptors → critical, indexed
  `extern "` signature → critical, system-facing std/tokio modules →
  critical, repository definition or repository package → critical,
  `core`/`alloc`/`std` → ordinary, else unknown. No spelling heuristics; a
  `-sys` suffix alone proves nothing; raw-pointer/`mem` helpers are not
  promoted. Only the rust-analyzer scheme has profiles.
- **Real tkos results** (probe, classification level): in `restore`
  (app_image.rs:404–425) `section`, `compatibility`, `MAGIC`, `MAX_IMAGE`,
  `Restored`, `Error` are critical; `Vec`, `Result`, `len`, `split_at`,
  `Err`, `into`, `Some`, `format`, `as_str`, `is_empty`, `BTreeMap`,
  `String` are ordinary; `serde_json::from_slice` and `Sha256::digest` have
  no occurrence (engine is `--no-deps`) and stay untouched. In
  store_owner.rs:41–49 `OpenOptions::open` is systemAPI, `libc::flock`,
  `LOCK_EX`, and `as_raw_fd` are ffiPackage, `io::Error::last_os_error` is
  plumbing (excluded `io/error/` module). In app.rs `open`, `optional_string`,
  `bad`, `HarnessError` are critical, `first`/`and_then`/`cloned`/
  `unwrap_or_default` ordinary, `serde_json::Value::as_object` unknown.
- **Marks:** source context menu → `Mark “name” ▸ Critical / Non-Critical /
  Built-In (…)` and `Mark Package “pkg” ▸ …` with radio state. Symbol beats
  package beats built-in. Locals are never offered or stored (their SCIP
  numbers are renumbered by reindexing). Package keys are
  `scheme manager name` without version. Persisted atomically at
  `~/Library/Application Support/Radiology/overrides/<repo-id>.json`,
  keyed like the index cache; the viewed repository is never written.
  Edits made before the file loads are replayed on top of it; saves are
  chained and revision-guarded; deletion failures surface as “Marks not
  saved” in the footer.
- **Rendering:** `SourceProjection` (sorted, merged canonical byte ranges
  bound to the buffer's path and full content identity). Only ordinary,
  non-definition, single-line, identifier-shaped occurrences that touch no
  Tree-sitter keyword/literal/comment/operator capture recede; a file with
  a grammar waits for its structure. The coordinator's
  `shouldUseTemporaryAttributes` hook returns the text storage's own color
  at 42 % (light) / 50 % (dark) opacity: no storage mutation, no layout,
  no coordinate change; copy, Find, selection, pins, shade, caret, folds,
  history, and scroll are untouched. Caret moves cost one key comparison.
- **Tests:** `CriticalityPolicyTests` (3), `CriticalProjectionTests` (2,
  including an ordinary occurrence over `await`/`true`/`return`),
  `CriticalityOverrideStoreTests` (2), `CriticalLensModelTests` (3, through
  `AppModel` with the fake indexer), `SourceProjectionDrawingTests` (3).
  TextKit ignores temporary attributes offscreen, so a pixel test is
  impossible by design; the hook's outputs and its consultation on every
  draw pass are tested instead.
- **Gates:** `make check`, **146 tests in 28 suites** via `make test`,
  `make build` (swiftbuild backend), `codesign --verify --deep --strict`,
  and packaged `--verify-resources` from `/tmp` with `env -i` (8 grammars)
  all pass after the final `io/error/` profile fix. Binary
  `build/Radiology.app/Contents/MacOS/Radiology` built 2026-10-04 15:43:16.
- **Not done (stage two/three, designed only):** function summaries, call
  graph from Tree-sitter call sites resolved to SCIP (closure and nested
  function sites are their own conditional nodes, never direct edges of the
  outer function), frontier with via paths, identity-driven sidebar
  summaries, hover popover, fold-gutter and outline counts.
- **Checks for Sol (live, untouched tkos):** 1. open
  `engine/rust/src/app_image.rs`, place the caret in `restore` (line 404),
  switch to Critical (toolbar or ⌘2): `section`, `compatibility`, `MAGIC`,
  `Restored`, `Error` stay full; `Vec`, `Result`, `len`, `Err`, `into`,
  `Some`, `format`, `BTreeMap`, `String` recede; `if`, `return`, `?`,
  braces, strings, `serde_json::from_slice`, `Sha256::digest`, locals stay
  full. 2. `modules/agent/ffi/src/store_owner.rs:41–49`: `open`, `libc`,
  `flock`, `LOCK_EX`, `as_raw_fd` full; `PathBuf`, `from`, `map_err`
  receded; `unsafe` full. 3. Arrow through a receded token: caret, Context
  rows, and the function shade behave as in Normal; ⌘-hover underline and
  ⌘-click still work on receded and full tokens; Return/⌘[ unchanged;
  select and copy a receded span: plain text. 4. Fold `restore`: no
  stacked artifacts; unfold: dimming intact. 5. Right-click `len` → Mark
  “len” ▸ Critical: it returns to full at once; Built-In restores; Mark
  Package “alloc” ▸ Critical: `Vec`/`String`/`format` return; relaunch and
  reopen tkos: marks persist; open another repository: none apply.
  6. ⌘1 returns to Normal with no residue; toggle rapidly while scrolling.
  7. Dark mode legibility of receded text (50 %). 8. Confirm no file
  appears in tkos and the JSON exists under
  `~/Library/Application Support/Radiology/overrides/`.

## 2026-10-04 — Faint shade under the current function

The user asked: "put a subtle background shade under the current function that
i'm visiting, just enough to notice if i'm looking for it." Opus 5.5
implemented it. See
[structural navigation](plans/structural-navigation.md#current-function-shade).

- **Which function:** the innermost Tree-sitter function, method, initializer,
  or deinitializer around the genuine caret, from signature to end. Not
  types, `impl` blocks, or modules. Closures keep their named function.
- **When it clears:** outside functions, on a file or repository change, and
  without structure. Scrolling never moves it.
- **Drawing:** full-width bands from TextKit line fragments, painted first in
  `drawBackground`. Line tint, highlights, pins, and caret stay on top. Folds
  collapse it to the visible line. Only the visible slice is mapped to glyphs,
  after source review.
- **Color:** `labelColor` at 3% (light) or 4.5% (dark).
- **Tests:** new `FunctionShadeTests` (3). They found and fixed a missing clear
  on repository open.
- **Gates:** `make check`, **132 tests in 22 suites** via `make test`,
  `make build`, strict deep codesign, and packaged `--verify-resources` from
  `/tmp` with an empty environment (8 grammars) all pass. Binary
  `build/Radiology.app/Contents/MacOS/Radiology` built 2026-10-04 15:02:16.
- **Live check:** GPT Sol verified the faint wash in light mode on untouched
  tkos: `section` shades lines 93–101, stays stable during caret movement,
  clears on blank line 102, and transfers to `sources`. Folding and adjacent
  `restore_base`/`restore_app` boundaries work. Pins, current-line tint,
  symbols, and the caret stay legible. Passive scrolling does not transfer
  the shade to the viewport's function. No defect was observed; dark mode
  was not tested. See [Sol's review](plans/context-ui-review.md); screenshots
  are preserved in `build/context-ui-review/function-shade/` (removed by
  `make clean`). No UI launch by the implementer; no commits or pushes.

## 2026-10-04 — Subtle caret in the read-only source reader

The user asked: "i need to see a cursor, not just the current line (a caret
would be great, keep it subtle) because some lines have multiple syms and i
don't want to have to mouse to get to them sometimes." Opus 5.5 implemented it.
See [structural navigation](plans/structural-navigation.md#read-only-source-caret).

- **Approach:** the reader stays read-only. AppKit draws no insertion point for
  a non-editable text view, so `ReaderTextView` paints one.
- **Style:** a 1.5 pt steady bar in the dynamic system insertion-point color at
  85% opacity. Its height spans the font's ascender to descender on the real
  baseline. It is painted last in `drawBackground`, above line tint and
  decorations. No blink, no timers.
- **Geometry:** from actual TextKit glyphs, covering tabs, emoji, ZWJ and
  combining clusters, line ends, EOF (including after a final cluster), and
  none inside folds.
- **Gating:** shown only in the focused key-window reader with an empty
  selection.
- **Fixes found during the work:**
  - Trailing UTF-16 units of clusters carry null placeholder glyphs, so the
    caret snaps to the start of the composed character.
  - The EOF case after a final cluster (found in source review) now uses the
    complete glyph span.
  - An initial `draw(_:)` override changed scroll-restoration behavior, so it
    was replaced by painting in `drawBackground`.
- **Tests:** `SourceCaretTests` (3), with mutation checks for the EOF fix and
  the gate.
- **Gates:** `make check`, **129 tests in 21 suites** via `make test`,
  `make build`, strict deep codesign, and packaged `--verify-resources`
  (empty environment, 8 grammars) all pass. The signed app is
  `build/Radiology.app`.
- **Live check:** GPT Sol verified the caret on tkos `app_image.rs:94`:
  arrows moved it from `input` to `prefix`, updating the lower Context row
  while the upper declaration/references stayed fixed. Word selection and
  sidebar focus hid it; it reappeared above pinned tint. Source Return/Back
  still worked at `section:413`. Concise default rows and the Definition
  heading were also observed. No new defect was found. Dark mode and Unicode
  edge cases were not exercised live; the latter have model-test coverage.
  Evidence is in [Sol's review](plans/context-ui-review.md), with captures
  preserved under `build/context-ui-review/caret/` (removed by `make clean`).
  No UI launch by the implementer; no commits or pushes.

## 2026-10-04 — Concise Context default: one line per item, expansion on demand

The user asked: "just show a single line for each, and then have an expansion
affordance to show more… keep the DEFAULT information layout in the sidebar
concise," and "lose 'under caret', too explainy." Opus 5.5 implemented it. See
the concise-default section of [plans/context-sidebar.md](plans/context-sidebar.md).

- **Declaration region:** one pinned line (name, kind, line link), with the
  signature behind a native disclosure triangle. References and definitions
  are one line each, with a row chevron or →/← to show context. The automatic
  selection preview is gone. ↑/↓ selects, Return commits.
- **"Definition" region** (formerly "Under Caret"): one line of name, kind, and
  location link, `here`, or package. The triangle reveals signature, docs,
  facts, and the preview.
- **Statuses:** one short line each, with full reasons in tooltip and
  accessibility.
- **Expansion state:** tied to identities in `ContextModel`. It starts
  collapsed, survives movement within an identity, collapses on a new one,
  and never navigates.
- **Tests:** a new expansion-identity test, plus disclosure toggling in the
  passive no-navigation test.
- **Gates:** `make check`, **126 tests in 20 suites** via `make test`,
  `make build`, strict deep codesign, and packaged `--verify-resources`
  (empty environment, 8 grammars) all pass. The signed app is
  `build/Radiology.app`.
- **UI boundary:** GPT Sol launched the fresh signed build, but native access
  returned `Computer Use server error -10005: noWindowsAvailable` during the
  line94/source-click sequence. He stopped immediately without retry or
  workaround, per user instructions. Compact layout and disclosure interaction
  remain unverified; no new screenshot or product defect was observed. Exact
  manual checks are in [Sol's review](plans/context-ui-review.md): capture
  collapsed and expanded rows at normal and 220-point widths, selection without
  automatic preview, reference Return/Back, and independent expansion resets.
  Earlier successful live reviews cover earlier builds only. No UI launch by
  the implementer; no commits or pushes.

## 2026-10-04 — Return/Enter in the source reader goes to definition

The user asked: "hitting enter when highlighting a funcall's symbol should just
take us to the definition. presumably cmd-[ should take us back to where we
were." Opus 5.5 implemented this as a narrow AppKit route in
`ReaderTextView.keyDown`. Details are in
[plans/context-sidebar.md](plans/context-sidebar.md).

- **Trigger:** plain Return or keypad Enter in the focused source reader. It
  works with the caret inside a SCIP occurrence or just past it, or with a
  word selection inside one occurrence.
- **Path:** it calls `goToDefinition(at:departingFrom:)`, the same semantic path
  as ⌘-click. ⌘[ restores the exact departure caret, even after passive
  scrolling.
- **Pass-through:** modified keys, marked text, whitespace, unindexed files,
  external symbols, the definition itself, and over-wide selections go to
  AppKit unchanged. Nothing is guessed. Selection, copy, pins, and the
  sidebar's Return behavior are untouched.
- **Tests:** new `ReaderReturnKeyTests` (2), driving the real `keyDown`.
  Removing the modifier or selection-bound guards made them fail.
- **Gates:** `make check`, **125 tests in 20 suites** via `make test`,
  `make build`, strict deep codesign, and packaged `--verify-resources` from
  `/tmp` with an empty environment (8 grammars) all pass. The signed app is
  `build/Radiology.app`.
- **Live check:** GPT Sol verified source-focused Return from `section` at
  `app_image.rs:420` to its definition at93 after passive scrolling; Cmd-[
  restored the call site. Native word selection also worked. Cross-file
  Return on `runtime.rs:145` `restore_app` reached `app_image.rs:401`, with
  Back restoring145. Sidebar Return still committed reference276, and
  external `Some` did not navigate. No new defects or tooling blockers.
  Exact token-end byte placement was only partially verified visually; unit
  tests cover that boundary. Evidence and screenshots are in
  [Sol's review](plans/context-ui-review.md) and
  `build/context-ui-review/return-key/`. No UI was launched by the implementer.
  No commits or pushes.

## 2026-10-04 — Context inspector repairs and GPT Sol live review

Opus 5.5 implemented the feature and all fixes. GPT-6.1 Sol exclusively
exercised the native UI and inspected the design against untouched tkos.
This entry supersedes the pending live-review status in the implementation
entry below. See [the implementation plan](plans/context-sidebar.md) and
[Sol's review](plans/context-ui-review.md).

- **Final gates:** `make check`, **123 tests in 19 suites** via `make test`,
  `make build`, strict deep codesign, and packaged `--verify-resources` from
  `/tmp` with an empty environment all pass (8 grammars). Signed app:
  `build/Radiology.app`. No commits or pushes.
- **Live behavior:** Sol verified read-only caret arrowing, independent lower
  context, whitespace outline fallback, reference selection/Return,
  definition-link and Tab/Return navigation, Back after passive scrolling,
  pins, narrow inspector layout, external-source availability, and file-change
  clearing. The shared type hierarchy and native split/list design were judged
  coherent.
- **Four repairs from that review:** preserve multiline signature height;
  keep call-site snippets visible at compact heights; use Tree-sitter's
  declaration boundary for cross-file definition previews; distinguish
  repository-without-index from file-not-indexed. Added meaningful regression
  coverage for adjacent declarations and availability. Fixed an older test
  race that waited on a placeholder repository status.
- **Recheck:** the rebuilt app visibly shows all seven `open` signature lines
  when space permits, numbered reference snippets at default/enlarged heights
  and a condensed call site at a short 220-point inspector, and only lines
  401–403 for `restore_app`. Definition activation and Back still work.
- **Manual boundary:** after the one recovery retry, ScreenCaptureKit failed
  with `-3812`. UI work stopped without another workaround, as requested.
  Open root `README.md` and screenshot **File not indexed** beside Outline
  with **Index Partial** in the footer. The wording repair has test evidence
  but was not observed on the final build. Cmd-click, contextual activation of
  an unselected row, long-list scroll retention, VoiceOver speech, and dark
  mode remain unverified; exact steps and other limits are in Sol's review.
- **Evidence:** original and recheck captures are preserved under
  `build/context-ui-review/initial/` and `build/context-ui-review/recheck/`.
  These are local build artifacts and are removed by `make clean`.

## 2026-10-04 — Context inspector implemented (Opus 5.5); live UI review pending

This round supersedes the authentication-blocked note below. Claude
authentication was restored, and Opus 5.5 implemented the caret-driven Context
inspector. Full detail is in [plans/context-sidebar.md](plans/context-sidebar.md).

- **Inspector:** the Outline/Symbol toggle and `SemanticInspectorView` are
  gone. A `VSplitView` holds two regions:
  - **Declaration:** the innermost Tree-sitter declaration. Its pinned summary
    shows name, kind, flush signature, and a Line link. Ambient SCIP references
    follow, grouped by file. The count covers uses only, and definitions are
    labelled.
  - **Under Caret:** the SCIP occurrence with signature and docs. Calls and
    types get a bounded preview; locals stay quiet. External symbols are
    honestly explained.
  - **Outline fallback:** on whitespace, keywords, imports, and anything
    without a semantic occurrence.
- **No debounce:** `ContextModel` is keyed on declaration and occurrence
  identities. It writes observable state only on identity change, and uses
  generation-checked, cancelled off-main queries on separate actors. Caches are
  bounded and invalidated by index, repository, and source-byte changes.
- **Genuine caret:** `AppModel.caretLocation` is separate from the
  viewport-mixed `positions`.
  - Scrolling never changes context.
  - Every sidebar activation records the caret as Back's departure: reference
    commit, the definition link or Return, and the declaration Line link.
  - Reference ↑/↓ shows a capped call-site preview below the list. Return,
    double-click, or Open commits the named row.
- **Fixes found on real data:** SCIP fallback names inside backtick-escaped
  `[...]` descriptors (`first` from core read as `]first().`); URL version
  fields in package names; multiline signatures of nested methods.
- **Fixes from parent review:** caret vs scroll departure, the true definition
  list on definitions, and honest reference counts.
- **Fixes from Sol's source-only review:**
  - native actions commit their own row ID;
  - snippet accessibility values contain the source;
  - the preview is capped and scrolls, preserving list room;
  - the summary is pinned above the list;
  - long names get stacked metadata;
  - a visible "Preview · Return opens" hint.
- **Validation:**
  - `make check`, **120 tests in 19 suites** via `make test`, signed
    `make build`, strict codesign, and packaged `--verify-resources` (8
    grammars from `/tmp`, empty environment) all pass.
  - New: `ContextModelTests` (15), `ContextNavigationTests` (7), and the opt-in
    `ContextRealDataProbe`.
  - Mutation checks confirmed that the caret-departure and identity-guard tests
    fail when those guards are broken.
  - Real tkos resolution used the existing app-owned cache (tkos `239b9f6d4`,
    read-only). Results are recorded in the plan.
- **Not done here:** this agent did no live launch, UI automation, or visual
  inspection, per instructions. GPT Sol (`31e45a42-9257-445f-a185-70c9b908ebf3`)
  owns that, and owns `plans/context-ui-review.md`.
- **Build:** the signed app is `build/Radiology.app`. Nothing was committed or
  pushed.

## 2026-10-04 — Caret Context sidebar requested; implementation awaiting authentication

The user authorized a new Context inspector with independently updating
enclosing-declaration/references and under-caret definition/preview regions,
semantic identity updates without timer debounce, outline fallback, and no
source navigation until explicit activation. References keyboard movement
should preview, Return should commit, and Back should restore the departure.
The explicit model split is **Opus 5.5 for implementation** and **GPT Sol for
live UI/design review**. The read-only test dataset is
`/Users/tqbf/codebase/tk/tkos`. If UI inspection becomes complicated, stop
automation and give the user precise manual checks and screenshot requests.

Started local Paseo implementation agent
`6195c78d-1734-48ea-b18f-62dceacc6ad0` (`claude/claude-opus-5-5`), but it
could not start work: "OAuth session expired and could not be refreshed."
Local `claude auth status` confirms `loggedIn: false`. The user was asked to
run `claude auth login` on SHEFFIELD, then report readiness for a retry. Do not
substitute another implementation model silently. No feature code has changed.

GPT-6.1 Sol review agent `31e45a42-9257-445f-a185-70c9b908ebf3` completed
read-only preparation and awaits a new-build follow-up. Native `@oai/sky`
imported, but screenshot/AX access is not yet verified. Concrete cases include
`engine/rust/src/app_image.rs:93` (`section`, with calls at lines 413/420/424),
`engine/rust/src/runtime.rs:145` (`restore_app`, definition at app_image.rs:401),
`app_image.rs:19` (cfg-inactive Android symbols), and
`modules/agent/ffi/src/app.rs:1343` (`open`, multiline signature/large fold) and
line 4286 (Unicode). Historical reference counts are not fresh expectations.
UI setup recovery is limited to one simple retry and about 2–3 minutes; no UI
launch or inspection has occurred in this preparation round.

## 2026-10-04 — Fresh checkout and build on SHEFFIELD

Cloned `tqbf/radiology` into `/Users/tqbf/codebase/radiology` on `main` at
`2e02ae3`. The first build compiled successfully on macOS 26.5 / Swift 6.3.3
but failed during packaging: this toolchain defaults to SwiftPM's native
backend, which creates flat query bundles instead of the expected macOS
`Contents/Resources` layout. Its generated resource accessor also does not
search the packaged app's resources.

Used the Paseo skill and CLI over the configured `ssh://elston` alias to read
the successful Radiology agent's build record, then inspected the remote
toolchain and generated resources without changing the remote workspace or
prompting its agents. ELSTON uses Swift 6.4 and the `swiftbuild` backend.
Updated `build.sh` to explicitly select `swiftbuild` for compilation and binary
path discovery, preserving the existing signed app layout. Applied the
SwiftPM guidance and the repository's required `swiftui-pro` review guidance
before and after the build-script change; no application or UI code changed.
Documented the backend requirement in `plans/build-system.md`.

Fresh validation passes: `make build`, `make check`, **97 tests in 16 suites**
via `make test`, strict codesign verification, and packaged resource verification
for all eight grammars / 31 query files. Resource verification ran from `/tmp`
with an empty environment; the Swift Build accessor resolves the bundled
resources instead of falling back to the developer's build directory. The
debug app is at `build/Radiology.app`. No interactive UI launch was performed.
The build fix and documentation changes remain local and uncommitted.

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
