import Foundation

struct BrandColor: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let hex: String

    static let presets: [BrandColor] = [
        BrandColor(id: "pink", name: "霓虹粉", hex: "ff00c8"),
        BrandColor(id: "blue", name: "系统蓝", hex: "007aff"),
        BrandColor(id: "orange", name: "琥珀", hex: "ff6b00"),
        BrandColor(id: "teal", name: "碧玺", hex: "00a3a1"),
    ]

    static let `default`: BrandColor = presets[0]

    static func named(_ hex: String) -> BrandColor {
        let needle = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        return presets.first { $0.hex.caseInsensitiveCompare(needle) == .orderedSame }
            ?? .default
    }
}
