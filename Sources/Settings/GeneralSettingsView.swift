import ChunUI
import SwiftUI

struct GeneralSettingsView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        @Bindable var session = session
        SettingsGroupCard("菜单栏") {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("在菜单栏显示图标")
                        .ccText(font: .cc.base, color: .cc.foreground)
                    Text("关闭后仍可从侧栏打开设置。")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 12)
                Toggle("在菜单栏显示图标", isOn: $session.showStatusBar)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .tint(Color.cc.primary)
                    .accessibilityIdentifier("settings.statusBar")
            }
            .padding(16)
        }
    }
}
