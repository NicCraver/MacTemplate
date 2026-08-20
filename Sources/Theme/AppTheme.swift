import ChunUI
import Foundation
import SwiftUI

@Observable
final class AppTheme {
    static var appearanceKey: String { PreferenceKey.appearanceMode }
    static var brandKey: String { PreferenceKey.brandColorHex }

    var appearance: AppearanceMode {
        didSet { defaults.set(appearance.rawValue, forKey: PreferenceKey.appearanceMode) }
    }

    var brandHex: String {
        didSet {
            defaults.set(brandHex, forKey: PreferenceKey.brandColorHex)
            applyBrand()
        }
    }

    private(set) var revision: Int = 0

    var brand: BrandColor {
        get { BrandColor.named(brandHex) }
        set { brandHex = newValue.hex }
    }

    private let defaults: UserDefaults
    private let palette: BrandPaletteApplying

    init(
        defaults: UserDefaults = .standard,
        palette: BrandPaletteApplying = ChunUIBrandPaletteApplier()
    ) {
        self.defaults = defaults
        self.palette = palette
        let appearanceRaw = defaults.string(forKey: PreferenceKey.appearanceMode) ?? ""
        self.appearance = AppearanceMode(rawValue: appearanceRaw) ?? .system
        let storedHex = defaults.string(forKey: PreferenceKey.brandColorHex) ?? BrandColor.default.hex
        self.brandHex = BrandColor.named(storedHex).hex
        defaults.set(appearance.rawValue, forKey: PreferenceKey.appearanceMode)
        defaults.set(brandHex, forKey: PreferenceKey.brandColorHex)
        palette.applyPrimaryHex(brandHex)
    }

    func applyBrand() {
        palette.applyPrimaryHex(brandHex)
        revision += 1
    }
}
