import Foundation

enum SettingsTab: String, CaseIterable, Identifiable {
    case general
    case appearance
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return "通用"
        case .appearance: return "外观"
        case .about: return "关于"
        }
    }

    var icon: String {
        switch self {
        case .general: return AppIconName.settings
        case .appearance: return AppIconName.appearance
        case .about: return AppIconName.about
        }
    }
}
