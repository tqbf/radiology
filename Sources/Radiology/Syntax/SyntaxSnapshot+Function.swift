import Foundation

extension SyntaxSnapshot {
    /// Tree-sitter symbol kinds that are callables with their own body.
    static let callableKinds: Set<String> = ["function", "method", "initializer", "deinitializer"]

    /// The innermost function, method, or initializer whose declaration
    /// (signature through body, half-open) contains the byte. Types, `impl`
    /// blocks, modules, and properties never qualify, so the caret between
    /// methods yields nil rather than the whole container.
    func innermostFunction(at byte: Int) -> DocumentSymbol? {
        var best: DocumentSymbol?
        for symbol in symbols where Self.callableKinds.contains(symbol.kind) && symbol.byteRange.contains(byte) {
            if best == nil || symbol.byteRange.count < best!.byteRange.count { best = symbol }
        }
        return best
    }
}
