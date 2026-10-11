import SwiftUI

struct ReviewChangeStatus: View {
    let status: FileChange.Status

    var body: some View {
        Group {
            if status == .modified {
                Text("M").font(Theme.Fonts.changeStatus)
            } else {
                Image(systemName: status.systemImage).font(Theme.Fonts.meta)
            }
        }
        .foregroundStyle(.secondary)
        .frame(width: 16, height: 18)
        .accessibilityLabel(status.title)
    }
}
