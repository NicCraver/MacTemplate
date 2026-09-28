import ChunUI
import Foundation
import SwiftUI

enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case apps
    case settings

    var id: String { rawValue }

    static let primary: [AppSection] = [.apps]

    static var menuOrder: [AppSection] { primary + [.settings] }

    var title: String {
        switch self {
        case .apps: return "应用"
        case .settings: return "设置"
        }
    }

    var icon: String {
        switch self {
        case .apps: return AppIconName.apps
        case .settings: return AppIconName.settings
        }
    }

    var shortcutDigit: Int? {
        guard let index = Self.menuOrder.firstIndex(of: self) else { return nil }
        let digit = index + 1
        return (1...9).contains(digit) ? digit : nil
    }

    var keyEquivalent: KeyEquivalent? {
        guard let shortcutDigit else { return nil }
        return KeyEquivalent(Character(String(shortcutDigit)))
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .apps:
            AppsPage()
        case .settings:
            SettingsRootView()
        }
    }
}
