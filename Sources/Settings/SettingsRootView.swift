import ChunUI
import SwiftUI

struct SettingsRootView: View {
    var body: some View {
        MacPageScaffold(title: "设置", subtitle: "主题、品牌色和菜单栏") {
            AppearanceSettingsView()
            GeneralSettingsView()
        }
        .accessibilityIdentifier("settings.page")
    }
}
