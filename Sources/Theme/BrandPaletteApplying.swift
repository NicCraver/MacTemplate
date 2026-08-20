import ChunUI
import Foundation

protocol BrandPaletteApplying {
    func applyPrimaryHex(_ hex: String)
}

struct ChunUIBrandPaletteApplier: BrandPaletteApplying {
    func applyPrimaryHex(_ hex: String) {
        var colors = CCColors.default
        colors.primary = .hex(hex)
        ChunUI.configure(colors: colors)
    }
}
