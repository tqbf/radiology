import SwiftUI

/// Compact sidebar tabs with native buttons, selected traits, and arrow navigation.
struct SidebarModeTabs: View {
    let modes: [BrowserMode]
    @Binding var selection: BrowserMode
    @FocusState private var focusedMode: BrowserMode?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(modes) { mode in
                    Button {
                        selection = mode
                        focusedMode = mode
                    } label: {
                        Text(mode.rawValue)
                            .font(Theme.Fonts.body)
                            .fontWeight(selection == mode ? .semibold : .regular)
                            .foregroundStyle(selection == mode ? .primary : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.spacing)
                            .contentShape(.rect)
                            .overlay(alignment: .bottom) {
                                Rectangle().fill(.tint).frame(height: 2)
                                    .opacity(selection == mode ? 1 : 0)
                            }
                    }
                    .buttonStyle(.plain)
                    .focusable()
                    .focused($focusedMode, equals: mode)
                    .accessibilityLabel("\(mode.rawValue) tab")
                    .accessibilityAddTraits(selection == mode ? .isSelected : [])
                    .help("Show \(mode.rawValue) in the sidebar")
                }
            }
            .padding(.horizontal, Theme.inset)
            Divider()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Sidebar modes")
        .onKeyPress(.leftArrow) { moveSelection(by: -1) }
        .onKeyPress(.rightArrow) { moveSelection(by: 1) }
    }

    private func moveSelection(by direction: Int) -> KeyPress.Result {
        guard let index = modes.firstIndex(of: selection), !modes.isEmpty else { return .ignored }
        let next = modes[(index + direction + modes.count) % modes.count]
        selection = next
        focusedMode = next
        return .handled
    }
}
