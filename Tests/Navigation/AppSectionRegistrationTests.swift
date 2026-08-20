import Testing
@testable import MacTemplate

struct AppSectionRegistrationTests {
    @Test
    func menuOrderIsPrimaryThenSettings() {
        #expect(AppSection.menuOrder == AppSection.primary + [.settings])
        #expect(AppSection.menuOrder == [.overview, .library, .settings])
    }

    @Test
    func shortcutDigitsFollowMenuOrder() {
        #expect(AppSection.overview.shortcutDigit == 1)
        #expect(AppSection.library.shortcutDigit == 2)
        #expect(AppSection.settings.shortcutDigit == 3)
    }

    @Test
    func iconsUseCatalogNames() {
        #expect(AppSection.overview.icon == AppIconName.overview)
        #expect(AppSection.library.icon == AppIconName.library)
        #expect(AppSection.settings.icon == AppIconName.settings)
        #expect(SettingsTab.general.icon == AppIconName.settings)
        #expect(SettingsTab.appearance.icon == AppIconName.appearance)
        #expect(SettingsTab.about.icon == AppIconName.about)
    }

    @Test
    func twoBusinessSections() {
        #expect(AppSection.primary == [.overview, .library])
        #expect(AppSection.settings.title == "设置")
        #expect(AppSection.overview.title == "概览")
        #expect(AppSection.library.title == "资料库")
    }
}
