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
    func settingsTabPersists() {
        let defaults = makeSuite("MacTemplate.AppSession.settingsTab")
        let session = AppSession(defaults: defaults)
        #expect(session.settingsTab == .general)

        session.settingsTab = .appearance
        #expect(defaults.string(forKey: PreferenceKey.settingsTab) == "appearance")

        let restored = AppSession(defaults: defaults)
        #expect(restored.settingsTab == .appearance)

        defaults.removePersistentDomain(forName: "MacTemplate.AppSession.settingsTab")
    }

    private func makeSuite(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
