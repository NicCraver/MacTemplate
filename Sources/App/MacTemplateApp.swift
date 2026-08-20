import ChunUI
import SwiftUI

@main
struct MacTemplateApp: App {
    @State private var theme = AppTheme()
    @State private var session = AppSession()

    var body: some Scene {
        WindowGroup(id: "main") {
            RootSplitView()
                .environment(theme)
                .environment(session)
                .preferredColorScheme(theme.appearance.colorScheme)
                .id(theme.revision)
        }
        .defaultSize(width: 1100, height: 740)
        .windowResizability(.contentMinSize)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            AppCommands(session: session)
        }

        Window("关于 \(AppInfo.displayName)", id: "about") {
            AboutView()
                .environment(theme)
                .preferredColorScheme(theme.appearance.colorScheme)
                .id(theme.revision)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra(isInserted: statusBarInserted) {
            StatusBarMenu()
                .environment(theme)
                .environment(session)
        } label: {
            StatusBarLabel()
        }
        .menuBarExtraStyle(.menu)
    }

    private var statusBarInserted: Binding<Bool> {
        Binding(
            get: { session.showStatusBar },
            set: { session.showStatusBar = $0 }
        )
    }
}
