import Foundation

enum PreferenceKey {
    static let prefix = "appList"
    static var appearanceMode: String { "\(prefix).appearanceMode" }
    static var brandColorHex: String { "\(prefix).brandColorHex" }
    static var showStatusBar: String { "\(prefix).showStatusBar" }

    static var appsViewMode: String { "\(prefix).apps.viewMode" }
    static var appsSortKey: String { "\(prefix).apps.sortKey" }
    static var appsCategory: String { "\(prefix).apps.category" }
    static var appsIncludeSystem: String { "\(prefix).apps.includeSystemApps" }
    static var appsLaunchCounts: String { "\(prefix).apps.launchCounts" }
}
