import Foundation
import Observation
import SwiftUI

@Observable
final class AppSession {
    static var statusBarKey: String { PreferenceKey.showStatusBar }

    var section: AppSection = .overview
    var navigationEpoch: Int = 0

    /// 存 SwiftUI 原样的列可见性。两列布局里 NavigationSplitView 写回的是
    /// `.doubleColumn`，若中间经 Bool 转一手会被还原成 `.all` 再推回去，
    /// 动画进行中被重新提交一次，就是展开时那一下顿挫。
    var sidebarVisibility: NavigationSplitViewVisibility = .doubleColumn

    var sidebarExpanded: Bool {
        get { sidebarVisibility != .detailOnly }
        set { sidebarVisibility = newValue ? .doubleColumn : .detailOnly }
    }

    var showStatusBar: Bool {
        didSet { defaults.set(showStatusBar, forKey: PreferenceKey.showStatusBar) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: PreferenceKey.showStatusBar) == nil {
            self.showStatusBar = true
            defaults.set(true, forKey: PreferenceKey.showStatusBar)
        } else {
            self.showStatusBar = defaults.bool(forKey: PreferenceKey.showStatusBar)
        }
    }

    func go(to section: AppSection) {
        if section == self.section {
            navigationEpoch += 1
        }
        self.section = section
    }
}
