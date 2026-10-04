import SwiftUI

@main
struct RadiologyApp: App {
    @State private var model = AppModel()

    init() {
        guard CommandLine.arguments.contains("--verify-resources") else { return }
        let result = ResourceVerification.run()
        print(result.report)
        exit(result.isComplete ? 0 : 1)
    }

    var body: some Scene {
        Window("Radiology", id: "reader") {
            RootView()
                .environment(model)
                .frame(minWidth: Theme.windowMinWidth, minHeight: Theme.windowMinHeight)
                .task {
                    let arguments = LaunchArguments(CommandLine.arguments)
                    guard let repository = arguments.repository else { return }
                    await model.openRepository(URL(filePath: repository), selecting: arguments.file)
                }
        }
        .defaultSize(width: Theme.windowDefaultWidth, height: Theme.windowDefaultHeight)
        .windowResizability(.contentMinSize)
        .commands { ReaderCommands(model: model) }
    }
}
