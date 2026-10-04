 enum ReaderSheet: String, Identifiable {
    case files, line, symbols
    var id: Self { self }
}
