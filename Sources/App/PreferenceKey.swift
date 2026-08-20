import Foundation

enum PreferenceKey {
    static let prefix = "macTemplate"
    static var appearanceMode: String { "\(prefix).appearanceMode" }
    static var brandColorHex: String { "\(prefix).brandColorHex" }
    static var showStatusBar: String { "\(prefix).showStatusBar" }
    static var settingsTab: String { "\(prefix).settingsTab" }
}
