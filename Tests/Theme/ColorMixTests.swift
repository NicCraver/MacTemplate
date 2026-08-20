import ChunUI
import SwiftUI
import Testing

struct ColorMixTests {
    @Test
    func mixingAdaptiveSemanticColorsDoesNotTrap() {
        _ = Color.cc.primary.mix(with: Color.cc.foreground, amount: 0.24)
        _ = Color.cc.primary.mix(with: Color.cc.card, amount: 0.76)
        _ = Color.cc.primary.mix(with: Color.cc.muted, amount: 0.66)
        _ = Color.cc.primary.mix(with: Color.cc.border, amount: 0.52)
        _ = Color.cc.background.mix(with: .black, amount: 0.10)
    }
}
