import ChunUI
import Foundation
import SwiftUI

enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case overview
    case library
    case settings

    var id: String { rawValue }

    static let primary: [AppSection] = [.overview, .library]

    static var menuOrder: [AppSection] { primary + [.settings] }

    var title: String {
        switch self {
        case .overview: return "概览"
        case .library: return "资料库"
        case .settings: return "设置"
        }
    }

    var icon: String {
        switch self {
        case .overview: return AppIconName.overview
        case .library: return AppIconName.library
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
        case .overview:
            OverviewPage()
        case .library:
            LibraryPage()
        case .settings:
            SettingsRootView()
        }
    }
}
