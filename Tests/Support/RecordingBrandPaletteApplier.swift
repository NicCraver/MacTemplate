@testable import MacTemplate

final class RecordingBrandPaletteApplier: BrandPaletteApplying {
    var hexes: [String] = []

    func applyPrimaryHex(_ hex: String) {
        hexes.append(hex)
    }
}
