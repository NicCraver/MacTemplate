import AppKit
import SwiftUI

struct StatusBarMenu: View {
    @Environment(AppSession.self) private var session
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("打开 \(AppInfo.displayName)") {
            AppWindows.showMain(openWindow: openWindow)
        }
        Divider()
        ForEach(AppSection.primary) { section in
            Button(section.title) {
                session.go(to: section)
                AppWindows.showMain(openWindow: openWindow)
            }
        }
        Divider()
        Button(AppSection.settings.title) {
            session.go(to: .settings)
            AppWindows.showMain(openWindow: openWindow)
        }
        Button("关于 \(AppInfo.displayName)") {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "about")
        }
        Divider()
        Button("退出 \(AppInfo.displayName)") {
            NSApp.terminate(nil)
        }
    }
}

struct StatusBarLabel: View {
    var body: some View {
        Image("StatusBarIcon")
            .renderingMode(.template)
            .accessibilityLabel(AppInfo.displayName)
    }
}
