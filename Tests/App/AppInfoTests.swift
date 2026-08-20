import Testing
@testable import MacTemplate

struct AppInfoTests {
    @Test
    func pickDisplayNamePrefersDisplayThenBundleThenFallback() {
        #expect(AppInfo.pickDisplayName("Notes", bundleName: "Ignore") == "Notes")
        #expect(AppInfo.pickDisplayName("  ", bundleName: "Bundle") == "Bundle")
        #expect(AppInfo.pickDisplayName(nil, bundleName: nil) == "MacTemplate")
        #expect(AppInfo.pickDisplayName(nil, bundleName: "") == "MacTemplate")
    }

    @Test
    func pickVersionFallsBack() {
        #expect(AppInfo.pickVersion("2.1.0") == "2.1.0")
        #expect(AppInfo.pickVersion("  ") == "1.0.0")
        #expect(AppInfo.pickVersion(nil) == "1.0.0")
    }

    @Test
    func pickCopyrightFallsBack() {
        #expect(AppInfo.pickCopyright("Copyright © Notes") == "Copyright © Notes")
        #expect(AppInfo.pickCopyright("  ") == "Copyright © MacTemplate")
        #expect(AppInfo.pickCopyright(nil) == "Copyright © MacTemplate")
    }

    @Test
    func hostBundleHasIdentity() {
        #expect(!AppInfo.displayName.isEmpty)
        #expect(!AppInfo.version.isEmpty)
        #expect(!AppInfo.copyright.isEmpty)
    }
}
