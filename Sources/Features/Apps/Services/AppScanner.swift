import AppKit
import Foundation

/// 递归扫描目录里的 .app，包括指向应用的 Finder 别名；跨目录按解析路径与
/// bundleID 去重。纯 Foundation/AppKit 服务，线程安全，可在任意执行环境调用。
nonisolated enum AppScanner {
    /// 参与列表的应用目录（合并为一个视图）。
    static func directories(includeSystemApps: Bool) -> [URL] {
        var directories = [
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true),
            URL(fileURLWithPath: "/Applications"),
        ]
        if includeSystemApps {
            directories.append(URL(fileURLWithPath: "/System/Applications", isDirectory: true))
        }
        return directories
    }

    static let sourcesLabel = "~/Applications + /Applications"

    static func apps(in directories: [URL]) -> [AppEntry] {
        let fm = FileManager.default
        var results: [AppEntry] = []
        var seenPaths = Set<String>()
        var seenBundleIDs = Set<String>()
        let keys: [URLResourceKey] = [.isDirectoryKey, .isAliasFileKey, .contentModificationDateKey]

        for directory in directories {
            guard let enumerator = fm.enumerator(
                at: directory,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles, .skipsPackageDescendants],
                errorHandler: { _, _ in true }
            ) else { continue }

            for case let url as URL in enumerator {
                guard url.pathExtension.lowercased() == "app" else {
                    if enumerator.level >= 4 { enumerator.skipDescendants() }
                    continue
                }
                enumerator.skipDescendants()

                var target = url
                var isDir: ObjCBool = false
                fm.fileExists(atPath: url.path, isDirectory: &isDir)
                if !isDir.boolValue {
                    let isAlias = (try? url.resourceValues(forKeys: [.isAliasFileKey]))?.isAliasFile ?? false
                    if isAlias, let resolved = resolveAlias(url) { target = resolved }
                }

                var isTargetDir: ObjCBool = false
                guard fm.fileExists(atPath: target.path, isDirectory: &isTargetDir), isTargetDir.boolValue else { continue }
                guard let values = try? target.resourceValues(forKeys: [.isPackageKey]), values.isPackage == true else { continue }

                let pathKey = target.resolvingSymlinksInPath().path
                guard !seenPaths.contains(pathKey) else { continue }
                seenPaths.insert(pathKey)

                let bundle = Bundle(url: target)
                if bundle?.bundleIdentifier == "com.nic.applist" { continue }
                // 同一 bundle id 出现在多个目录时只保留优先级最高的一份。
                if let bundleID = bundle?.bundleIdentifier {
                    guard !seenBundleIDs.contains(bundleID) else { continue }
                    seenBundleIDs.insert(bundleID)
                }

                let rawName = fm.displayName(atPath: target.path)
                // Launchpad 风格：展示名不带 .app 后缀
                let name = rawName.lowercased().hasSuffix(".app") ? String(rawName.dropLast(4)) : rawName
                let rawVersion = bundle?.infoDictionary?["CFBundleShortVersionString"] as? String
                let version = rawVersion.flatMap { $0.isEmpty ? nil : $0 }
                let modified = (try? target.resourceValues(forKeys: [.contentModificationDateKey]))?
                    .contentModificationDate ?? Date()
                let icon = IconCache.icon(for: target, bundleID: bundle?.bundleIdentifier,
                                          version: version, modified: modified)

                results.append(AppEntry(url: target,
                                        name: name,
                                        version: version,
                                        bundleID: bundle?.bundleIdentifier,
                                        modified: modified,
                                        icon: icon))
            }
        }
        return results
    }

    private static func resolveAlias(_ url: URL) -> URL? {
        guard let data = try? url.bookmarkData() else { return nil }
        var stale = false
        return try? URL(resolvingBookmarkData: data, options: [.withoutUI], relativeTo: nil, bookmarkDataIsStale: &stale)
    }
}
