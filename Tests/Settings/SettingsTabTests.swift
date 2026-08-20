import Testing
@testable import MacTemplate

struct SettingsTabTests {
    @Test
    func titlesInOrder() {
        #expect(SettingsTab.allCases.map(\.title) == ["通用", "外观", "关于"])
    }

    @Test
    func preferencePrefixIsShared() {
        #expect(PreferenceKey.appearanceMode.hasPrefix("\(PreferenceKey.prefix)."))
        #expect(PreferenceKey.brandColorHex.hasPrefix("\(PreferenceKey.prefix)."))
        #expect(PreferenceKey.showStatusBar.hasPrefix("\(PreferenceKey.prefix)."))
        #expect(PreferenceKey.settingsTab.hasPrefix("\(PreferenceKey.prefix)."))
        #expect(PreferenceKey.prefix == "macTemplate")
    }
}
