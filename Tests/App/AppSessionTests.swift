import Foundation
import Testing
@testable import MacTemplate

struct AppSessionTests {
    @Test
    func statusBarDefaultsOn() {
        let suite = "MacTemplate.AppSession.statusBar"
        guard let defaults = UserDefaults(suiteName: suite) else {
            Issue.record("failed to create defaults suite")
            return
        }
        defaults.removePersistentDomain(forName: suite)

        let session = AppSession(defaults: defaults)
        #expect(session.showStatusBar == true)
        #expect(defaults.bool(forKey: AppSession.statusBarKey) == true)

        session.showStatusBar = false
        #expect(defaults.bool(forKey: AppSession.statusBarKey) == false)

        defaults.removePersistentDomain(forName: suite)
    }

    @Test
    func sidebarStartsExpanded() {
        let suite = "MacTemplate.AppSession.sidebar"
        guard let defaults = UserDefaults(suiteName: suite) else {
            Issue.record("failed to create defaults suite")
            return
        }
        defaults.removePersistentDomain(forName: suite)

        let session = AppSession(defaults: defaults)
        #expect(session.sidebarExpanded == true)

        session.sidebarExpanded = false
        #expect(session.sidebarExpanded == false)

        defaults.removePersistentDomain(forName: suite)
    }
}
