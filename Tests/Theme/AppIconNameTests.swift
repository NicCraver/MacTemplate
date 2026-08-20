import Testing
@testable import MacTemplate

struct AppIconNameTests {
    @Test
    func catalogMatchesPikaAssets() {
        #expect(AppIconName.overview == "grid-dashboard-bento")
        #expect(AppIconName.library == "folder-default")
        #expect(AppIconName.settings == "settings01")
        #expect(AppIconName.appearance == "color-palette")
        #expect(AppIconName.about == "information-circle")
        #expect(AppIconName.search == "search-default")
    }
}
