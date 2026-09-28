import AppKit
import Foundation
import Observation

/// 应用库的单一数据源：扫描、筛选、排序、启动计数与体积懒计算。
@MainActor
@Observable
final class AppLibrary {
    enum ViewMode: Int { case grid, list }
    enum SortKey: Int { case name, date, size, frequent }
    enum Category: Int, CaseIterable {
        case all, mostUsed, recentlyUpdated, homeFolder, systemFolder

        static let cutoffInterval: TimeInterval = 30 * 86400
        static let mostUsedMinimum = 3

        var title: String {
            switch self {
            case .all: return "全部应用"
            case .mostUsed: return "最常用"
            case .recentlyUpdated: return "最近更新"
            case .homeFolder: return "~/Applications"
            case .systemFolder: return "/Applications"
            }
        }
    }

    private(set) var apps: [AppEntry] = []
    /// 缓存后的可见列表：只在数据/筛选/排序变化时重算一次，
    /// 滚动与悬停不会反复触发全量过滤排序（这是之前滚动卡顿的根因）。
    private(set) var visibleApps: [AppEntry] = []
    private(set) var isScanning = false
    var searchText: String = "" {
        didSet { recomputeVisible() }
    }
    var viewMode: ViewMode {
        didSet { defaults.set(viewMode.rawValue, forKey: PreferenceKey.appsViewMode) }
    }
    var sortKey: SortKey {
        didSet {
            defaults.set(sortKey.rawValue, forKey: PreferenceKey.appsSortKey)
            recomputeVisible()
        }
    }
    var category: Category {
        didSet {
            defaults.set(category.rawValue, forKey: PreferenceKey.appsCategory)
            recomputeVisible()
        }
    }
    var includeSystemApps: Bool {
        didSet {
            defaults.set(includeSystemApps, forKey: PreferenceKey.appsIncludeSystem)
            load()
        }
    }

    private(set) var launchCounts: [String: Int]

    private var hasLoaded = false
    private var scanGeneration = 0
    private var sizeBatchInFlight = false
    private let watcher = FSWatcher()
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        viewMode = ViewMode(rawValue: defaults.integer(forKey: PreferenceKey.appsViewMode)) ?? .grid
        sortKey = SortKey(rawValue: defaults.integer(forKey: PreferenceKey.appsSortKey)) ?? .name
        category = Category(rawValue: defaults.integer(forKey: PreferenceKey.appsCategory)) ?? .all
        includeSystemApps = defaults.object(forKey: PreferenceKey.appsIncludeSystem) as? Bool ?? false
        launchCounts = defaults.dictionary(forKey: PreferenceKey.appsLaunchCounts) as? [String: Int] ?? [:]
        recomputeVisible()
    }

    var totalCount: Int { apps.count }

    private func recomputeVisible() {
        var apps = apps.filter { matchesCategory(category, app: $0) }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            apps = apps.filter {
                $0.name.lowercased().contains(query)
                    || ($0.bundleID?.lowercased().contains(query) ?? false)
            }
        }
        switch sortKey {
        case .name:
            apps.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .date:
            apps.sort { $0.modified > $1.modified }
        case .size:
            apps.sort { max($0.sizeBytes, 0) > max($1.sizeBytes, 0) }
        case .frequent:
            apps.sort {
                let lhs = launchCount(for: $0), rhs = launchCount(for: $1)
                if lhs != rhs { return lhs > rhs }
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
        }
        visibleApps = apps
    }

    func categoryCount(_ category: Category) -> Int {
        apps.filter { matchesCategory(category, app: $0) }.count
    }

    private func matchesCategory(_ category: Category, app: AppEntry) -> Bool {
        switch category {
        case .all:
            return true
        case .mostUsed:
            return launchCount(for: app) >= Category.mostUsedMinimum
        case .recentlyUpdated:
            return app.modified > Date().addingTimeInterval(-Category.cutoffInterval)
        case .homeFolder:
            let home = AppScanner.directories(includeSystemApps: false)[0]
            return app.url.path.hasPrefix(home.path)
        case .systemFolder:
            let system = AppScanner.directories(includeSystemApps: false)[1]
            return app.url.path.hasPrefix(system.path)
        }
    }

    func launchCount(for app: AppEntry) -> Int {
        launchCounts[app.identityKey] ?? 0
    }

    // MARK: - Scanning

    /// 幂等：页面首次出现时调用一次，之后由 watcher 增量刷新。
    func loadIfNeeded() {
        guard !hasLoaded else { return }
        load()
    }

    func refresh() {
        load()
    }

    func load() {
        scanGeneration += 1
        let generation = scanGeneration
        isScanning = apps.isEmpty
        let directories = AppScanner.directories(includeSystemApps: includeSystemApps)
        Task.detached(priority: .userInitiated) { [weak self] in
            let apps = AppScanner.apps(in: directories)
            await self?.finishScan(apps: apps, generation: generation)
        }
    }

    private func finishScan(apps: [AppEntry], generation: Int) {
        guard generation == scanGeneration else { return }
        self.apps = apps
        recomputeVisible()
        isScanning = false
        watcher.watch(paths: AppScanner.directories(includeSystemApps: includeSystemApps).map(\.path))
        watcher.onChange = { [weak self] in self?.load() }
        computeSizesIfNeeded()
    }

    private func computeSizesIfNeeded() {
        guard !sizeBatchInFlight, apps.contains(where: { $0.sizeBytes < 0 }) else { return }
        sizeBatchInFlight = true
        let generation = scanGeneration
        let entries = apps.map { ($0.url.resolvingSymlinksInPath().path, $0.modified) }
        Task.detached(priority: .utility) { [weak self] in
            var sizes: [String: Int64] = [:]
            for (path, modified) in entries {
                sizes[path] = SizeStore.size(resolvedPath: path, modified: modified)
            }
            await self?.applySizes(sizes, generation: generation)
        }
    }

    private func applySizes(_ sizes: [String: Int64], generation: Int) {
        sizeBatchInFlight = false
        guard generation == scanGeneration else { return }
        var updated = apps
        var changed = false
        for index in updated.indices where updated[index].sizeBytes < 0 {
            let path = updated[index].url.resolvingSymlinksInPath().path
            if let size = sizes[path] {
                updated[index].sizeBytes = size
                changed = true
            }
        }
        if changed {
            apps = updated
            recomputeVisible()
        }
    }

    // MARK: - Launch actions

    func launchCountKey(_ app: AppEntry) -> String { app.identityKey }

    func open(_ app: AppEntry) {
        launchCounts[app.identityKey, default: 0] += 1
        defaults.set(launchCounts, forKey: PreferenceKey.appsLaunchCounts)
        recomputeVisible()
        NSWorkspace.shared.openApplication(at: app.url, configuration: NSWorkspace.OpenConfiguration())
    }

    func trash(_ app: AppEntry) {
        try? FileManager.default.trashItem(at: app.url, resultingItemURL: nil)
        load()
    }

    func reveal(_ app: AppEntry) {
        NSWorkspace.shared.activateFileViewerSelecting([app.url])
    }

    func copyPath(_ app: AppEntry) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([app.url as NSURL])
    }

    func pruneIconCache() {
        IconCache.pruneStaleFiles()
    }
}
