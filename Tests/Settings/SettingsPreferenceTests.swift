import Testing
@testable import AppList

struct SettingsPreferenceTests {
    @Test
    func knownKeysSharePrefix() {
        let keys = [
            PreferenceKey.appearanceMode,
            PreferenceKey.brandColorHex,
            PreferenceKey.showStatusBar,
        ]
        for key in keys {
            #expect(key.hasPrefix("\(PreferenceKey.prefix)."))
        }
        #expect(PreferenceKey.prefix == "appList")
    }
}
