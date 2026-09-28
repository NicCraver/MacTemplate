import Foundation

struct BrandColor: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let hex: String

    static let presets: [BrandColor] = [
        BrandColor(id: "azure", name: "湛蓝", hex: "3E7EFF"),
        BrandColor(id: "blue", name: "系统蓝", hex: "007AFF"),
        BrandColor(id: "orange", name: "琥珀", hex: "FF6B00"),
        BrandColor(id: "teal", name: "碧玺", hex: "00A3A1"),
    ]

    static let `default`: BrandColor = presets[0]

    static func named(_ hex: String) -> BrandColor {
        let needle = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        return presets.first { $0.hex.caseInsensitiveCompare(needle) == .orderedSame }
            ?? .default
    }
}
