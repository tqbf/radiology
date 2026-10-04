# Design and typography

The first version follows the macos-design, typography-designer, and swiftui-pro skills. The typography skill is available locally at `/Users/agentzero/.claude/skills/typography-designer/SKILL.md` even though it was absent from the initial Codex catalog.

## Layout

A native NavigationSplitView contains a resizable repository sidebar, source surface, and delivered Outline/Symbol inspector. Use system window chrome, traffic lights, toolbar, segmented picker, lists, open panel, and sheets. No simulated chrome, editor tabs, large dashboard cards, or decorative gradients.

Files and Search are sidebar modes. The toolbar holds back/forward, outline visibility, file lookup, repository search, and open. A quiet source header shows the relative path and Finder reveal; a footer shows language, line count, selected line, and read-only UTF-8 status. Empty states use ContentUnavailableView, with an actionable open button and recent folders on first launch.

## Typography specification

| Role | Family / style | Weight | Leading / usage |
| --- | --- | --- | --- |
| Native controls and file rows | System SF, semantic body | Regular | System leading; standard Mac density |
| Sheet and recent-folder headings | System SF, semantic headline | System emphasis | System leading; one level above body |
| Paths, counts, status, hints | System SF, semantic callout | Regular | Secondary foreground, never thin weight |
| Source and result previews | System monospace (SF Mono fallback) | Regular | Source starts at 14 pt with 22 pt line height |
| Line numbers | System tabular monospace digits | Regular | Source size minus 1; aligned to source line boxes |
| Symbol name under caret | System SF, semantic body | Semibold | The one emphasized element of the Symbol inspector card |
| Canonical symbol IDs, indexer command lines, tool output | System monospace, semantic caption | Regular | Secondary foreground, selectable, truncated in the middle |

All fonts and repeated metrics live in Theme. Code size is adjustable from 11–28 pt with the View menu and Cmd-plus/minus. Source leading is max(22, size × 1.55), keeping comfortable spacing as text enlarges. Source remains horizontally scrollable to preserve code indentation rather than imposing a prose measure. Native semantic fonts track system metrics. Body text and source use the system primary text colors; metadata uses secondary colors, and current-line tint is subdued. Background and label colors automatically adapt to light and dark appearances.

## Interaction and accessibility

| Shortcut | Action |
| --- | --- |
| Cmd-O | Open repository |
| Cmd-K / Cmd-P | Go to file (Cmd-K primary, Cmd-P alias) |
| Cmd-Shift-F | Repository search |
| Cmd-F | Native find within source, when source has focus |
| Cmd-G / Cmd-Shift-G | Next / previous in-file match |
| Cmd-L | Go to line |
| Cmd-[ / Cmd-] | Back / forward |
| Cmd-R | Reload repository and visible source |
| Cmd-plus / Cmd-minus | Source text size |
| Cmd-T | Go to symbol (semantic index) |
| Ctrl-Cmd-J | Go to Definition at caret; Cmd-click an identifier does the same |
| Ctrl-Cmd-R | Find References at caret (also in the source context menu) |
| Ctrl-Cmd-I | Repository > Reindex; Cancel Indexing while running |

Icon buttons retain explicit text labels and shortcut help. The source exposes a read-only accessibility label, selection and copy use native text interactions, and lists/sheets use native keyboard focus. Finder folder drops open repositories. File reveal supplies the reverse connection to Finder. No custom motion is introduced, so reduced-motion preferences are respected without an animation branch.

The native inspector presents the current file's hierarchical outline with semantic body typography and system symbols. Syntax colours use Apple's dynamic system palette. The source footer reports language and parse status. The 104-point gutter uses restrained medium-weight disclosure markers in a 28-point-wide, full-line hit region. Collapsed functions add a three-point secondary-label logarithmic meter (6–22 points) and a distinct neutral capsule with the exact hidden-source-line count in 9-point medium tabular monospace. Separate lanes keep that count visually distinct from regular source-size canonical line numbers. Tooltip and accessibility help repeat the full count. Shape, length, and digits convey size without warning color. Hidden TextKit glyphs never receive stacked labels or nested meters; visible fragments retain their original source numbers. A compact semantic-callout breadcrumb row shows repository, path, and enclosing declarations. Cmd-K opens a compact native file-search sheet with immediate field focus, filename-first rows, a secondary relative directory, persistent keyboard selection, and an explicit result/refinement count.

Occurrence locks use four restrained dynamic system hues—teal, amber/orange,
violet, and rose—at translucent fills tuned separately for light and dark
appearance. A 1.4-point outline makes the locked state distinct from the plain
accent wash without relying on hue alone. Slots cycle for additional locks;
existing locks retain their assigned slot until removed. Text color, font,
selection, and layout are never changed. Source accessibility help reports the
number of locked groups and occurrences and explains the double-click toggle.

The inspector gains a segmented Outline / Symbol switch. The Symbol pane is a restrained debug-grade card: name (semibold body), kind, canonical SCIP identifier (caption monospace, selectable), definition location, reference count, index state, then Find References results grouped by file with line numbers and monospace line text. The footer carries an unobtrusive index-state label with a system symbol (No Index, Indexing…, Index Current, Index Stale, Index Failed); clicking it opens a 440-point popover with the indexer, version, command line, exit status, bounded output, Reindex/Cancel, and an Install button when a managed tool is missing. ⌘-hover on a resolvable identifier underlines it in the accent color with a pointing hand; nothing appears where there is no in-repository target. Current scope limits: source restoration is line-based; quick file lookup uses ordered-subsequence fuzzy matching and presents the best 100 results with a truthful total; ⌘T symbol ranking is exact > prefix > initials > subsequence and caps presentation at 200 symbols.
