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
}
