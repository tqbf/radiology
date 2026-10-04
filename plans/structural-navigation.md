# Structural navigation

Radiology's Tree-sitter structure is a coordinated reading surface. All
locations remain canonical UTF-8 byte offsets; TextKit conversion still occurs
only through `SourceBuffer`.

## Outline and synchronization

The flat query result becomes a tree through strict byte-range containment.
Direct children exclude intervening containers and retain source order. Thus
Rust `impl PreparedApp > image` and `impl SnapshotBootstrapGlobals > hide,
restore` reflect actual syntax rather than inferred indentation.

Clicking an outline row commits a history entry and selects its declaration.
Native Up/Down movement previews without changing selection or history; Return
commits. Passive source scrolling updates the enclosing declaration and
breadcrumb. A programmatic jump reports its target before ordinary scroll
synchronization resumes, preventing viewport clamping near EOF from replacing
the intended selection.

Pointer activation is independent of the list's selection-change callback, so
clicking an already-selected row still issues a fresh jump. Preview ignores the
exact committed target instead of racing it. Before scrolling, every manual or
definition fold containing the destination is removed. A revision-guarded second
layout pass on the next main-actor turn positions the source after TextKit has
settled changed fold and font geometry; a superseding navigation cancels it.

Outline pointer jumps briefly paint the complete destination line with the
dynamic system accent color at low alpha. This is a `ReaderTextView` background
presentation only: it does not modify attributed source, syntax colors,
selection, copy/find ranges, or canonical bytes. Repeated clicks restart the
feedback. Any new navigation or file clears it. It holds for roughly 650 ms and
then fades over roughly 200 ms; Reduce Motion clears it without the fade.

## Breadcrumbs and history

The header displays repository / relative path / enclosing declarations.
Declaration components are buttons. History distinguishes a file-opening
restoration position from a pinned structural anchor. Preview and passive
synchronization never append entries; Back/Forward do not duplicate entries.

## Default function folding and Fold to Definitions

As soon as structure arrives for a newly loaded supported source, Radiology
collapses every captured function implementation body once. Type, class, impl,
protocol, interface, module, and other declaration containers remain open, so
the initial view is a scan of signatures rather than a sequence of adjacent
implementations. The one-time state belongs to the loaded buffer: repainting,
resizing, changing source type size, or receiving another SwiftUI update does
not undo a user's manual expansion.

The header has an always-visible **Collapse Functions** control (disabled when
the file has no function folds) with a tooltip and accessibility label. The
same action is available from the app menu with `⌘⇧0`; it adds all function
folds back without disturbing manual non-function folds, navigation history, or
source bytes. When syntax arrives after a requested jump, default folds are
applied first and the target is revealed afterward, so asynchronous parsing
cannot hide the destination.

Navigate > Fold to Definitions (`⌘⌥0`) collapses function bodies and leaf type
bodies. Containers with nested declarations remain open, so method signatures
stay visible. Rust `extern C` signatures remain visible. Navigation removes any
fold that actually hides its target. Manual folds, copy, find, and coordinates
continue to use unchanged backing text.

The separate `LineNumberGutter` enumerates surviving TextKit line fragments and
maps the first real glyph in each fragment back to its canonical source line.
Hidden glyph aliases therefore cannot stack or mislabel rows. Fold controls use
an 11-point medium disclosure glyph centered in a 28-point-wide, full-line hit
target, with pointing-hand cursor and accessibility help.

A collapsed function has a three-point secondary-label meter whose logarithmic
width is `6 + 16 × log2(hiddenLines + 1) / log2(257)` points (capped at 256),
plus a separate neutral capsule containing the exact hidden-line count. The
104-point gutter reserves distinct lanes for disclosure/meter, fold count, and
canonical source number; counts cannot be mistaken for line numbers. Counts
come from canonical source boundaries and are independent of font/layout.
Tooltip and accessibility help report “Collapsed function — N lines hidden.”
Expanded and non-function folds have no cue.

Fold glyph ranges are normalized to disjoint outermost ranges, so a nested
function cannot paint a marker through a collapsed parent. Null glyphs retain
their original TextKit properties while hidden control characters use zero
advancement. This keeps large bodies compact without corrupting the glyph to
character map. Delegate detachment is limited to source replacement, and one
SwiftUI update never generates the same large folded layout twice.

### Large-file performance

The effective folded ranges are cached in sorted, disjoint UTF-16 form at the
TextKit boundary. Per-glyph and per-control-character membership uses binary
search. A fold update diffs old and new effective ranges: an invisible nested
change is a no-op, changed glyph properties are regenerated only for their
union, and layout is invalidated from the earliest changed character to EOF
because downstream vertical positions move. This preserves canonical source
coordinates while avoiding a whole-document glyph regeneration on every click.
The real tkos 4,880-line `app.rs` rendered-completion probe covers large,
medium, and tiny folds and explicitly forces layout after each toggle.
It is opt-in through `RADIOLOGY_REAL_FOLD_BENCHMARK=1` because it reads the
untouched external tkos checkout; normal portable tests retain the generated
607-row multiline/nested-function regression fixture.

## Language limits

Function folding follows existing grammar captures. Swift function and
initializer bodies; Rust functions and block-bodied closures; Go functions,
methods, and block-bodied function literals; Python sync/async function bodies;
JavaScript/JSX/TypeScript/TSX declarations, methods, function expressions, and
block-bodied arrows; and Kotlin function bodies and lambdas are included.
Brace bodies retain delimiters; Python indentation blocks collapse whole.
Expression-bodied arrows/functions have no implementation block to hide and
remain visible. Rust `extern` declarations have signatures but no bodies, so
they also remain visible. Go interfaces/grouped declarations and JSX elements
still lack fold captures. Indentation-delimited fold controls are anchored to
the preceding visible signature line rather than the hidden first body line.
Breadcrumbs and outline symbols are syntactic, not semantic.
