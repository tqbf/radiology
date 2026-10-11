 enum ReaderSheet: String, Identifiable {
    case files, line, symbols, pullRequest
    var id: Self { self }
}
