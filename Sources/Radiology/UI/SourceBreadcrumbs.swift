import SwiftUI

struct SourceBreadcrumbs: View {
    let rootName: String
    let path: String
    let symbols: [DocumentSymbol]
    let canCollapseFunctions: Bool
    let collapseFunctions: () -> Void
    let select: (DocumentSymbol) -> Void

    var body: some View {
        HStack(spacing: Theme.breadcrumbSpacing) {
                breadcrumb(rootName, icon: "externaldrive")
                ForEach(Array(path.split(separator: "/").enumerated()), id: \.offset) { _, component in
                    separator
                    breadcrumb(String(component), icon: nil)
                }
                ForEach(symbols) { symbol in
                    separator
                    Button(symbol.name) { select(symbol) }
                        .buttonStyle(.plain)
                        .help("Go to \(symbol.name)")
                }
            Spacer(minLength: 0)
            Button("Collapse Functions", systemImage: "arrow.down.right.and.arrow.up.left") {
                collapseFunctions()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
            .disabled(!canCollapseFunctions)
            .help("Collapse Functions")
            .accessibilityLabel("Collapse Functions")
        }
        .font(Theme.Fonts.meta)
        .padding(.horizontal, Theme.inset)
        .frame(minHeight: Theme.breadcrumbHeight)
        .accessibilityElement(children: .contain)
    }

    private func breadcrumb(_ title: String, icon: String?) -> some View {
        Group {
            if let icon {
                Label(title, systemImage: icon)
            } else {
                Text(title)
            }
        }
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }

    private var separator: some View {
        Image(systemName: "chevron.right")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .accessibilityHidden(true)
    }
}
