import Testing
@testable import MacTemplate

struct AppWindowsTests {
    @Test
    func mainWindowIdentifiers() {
        #expect(AppWindows.isMainWindow(identifier: "main"))
        #expect(AppWindows.isMainWindow(identifier: "main-2"))
        #expect(!AppWindows.isMainWindow(identifier: "about"))
        #expect(!AppWindows.isMainWindow(identifier: nil))
        #expect(!AppWindows.isMainWindow(identifier: ""))
    }
}
