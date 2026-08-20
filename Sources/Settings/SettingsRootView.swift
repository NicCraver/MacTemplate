import ChunUI
import SwiftUI

struct SettingsRootView: View {
    @Environment(AppSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        @Bindable var session = session
        MacPageScaffold(title: "设置", subtitle: "主题、品牌色和菜单栏") {
            SettingsTabPicker(tab: $session.settingsTab)
        } content: {
            tabContent
        }
        .accessibilityIdentifier("settings.page")
    }

    @ViewBuilder
    private var tabContent: some View {
        Group {
            switch session.settingsTab {
            case .general:
                GeneralSettingsView()
            case .appearance:
                AppearanceSettingsView()
            case .about:
                AboutSettingsView()
            }
        }
        .id(session.settingsTab)
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 6)))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
