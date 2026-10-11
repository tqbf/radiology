enum BrowserMode: String, CaseIterable, Identifiable {
    case changes = "Changes"
    case files = "Files"
    case search = "Search"
    var id: Self { self }

    /// Changes exists only while a pull request is under review.
    static func available(reviewing: Bool) -> [BrowserMode] {
        reviewing ? allCases : [.files, .search]
    }
}
