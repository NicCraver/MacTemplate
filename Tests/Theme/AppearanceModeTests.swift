import SwiftUI
import Testing
@testable import AppList

struct AppearanceModeTests {
    @Test
    func colorSchemeMapping() {
        #expect(AppearanceMode.system.colorScheme == nil)
        #expect(AppearanceMode.light.colorScheme == .light)
        #expect(AppearanceMode.dark.colorScheme == .dark)
    }
}
