import Foundation
import Testing
@testable import AppList

struct AppSessionNavigationTests {
    @Test
    func goToSameSectionBumpsNavigationEpoch() {
        let defaults = makeSuite("AppList.AppSession.epoch")
        let session = AppSession(defaults: defaults)

        #expect(session.navigationEpoch == 0)
        session.go(to: .apps)
        #expect(session.navigationEpoch == 1)
        #expect(session.section == .apps)

        session.go(to: .settings)
        #expect(session.navigationEpoch == 1)
        #expect(session.section == .settings)

        session.go(to: .settings)
        #expect(session.navigationEpoch == 2)

        defaults.removePersistentDomain(forName: "AppList.AppSession.epoch")
    }

    @Test
    func startsOnAppsSection() {
        let defaults = makeSuite("AppList.AppSession.startSection")
        let session = AppSession(defaults: defaults)
        #expect(session.section == .apps)
        defaults.removePersistentDomain(forName: "AppList.AppSession.startSection")
    }

    @Test
    func doesNotPersistASettingsTab() {
        let defaults = makeSuite("AppList.AppSession.settingsTab")
        _ = AppSession(defaults: defaults)
        #expect(defaults.object(forKey: "appList.settingsTab") == nil)

        defaults.removePersistentDomain(forName: "AppList.AppSession.settingsTab")
    }

    private func makeSuite(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
