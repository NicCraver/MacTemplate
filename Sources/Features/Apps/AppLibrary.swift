import AppKit
import Foundation
import Observation

/// 应用库的单一数据源：扫描、筛选、排序、启动计数与体积懒计算。
@MainActor
@Observable
final class AppLibrary {
    enum ViewMode: Int { case grid, list }
    enum SortKey: Int { case name, date, size, frequent, manual }
    enum Category: Int, CaseIterable {
        case all, favorites, mostUsed, recentlyUpdated, homeFolder, systemFolder

        static let cutoffInterval: TimeInterval = 30 * 86400
        static let mostUsedMinimum = 3

        var title: String {
            switch self {
            case .all: return "全部应用"
            case .favorites: return "收藏"
            case .mostUsed: return "常用"
            case .recentlyUpdated: return "最近更新"
            case .homeFolder: return "~/Applications"
            case .systemFolder: return "/Applications"
            }
        }

        var iconName: String {
            switch self {
            case .all: return AppIconName.appsGrid
            case .favorites: return AppIconName.favorite
            case .mostUsed: return AppIconName.mostUsed
            case .recentlyUpdated: return AppIconName.recentlyUpdated
            case .homeFolder: return AppIconName.homeFolder
            case .systemFolder: return AppIconName.systemFolder
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
    private(set) var favoriteIDs: Set<String>
    private(set) var favoriteOrder: [String]
    private(set) var customOrder: [String] = []

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
        favoriteIDs = Set(defaults.stringArray(forKey: PreferenceKey.appsFavorites) ?? [])
        favoriteOrder = defaults.stringArray(forKey: PreferenceKey.appsFavoriteOrder) ?? []
        customOrder = defaults.stringArray(forKey: PreferenceKey.appsCustomOrder) ?? []
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
        if category == .favorites {
            // 收藏视图按用户拖拽定义的顺序展示，不受排序菜单影响。
            apps.sort {
                let ai = favoriteOrder.firstIndex(of: $0.identityKey) ?? Int.max
                let bi = favoriteOrder.firstIndex(of: $1.identityKey) ?? Int.max
                if ai != bi { return ai < bi }
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
        } else if sortKey == .manual {
            // 手动排序：按用户拖拽生成的顺序；没排过的按名称排在最后。
            let orderIndex = Dictionary(uniqueKeysWithValues: customOrder.enumerated().map { ($1, $0) })
            apps.sort {
                let ai = orderIndex[$0.identityKey] ?? Int.max
                let bi = orderIndex[$1.identityKey] ?? Int.max
                if ai != bi { return ai < bi }
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
        } else {
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
            case .manual:
                break
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
        case .favorites:
            return favoriteIDs.contains(app.identityKey)
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

    func isFavorite(_ app: AppEntry) -> Bool {
        favoriteIDs.contains(app.identityKey)
    }

    func toggleFavorite(_ app: AppEntry) {
        let key = app.identityKey
        if favoriteIDs.contains(key) {
            favoriteIDs.remove(key)
            favoriteOrder.removeAll { $0 == key }
        } else {
            favoriteIDs.insert(key)
            favoriteOrder.append(key)
        }
        persistFavorites()
        recomputeVisible()
    }

    /// 把应用加入收藏（拖到侧边栏「收藏」时调用）。
    func addFavorite(identityKey: String) {
        favoriteIDs.insert(identityKey)
        if !favoriteOrder.contains(identityKey) {
            favoriteOrder.append(identityKey)
        }
        persistFavorites()
        recomputeVisible()
    }

    /// 拖拽重排：把 dragged 移到 target 之前。
    /// - 收藏分类：写回收藏顺序
    /// - 其他分类：写入手动排序，并自动把排序方式切到「手动」（否则重排会被覆盖、看起来无效）
    func reorder(draggedID: String, before targetID: String) {
        let sequence = visibleApps.map(\.identityKey)
        guard let from = sequence.firstIndex(of: draggedID),
              let to = sequence.firstIndex(of: targetID), from != to else { return }
        var ordered = sequence
        let dragged = ordered.remove(at: from)
        let insertIndex = ordered.firstIndex(of: targetID) ?? ordered.count
        ordered.insert(dragged, at: insertIndex)

        if category == .favorites {
            var merged = ordered
            merged += favoriteOrder.filter { !ordered.contains($0) }
            favoriteOrder = merged
            persistFavorites()
        } else {
            var merged = ordered
            merged += customOrder.filter { !ordered.contains($0) }
            merged += apps.map(\.identityKey).filter { !merged.contains($0) }
            customOrder = merged
            defaults.set(customOrder, forKey: PreferenceKey.appsCustomOrder)
            if sortKey != .manual {
                sortKey = .manual
                return   // didSet 已触发重算
            }
        }
        recomputeVisible()
    }

    private func persistFavorites() {
        defaults.set(Array(favoriteIDs), forKey: PreferenceKey.appsFavorites)
        defaults.set(favoriteOrder, forKey: PreferenceKey.appsFavoriteOrder)
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
