import Testing
@testable import MacTemplate

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
        #expect(PreferenceKey.prefix == "macTemplate")
    }
}
