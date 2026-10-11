import SwiftUI

/// The right inspector: the enclosing declaration and its references above,
/// the symbol under the caret (or the outline) immediately below. Model state
/// remains independently keyed. Native dividers resize the three independently
/// scrolling regions without changing their selection or disclosure state.
struct ContextInspectorView: View {
    var body: some View {
        VSplitView {
            DeclarationRegionView()
                .frame(minHeight: Theme.inspectorReferencesMinHeight, maxHeight: .infinity, alignment: .topLeading)
            VSplitView {
                UnderCaretRegionView()
                    .frame(minHeight: Theme.inspectorDefinitionMinHeight, maxHeight: .infinity, alignment: .topLeading)
                BookmarksPane()
                    .frame(minHeight: Theme.inspectorBookmarksMinHeight, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(minHeight: Theme.inspectorDefinitionMinHeight + Theme.inspectorBookmarksMinHeight + 1,
                   maxHeight: .infinity)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .inspectorColumnWidth(min: Theme.inspectorMinWidth, ideal: Theme.inspectorIdealWidth, max: Theme.inspectorMaxWidth)
    }
}
