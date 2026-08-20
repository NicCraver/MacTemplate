import Foundation
import Testing
@testable import MacTemplate

struct BrandColorTests {
    @Test
    func knownHexIgnoresHashAndCase() {
        #expect(BrandColor.named("#FF00C8").hex == "ff00c8")
        #expect(BrandColor.named("007AFF").id == "blue")
    }

    @Test
    func unknownHexFallsBackToDefaultPink() {
        #expect(BrandColor.named("zzzzzz") == .default)
        #expect(BrandColor.default.hex == "ff00c8")
    }
}
