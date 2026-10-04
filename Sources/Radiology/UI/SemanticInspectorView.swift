import SwiftUI

/// The inspector's Symbol pane: what is under the caret, its definitions, and
/// the latest Find References results grouped by file.
struct SemanticInspectorView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        List {
            if let target = model.semantics.caretTarget {
                Section("Under Caret") {
                    SemanticTargetCard(target: target, status: model.semantics.status)
                    if target.definitions.count > 1 || (target.definitions.count == 1 && target.isOnDefinition) {
                        ForEach(Array(target.definitions.enumerated()), id: \.offset) { _, position in
                            Button { model.navigate(toDefinition: position) } label: {
                                Label("\(position.path):\(position.range.startLine + 1)", systemImage: "arrow.turn.down.right")
                                    .font(Theme.Fonts.meta).lineLimit(1).truncationMode(.middle)
                            }.buttonStyle(.plain)
                        }
                    }
                    ViewThatFits(in: .horizontal) {
                        HStack {
                            Button("Go to Definition", action: model.goToDefinitionAtCaret).disabled(!target.hasDefinition)
                            Button("Find References") { model.semantics.findReferences(of: target.symbol) }
                        }
                        VStack(alignment: .leading) {
                            Button("Go to Definition", action: model.goToDefinitionAtCaret).disabled(!target.hasDefinition)
                            Button("Find References") { model.semantics.findReferences(of: target.symbol) }
                        }
                    }
                    .controlSize(.small)
                }
            } else {
                Section("Under Caret") {
                    Text(caretHint).font(Theme.Fonts.meta).foregroundStyle(.secondary)
                }
            }
            if let error = model.semantics.navigationError {
                Section { Label(error, systemImage: "info.circle").font(Theme.Fonts.meta).foregroundStyle(.secondary) }
            }
            if model.semantics.isFindingReferences {
                Section("References") { ProgressView("Finding references…").controlSize(.small) }
            } else if let error = model.semantics.referencesError {
                Section("References") { Label(error, systemImage: "exclamationmark.triangle").font(Theme.Fonts.meta) }
            } else if let references = model.semantics.references {
                Section {
                    ForEach(references.groups) { group in
                        ReferenceGroupView(group: group) { hit in
                            model.navigateSemantically(from: model.currentCaretLocation ?? hit.location, to: hit.location)
                        }
                    }
                    if references.unmappedCount > 0 {
                        Text("\(references.unmappedCount) occurrences no longer match the files on disk.")
                            .font(Theme.Fonts.meta).foregroundStyle(.secondary)
                    }
                } header: {
                    HStack {
                        Text("References to \(references.displayName)")
                        Spacer()
                        Text("\(references.total) in \(references.groups.count) files").font(Theme.Fonts.meta).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }

    private var caretHint: String {
        guard model.source != nil else { return "Open a file to inspect symbols." }
        switch model.semantics.status {
        case .indexing(let progress): return progress.message
        case .noIndex(let reason): return reason
        case .failed(let failure): return failure.message
        default: break
        }
        if model.semantics.documentSemantics == nil { return "This file is not covered by the semantic index." }
        return "Place the caret on an identifier."
    }
}

/// Debug-grade detail kept readable: name, kind, canonical ID, definition, references, state.
struct SemanticTargetCard: View {
    let target: SemanticTarget
    let status: SemanticIndexStatus
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing / 2) {
            HStack(alignment: .firstTextBaseline, spacing: Theme.spacing) {
                Image(systemName: target.kind.systemImage).foregroundStyle(.secondary).accessibilityHidden(true)
                Text(target.displayName).font(Theme.Fonts.body.weight(.semibold))
                Text(target.kind.name).font(Theme.Fonts.meta).foregroundStyle(.secondary)
            }
            Text(target.symbol.description)
                .font(Theme.Fonts.identifier).foregroundStyle(.secondary)
                .lineLimit(3).truncationMode(.middle).textSelection(.enabled)
                .accessibilityLabel("Symbol identifier")
            Text(definitionText).font(Theme.Fonts.meta).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
            Text("\(target.referenceCount) references · Index \(status.label.lowercased())").font(Theme.Fonts.meta).foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var definitionText: String {
        if target.isOnDefinition { return "Defined here" }
        guard let first = target.definitions.first else { return "Defined outside this repository" }
        let extra = target.definitions.count > 1 ? " and \(target.definitions.count - 1) more" : ""
        return "Defined in \(first.path):\(first.range.startLine + 1)\(extra)"
    }
}

struct ReferenceGroupView: View {
    let group: ReferenceGroup
    let open: (ReferenceHit) -> Void
    @State private var isExpanded = true
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(group.hits) { hit in
                Button { open(hit) } label: {
                    HStack(alignment: .firstTextBaseline, spacing: Theme.spacing) {
                        Text("\(hit.line)").font(Theme.Fonts.meta).foregroundStyle(.secondary).monospacedDigit().frame(minWidth: 32, alignment: .trailing)
                        Text(hit.lineText.trimmingCharacters(in: .whitespaces)).font(Theme.Fonts.codePreview).lineLimit(1).truncationMode(.tail)
                        if hit.isDefinition { Text("definition").font(Theme.Fonts.meta).foregroundStyle(.secondary) }
                    }.frame(maxWidth: .infinity, alignment: .leading).contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Line \(hit.line)\(hit.isDefinition ? ", definition" : ""): \(hit.lineText.trimmingCharacters(in: .whitespaces))")
            }
        } label: {
            HStack {
                Label(group.path, systemImage: "doc.text").font(Theme.Fonts.meta).lineLimit(1).truncationMode(.middle)
                Spacer()
                Text("\(group.hits.count)").font(Theme.Fonts.meta).foregroundStyle(.secondary)
            }
        }
    }
}
