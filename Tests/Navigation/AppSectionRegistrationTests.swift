import Testing
@testable import AppList

struct AppSectionRegistrationTests {
    @Test
    func menuOrderIsPrimaryThenSettings() {
        #expect(AppSection.menuOrder == AppSection.primary + [.settings])
        #expect(AppSection.menuOrder == [.apps, .settings])
    }

    @Test
    func shortcutDigitsFollowMenuOrder() {
        #expect(AppSection.apps.shortcutDigit == 1)
        #expect(AppSection.settings.shortcutDigit == 2)
    }

    @Test
    func iconsUseCatalogNames() {
        #expect(AppSection.apps.icon == AppIconName.apps)
        #expect(AppSection.settings.icon == AppIconName.settings)
    }

    @Test
    func primarySectionsThenSettings() {
        #expect(AppSection.primary == [.apps])
        #expect(AppSection.settings.title == "设置")
        #expect(AppSection.apps.title == "应用")
    }
}
