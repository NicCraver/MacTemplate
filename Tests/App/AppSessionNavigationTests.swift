import Foundation
import Testing
@testable import MacTemplate

struct AppSessionNavigationTests {
    @Test
    func goToSameSectionBumpsNavigationEpoch() {
        let defaults = makeSuite("MacTemplate.AppSession.epoch")
        let session = AppSession(defaults: defaults)

        #expect(session.navigationEpoch == 0)
        session.go(to: .overview)
        #expect(session.navigationEpoch == 1)
        #expect(session.section == .overview)

        session.go(to: .library)
        #expect(session.navigationEpoch == 1)
        #expect(session.section == .library)

        session.go(to: .library)
        #expect(session.navigationEpoch == 2)

        defaults.removePersistentDomain(forName: "MacTemplate.AppSession.epoch")
    }

    @Test
    func doesNotPersistASettingsTab() {
        let defaults = makeSuite("MacTemplate.AppSession.settingsTab")
        _ = AppSession(defaults: defaults)
        #expect(defaults.object(forKey: "macTemplate.settingsTab") == nil)

        defaults.removePersistentDomain(forName: "MacTemplate.AppSession.settingsTab")
    }

    private func makeSuite(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
