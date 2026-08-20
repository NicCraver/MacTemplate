import SwiftUI

struct AppCommands: Commands {
    @Bindable var session: AppSession
    @Environment(\.openWindow) private var openWindow
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("关于 \(AppInfo.displayName)") {
                openWindow(id: "about")
            }
        }

        CommandGroup(replacing: .appSettings) {
            Button("设置…") {
                session.go(to: .settings)
            }
            .keyboardShortcut(",", modifiers: .command)
        }

        CommandMenu("前往") {
            ForEach(AppSection.menuOrder) { section in
                goButton(section)
            }
        }

        CommandGroup(replacing: .sidebar) {
            Button(session.sidebarExpanded ? "隐藏边栏" : "显示边栏") {
                toggleSidebar()
            }
            .keyboardShortcut("s", modifiers: [.command, .control])
        }
    }

    @ViewBuilder
    private func goButton(_ section: AppSection) -> some View {
        if let key = section.keyEquivalent {
            Button(section.title) {
                session.go(to: section)
            }
            .keyboardShortcut(key, modifiers: .command)
        } else {
            Button(section.title) {
                session.go(to: section)
            }
        }
    }

    private func toggleSidebar() {
        if reduceMotion {
            session.sidebarExpanded.toggle()
        } else {
            withAnimation(MacChrome.sidebarAnimation) {
                session.sidebarExpanded.toggle()
            }
        }
    }
}
