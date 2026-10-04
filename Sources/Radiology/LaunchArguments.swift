import Foundation

/// Development launch arguments: `--repository PATH` opens a folder and the
/// optional `--file RELATIVE_PATH` selects a file inside it, which makes
/// launching straight into a given language reproducible.
/// `--verify-resources` is handled before any window is created.
struct LaunchArguments {
    let repository: String?
    let file: String?

    init(_ arguments: [String]) {
        repository = Self.value(of: "--repository", in: arguments)
        file = Self.value(of: "--file", in: arguments)
    }

    private static func value(of flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.count > index + 1 else { return nil }
        return arguments[index + 1]
    }
}
