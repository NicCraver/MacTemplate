import Testing
@testable import MacTemplate

struct LibraryNavigationTests {
    @Test
    func escapeClearsSearchBeforePopping() {
        #expect(LibraryNavigation.escapeAction(query: "brief", pathCount: 0) == .clearSearch)
        #expect(LibraryNavigation.escapeAction(query: "  ", pathCount: 1) == .pop)
        #expect(LibraryNavigation.escapeAction(query: "", pathCount: 0) == .none)
        #expect(LibraryNavigation.escapeAction(query: "x", pathCount: 2) == .pop)
    }

    @Test
    func enterOpensFirstMatch() {
        #expect(
            LibraryNavigation.firstMatch(LibraryItem.placeholders, query: "清单")?.id
                == "release"
        )
        #expect(LibraryNavigation.firstMatch(LibraryItem.placeholders, query: "xyz") == nil)
        #expect(
            LibraryNavigation.firstMatch(LibraryItem.placeholders, query: "")?.id == "brief"
        )
    }

    @Test
    func searchFocusOnlyOnRoot() {
        #expect(LibraryNavigation.canFocusSearch(pathCount: 0))
        #expect(!LibraryNavigation.canFocusSearch(pathCount: 1))
    }
}
