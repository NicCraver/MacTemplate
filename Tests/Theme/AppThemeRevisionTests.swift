import Foundation
import Testing
@testable import MacTemplate

struct AppThemeRevisionTests {
    @Test
    func initAppliesPaletteWithoutBumpingRevision() {
        let defaults = makeSuite("MacTemplate.AppTheme.init")
        let palette = RecordingBrandPaletteApplier()

        let theme = AppTheme(defaults: defaults, palette: palette)

        #expect(theme.revision == 0)
        #expect(theme.appearance == .system)
        #expect(theme.brandHex == BrandColor.default.hex)
        #expect(palette.hexes == [BrandColor.default.hex])

        defaults.removePersistentDomain(forName: "MacTemplate.AppTheme.init")
    }

    @Test
    func writingBrandBumpsRevisionAndReappliesPalette() {
        let defaults = makeSuite("MacTemplate.AppTheme.revision")
        let palette = RecordingBrandPaletteApplier()
        let theme = AppTheme(defaults: defaults, palette: palette)

        theme.brand = BrandColor.presets[1]

        #expect(theme.brandHex == "007aff")
        #expect(theme.revision == 1)
        #expect(palette.hexes == [BrandColor.default.hex, "007aff"])
        #expect(defaults.string(forKey: PreferenceKey.brandColorHex) == "007aff")

        defaults.removePersistentDomain(forName: "MacTemplate.AppTheme.revision")
    }

    @Test
    func appearanceChangeDoesNotBumpRevision() {
        let defaults = makeSuite("MacTemplate.AppTheme.appearance")
        let palette = RecordingBrandPaletteApplier()
        let theme = AppTheme(defaults: defaults, palette: palette)
        let applied = palette.hexes.count

        theme.appearance = .dark

        #expect(theme.revision == 0)
        #expect(palette.hexes.count == applied)
        #expect(defaults.string(forKey: PreferenceKey.appearanceMode) == "dark")

        defaults.removePersistentDomain(forName: "MacTemplate.AppTheme.appearance")
    }

    private func makeSuite(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
