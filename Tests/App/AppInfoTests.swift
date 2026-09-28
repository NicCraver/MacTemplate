import Testing
@testable import AppList

struct AppInfoTests {
    @Test
    func pickDisplayNamePrefersDisplayThenBundleThenFallback() {
        #expect(AppInfo.pickDisplayName("Notes", bundleName: "Ignore") == "Notes")
        #expect(AppInfo.pickDisplayName("  ", bundleName: "Bundle") == "Bundle")
        #expect(AppInfo.pickDisplayName(nil, bundleName: nil) == "AppList")
        #expect(AppInfo.pickDisplayName(nil, bundleName: "") == "AppList")
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
        #expect(AppInfo.pickCopyright("  ") == "Copyright © AppList")
        #expect(AppInfo.pickCopyright(nil) == "Copyright © AppList")
    }

    @Test
    func hostBundleHasIdentity() {
        #expect(!AppInfo.displayName.isEmpty)
        #expect(!AppInfo.version.isEmpty)
        #expect(!AppInfo.copyright.isEmpty)
    }
}
