import Foundation

enum AppInfo {
    static var displayName: String {
        pickDisplayName(
            Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
            bundleName: Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        )
    }

    static var version: String {
        pickVersion(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
    }

    static var copyright: String {
        pickCopyright(Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String)
    }

    static func pickDisplayName(_ display: String?, bundleName: String?) -> String {
        if let display = nonempty(display) { return display }
        if let bundleName = nonempty(bundleName) { return bundleName }
        return "MacTemplate"
    }

    static func pickVersion(_ version: String?) -> String {
        nonempty(version) ?? "1.0.0"
    }

    static func pickCopyright(_ copyright: String?) -> String {
        nonempty(copyright) ?? "Copyright © MacTemplate"
    }

    private static func nonempty(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty
        else { return nil }
        return trimmed
    }
}
