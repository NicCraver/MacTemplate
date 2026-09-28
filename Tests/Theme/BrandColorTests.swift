import Foundation
import Testing
@testable import AppList

struct BrandColorTests {
    @Test
    func knownHexIgnoresHashAndCase() {
        #expect(BrandColor.named("#3e7eff").hex == "3E7EFF")
        #expect(BrandColor.named("007AFF").id == "blue")
    }

    @Test
    func unknownHexFallsBackToDefaultAzure() {
        #expect(BrandColor.named("zzzzzz") == .default)
        #expect(BrandColor.default.hex == "3E7EFF")
        #expect(BrandColor.default.id == "azure")
    }
}
