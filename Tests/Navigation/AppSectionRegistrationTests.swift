import Testing
@testable import MacTemplate

struct AppSectionRegistrationTests {
    @Test
    func menuOrderIsPrimaryThenSettings() {
        #expect(AppSection.menuOrder == AppSection.primary + [.settings])
        #expect(AppSection.menuOrder == [.overview, .library, .components, .settings])
    }

    @Test
    func shortcutDigitsFollowMenuOrder() {
        #expect(AppSection.overview.shortcutDigit == 1)
        #expect(AppSection.library.shortcutDigit == 2)
        #expect(AppSection.components.shortcutDigit == 3)
        #expect(AppSection.settings.shortcutDigit == 4)
    }

    @Test
    func iconsUseCatalogNames() {
        #expect(AppSection.overview.icon == AppIconName.overview)
        #expect(AppSection.library.icon == AppIconName.library)
        #expect(AppSection.components.icon == AppIconName.components)
        #expect(AppSection.settings.icon == AppIconName.settings)
    }

    @Test
    func primarySectionsThenSettings() {
        #expect(AppSection.primary == [.overview, .library, .components])
        #expect(AppSection.settings.title == "设置")
        #expect(AppSection.overview.title == "概览")
        #expect(AppSection.library.title == "资料库")
        #expect(AppSection.components.title == "基础组件")
    }
}
