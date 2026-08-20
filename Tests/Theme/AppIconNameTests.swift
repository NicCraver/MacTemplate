import Testing
@testable import MacTemplate

struct AppIconNameTests {
    @Test
    func catalogMatchesPikaAssets() {
        #expect(AppIconName.overview == "grid-dashboard-bento")
        #expect(AppIconName.library == "folder-default")
        #expect(AppIconName.components == "diamond-component")
        #expect(AppIconName.settings == "settings01")
        #expect(AppIconName.search == "search-default")
        #expect(AppIconName.document == "file-text")
        #expect(AppIconName.tokens == "color-palette")
        #expect(AppIconName.checklist == "list-check-box")
        #expect(AppIconName.note == "note-outline")
        #expect(AppIconName.close == "multiple-cross-cancel-default")
    }
}
