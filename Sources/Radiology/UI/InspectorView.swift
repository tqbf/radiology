import SwiftUI

/// The right inspector: the structural outline or the semantic symbol pane.
struct InspectorView: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            Picker("Inspector", selection: $model.inspectorMode) {
                ForEach(InspectorMode.allCases) { mode in Text(mode.rawValue).tag(mode) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(Theme.inset)
            Divider()
            switch model.inspectorMode {
            case .outline: DocumentOutlineView()
            case .semantics: SemanticInspectorView()
            }
        }
        .inspectorColumnWidth(min: Theme.inspectorMinWidth, ideal: Theme.inspectorIdealWidth, max: Theme.inspectorMaxWidth)
    }
}
