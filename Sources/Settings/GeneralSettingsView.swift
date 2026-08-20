import ChunUI
import SwiftUI

struct GeneralSettingsView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        @Bindable var session = session
        SettingsGroupCard("菜单栏") {
            Toggle(isOn: $session.showStatusBar) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("在菜单栏显示图标")
                        .ccText(font: .cc.base, color: .cc.foreground)
                    Text("关闭后仍可从侧栏底部或程序坞打开本页。")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .toggleStyle(.switch)
            .tint(Color.cc.primary)
            .padding(16)
            .accessibilityIdentifier("settings.statusBar")
        }
    }
}
