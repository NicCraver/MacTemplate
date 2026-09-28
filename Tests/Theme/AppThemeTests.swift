import Foundation
import Testing
@testable import AppList

struct AppThemeTests {
    @Test
    func unknownStoredValuesFallBack() {
        let suite = "AppList.AppTheme.fallback"
        guard let defaults = UserDefaults(suiteName: suite) else {
            Issue.record("failed to create defaults suite")
            return
        }
        defaults.removePersistentDomain(forName: suite)
        defaults.set("nope", forKey: AppTheme.appearanceKey)
        defaults.set("zzzzzz", forKey: AppTheme.brandKey)

        let theme = AppTheme(defaults: defaults, palette: RecordingBrandPaletteApplier())
        #expect(theme.appearance == .system)
        #expect(theme.brandHex == BrandColor.default.hex)

        defaults.removePersistentDomain(forName: suite)
    }

    @Test
    func writingBrandUpdatesHex() {
        let suite = "AppList.AppTheme.write"
        guard let defaults = UserDefaults(suiteName: suite) else {
            Issue.record("failed to create defaults suite")
            return
        }
        defaults.removePersistentDomain(forName: suite)

        let theme = AppTheme(defaults: defaults, palette: RecordingBrandPaletteApplier())
        theme.brand = BrandColor.presets[1]
        #expect(theme.brandHex == BrandColor.presets[1].hex)
        #expect(defaults.string(forKey: AppTheme.brandKey) == BrandColor.presets[1].hex)

        defaults.removePersistentDomain(forName: suite)
    }
}
