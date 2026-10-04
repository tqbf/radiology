 enum BrowserMode: String, CaseIterable, Identifiable {
    case files = "Files"
    case search = "Search"
    var id: Self { self }
}

/// What the right inspector shows.
enum InspectorMode: String, CaseIterable, Identifiable {
    case outline = "Outline"
    case semantics = "Symbol"
    var id: Self { self }
}
