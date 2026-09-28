import Foundation
import Testing
@testable import AppList

struct AppThemeRevisionTests {
    @Test
    func initAppliesPaletteWithoutBumpingRevision() {
        let defaults = makeSuite("AppList.AppTheme.init")
        let palette = RecordingBrandPaletteApplier()

        let theme = AppTheme(defaults: defaults, palette: palette)

        #expect(theme.revision == 0)
        #expect(theme.appearance == .system)
        #expect(theme.brandHex == BrandColor.default.hex)
        #expect(palette.hexes == [BrandColor.default.hex])

        defaults.removePersistentDomain(forName: "AppList.AppTheme.init")
    }

    @Test
    func writingBrandBumpsRevisionAndReappliesPalette() {
        let defaults = makeSuite("AppList.AppTheme.revision")
        let palette = RecordingBrandPaletteApplier()
        let theme = AppTheme(defaults: defaults, palette: palette)

        theme.brand = BrandColor.presets[1]

        #expect(theme.brandHex == BrandColor.presets[1].hex)
        #expect(theme.revision == 1)
        #expect(palette.hexes == [BrandColor.default.hex, BrandColor.presets[1].hex])
        #expect(defaults.string(forKey: PreferenceKey.brandColorHex) == BrandColor.presets[1].hex)

        defaults.removePersistentDomain(forName: "AppList.AppTheme.revision")
    }

    @Test
    func appearanceChangeDoesNotBumpRevision() {
        let defaults = makeSuite("AppList.AppTheme.appearance")
        let palette = RecordingBrandPaletteApplier()
        let theme = AppTheme(defaults: defaults, palette: palette)
        let applied = palette.hexes.count

        theme.appearance = .dark

        #expect(theme.revision == 0)
        #expect(palette.hexes.count == applied)
        #expect(defaults.string(forKey: PreferenceKey.appearanceMode) == "dark")

        defaults.removePersistentDomain(forName: "AppList.AppTheme.appearance")
    }

    private func makeSuite(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
