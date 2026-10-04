import Foundation

struct SourceLocation: Hashable, Sendable {
    let path: String
    let byteOffset: Int
}
