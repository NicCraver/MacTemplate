import ChunUI
import SwiftUI

struct AppsPage: View {
    @Environment(AppLibrary.self) private var library
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var query = ""
    @State private var pendingTrash: AppEntry?
    @FocusState private var searchFocused: Bool

    // 拖拽排序状态（网格 appsGridSpace / 列表 appsListSpace 两个命名空间通用）
    @State private var draggingID: String?
    @State private var dragStartPoint: CGPoint = .zero
    @State private var dragStartCenter: CGPoint?
    @State private var dragCurrentPoint: CGPoint = .zero
    @State private var insertionIndex: Int?
    @State private var cardFrames: [String: CGRect] = [:]

    private static let gridSpace = "appsGridSpace"
    private static let listSpace = "appsListSpace"

    var body: some View {
        MacPageScaffold(
            title: "应用",
            subtitle: subtitle,
            contentMaxWidth: .infinity
        ) {
            controls
        } content: {
            content
        }
        .task {
            library.loadIfNeeded()
            library.pruneIconCache()
        }
        .confirmationDialog(
            pendingTrash.map { "将 “\($0.displayName)” 移到废纸篓？" } ?? "",
            isPresented: Binding(
                get: { pendingTrash != nil },
                set: { if !$0 { pendingTrash = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("移到废纸篓", role: .destructive) {
                if let app = pendingTrash { library.trash(app) }
                pendingTrash = nil
            }
            Button("取消", role: .cancel) { pendingTrash = nil }
        } message: {
            Text("应用将被移到废纸篓。")
        }
        .background { searchShortcut }
    }

    private var subtitle: String {
        let total = library.totalCount
        if library.isScanning && library.apps.isEmpty { return "正在扫描…" }
        let filtered = library.category != .all || !query.trimmingCharacters(in: .whitespaces).isEmpty
        if filtered {
            return "显示 \(library.visibleApps.count) / \(total) 个应用"
        }
        return "共 \(total) 个应用"
    }

    // MARK: - Header controls

    private var controls: some View {
        @Bindable var library = library
        return HStack(spacing: 10) {
            searchCapsule

            Picker("视图", selection: $library.viewMode) {
                Text("网格").tag(AppLibrary.ViewMode.grid)
                Text("列表").tag(AppLibrary.ViewMode.list)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()

            sortMenu
            filterMenu

            Button {
                library.refresh()
            } label: {
                PikaIcon(PikaIcon.Name.refresh, size: 16, color: .cc.mutedForeground)
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
            .help("重新扫描")
            .accessibilityLabel("重新扫描")
        }
    }

    private var searchCapsule: some View {
        @Bindable var library = library
        return HStack(spacing: 8) {
            PikaIcon(AppIconName.search, size: 14, color: .cc.mutedForeground)
            TextField("搜索应用", text: $library.searchText)
                .textFieldStyle(.plain)
                .ccText(font: .cc.sm, color: .cc.foreground)
                .focused($searchFocused)
                .frame(width: 140)
                .accessibilityIdentifier("apps.search")
            if !library.searchText.isEmpty {
                Button {
                    library.searchText = ""
                    searchFocused = false
                } label: {
                    PikaIcon(AppIconName.close, size: 12, color: .cc.mutedForeground)
                }
                .buttonStyle(.plain)
                .help("清除搜索")
                .accessibilityLabel("清除搜索")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.cc.muted, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(
                    searchFocused ? Color.cc.primary.opacity(0.7) : Color.clear,
                    lineWidth: 1
                )
        }
    }

    private var searchShortcut: some View {
        Button("搜索应用") { searchFocused = true }
            .keyboardShortcut("f", modifiers: .command)
            .opacity(0)
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .allowsHitTesting(false)
    }

    private var sortMenu: some View {
        @Bindable var library = library
        return Menu {
            Picker("排序方式", selection: $library.sortKey) {
                Text("按名称").tag(AppLibrary.SortKey.name)
                Text("最近修改").tag(AppLibrary.SortKey.date)
                Text("大小").tag(AppLibrary.SortKey.size)
                Text("最常用").tag(AppLibrary.SortKey.frequent)
                Text("手动排序").tag(AppLibrary.SortKey.manual)
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } label: {
            HStack(spacing: 6) {
                PikaIcon(PikaIcon.Name.listChecklist, size: 14, color: .cc.mutedForeground)
                Text("排序").ccText(font: .cc.sm, color: .cc.foreground)
                PikaIcon(PikaIcon.Name.chevronDown, size: 12, color: .cc.mutedForeground)
            }
        }
        .menuStyle(.button)
        .fixedSize()
        .menuIndicator(.visible)
        .accessibilityLabel("排序方式")
    }

    private var filterMenu: some View {
        @Bindable var library = library
        return Menu {
            Picker("分类", selection: $library.category) {
                ForEach(AppLibrary.Category.allCases, id: \.self) { category in
                    Text("\(category.title) · \(library.categoryCount(category))").tag(category)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()

            Divider()

            Toggle("显示系统应用", isOn: $library.includeSystemApps)
        } label: {
            HStack(spacing: 6) {
                PikaIcon(AppIconName.apps, size: 14, color: .cc.mutedForeground)
                Text("分类").ccText(font: .cc.sm, color: .cc.foreground)
                PikaIcon(PikaIcon.Name.chevronDown, size: 12, color: .cc.mutedForeground)
            }
        }
        .menuStyle(.button)
        .fixedSize()
        .menuIndicator(.visible)
        .help("包含 /System/Applications 时开关「显示系统应用」")
        .accessibilityLabel("分类筛选")
    }

    // MARK: - Drag reorder

    /// 拖拽期间的计算布局：被拖卡片移到插入点，其余卡片让位（带弹簧动画）。
    private var arrangedApps: [AppEntry] {
        var apps = library.visibleApps
        if let draggingID, let insertionIndex,
           let from = apps.firstIndex(where: { $0.id == draggingID }) {
            let item = apps.remove(at: from)
            apps.insert(item, at: min(insertionIndex, apps.count))
        }
        return apps
    }

    /// 指针位置对应的插入位置：命中哪张未拖拽的卡片，就插到它前面。
    private func insertionIndexAt(_ point: CGPoint) -> Int? {
        let ids = arrangedApps.map(\.id)
        for (index, id) in ids.enumerated() where id != draggingID {
            if let frame = cardFrames[id], frame.contains(point) {
                return index
            }
        }
        return nil
    }

    /// 被拖卡片的位移：手指位移 − 它当前所在槽位的位移补偿，保证始终跟手。
    private func dragOffset(for app: AppEntry) -> CGSize {
        guard app.id == draggingID,
              let startCenter = dragStartCenter,
              let frame = cardFrames[app.id] else { return .zero }
        return CGSize(
            width: startCenter.x + (dragCurrentPoint.x - dragStartPoint.x) - frame.midX,
            height: startCenter.y + (dragCurrentPoint.y - dragStartPoint.y) - frame.midY
        )
    }

    private func dragChanged(app: AppEntry, at point: CGPoint) {
        if draggingID == nil {
            draggingID = app.id
            dragStartPoint = point
            dragStartCenter = cardFrames[app.id].map { CGPoint(x: $0.midX, y: $0.midY) }
            insertionIndex = library.visibleApps.firstIndex(where: { $0.id == app.id })
        }
        dragCurrentPoint = point

        if let index = insertionIndexAt(point), index != insertionIndex {
            withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.85)) {
                insertionIndex = index
            }
        }
    }

    private func dragEnded(at point: CGPoint) {
        guard draggingID != nil else { return }
        // 此刻 arrangedApps 已是最终顺序，直接持久化。
        library.applyVisibleOrder(arrangedApps)

        let reset = {
            draggingID = nil
            dragStartPoint = .zero
            dragStartCenter = nil
            dragCurrentPoint = .zero
            insertionIndex = nil
        }
        if reduceMotion {
            reset()
        } else {
            withAnimation(.easeOut(duration: 0.2)) { reset() }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if library.isScanning && library.apps.isEmpty {
            HStack {
                Spacer()
                ProgressView()
                    .controlSize(.large)
                Spacer()
            }
            .padding(.top, 80)
        } else if library.visibleApps.isEmpty {
            CCEmptyState(
                kind: .knowledge,
                message: emptyTitle,
                detail: emptyDetail,
                compact: true
            )
            .frame(maxWidth: .infinity, minHeight: 220)
        } else {
            switch library.viewMode {
            case .grid:
                gridView
            case .list:
                listView
            }
        }
    }

    private var emptyTitle: String {
        if !query.trimmingCharacters(in: .whitespaces).isEmpty { return "没有匹配的应用" }
        if library.category == .mostUsed { return "还没有常用应用" }
        return "这里还没有应用"
    }

    private var emptyDetail: String {
        if !query.trimmingCharacters(in: .whitespaces).isEmpty { return "换个关键词，或清空搜索" }
        return "换个分类看看，或在「分类」菜单里开启「显示系统应用」"
    }

    private var gridView: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 148), spacing: 14)],
            spacing: 14
        ) {
            ForEach(arrangedApps) { app in
                AppCard(
                    app: app,
                    isDragged: app.id == draggingID,
                    dragOffset: dragOffset(for: app),
                    isFavorite: library.isFavorite(app),
                    onOpen: { library.open(app) },
                    onToggleFavorite: { library.toggleFavorite(app) },
                    onDragChanged: { dragChanged(app: app, at: $0) },
                    onDragEnded: { dragEnded(at: $0) },
                    onTrash: { pendingTrash = app }
                )
                .background(cardFrameReader(id: app.id, space: Self.gridSpace))
            }
        }
        .coordinateSpace(name: Self.gridSpace)
        .accessibilityIdentifier("apps.grid")
    }

    private var listView: some View {
        CCAppleCard(radius: 16) {
            LazyVStack(spacing: 0) {
                ForEach(arrangedApps) { app in
                    AppRow(
                        app: app,
                        isDragged: app.id == draggingID,
                        dragOffset: dragOffset(for: app),
                        isFavorite: library.isFavorite(app),
                        onOpen: { library.open(app) },
                        onToggleFavorite: { library.toggleFavorite(app) },
                        onDragChanged: { dragChanged(app: app, at: $0) },
                        onDragEnded: { dragEnded(at: $0) },
                        onTrash: { pendingTrash = app }
                    )
                    .background(cardFrameReader(id: app.id, space: Self.listSpace))
                }
            }
        }
        .coordinateSpace(name: Self.listSpace)
        .accessibilityIdentifier("apps.list")
    }

    private func cardFrameReader(id: String, space: String) -> some View {
        GeometryReader { geo in
            Color.clear.preference(
                key: CardFramesKey.self,
                value: [id: geo.frame(in: .named(space))]
            )
        }
    }
}

// MARK: - Grid card

/// 独立视图：悬停状态本地化，滚动/悬停只重渲染当前卡片，不牵动整页。
private struct AppCard: View {
    static let gridSpace = "appsGridSpace"

    let app: AppEntry
    let isDragged: Bool
    let dragOffset: CGSize
    let isFavorite: Bool
    let onOpen: () -> Void
    let onToggleFavorite: () -> Void
    let onDragChanged: (CGPoint) -> Void
    let onDragEnded: (CGPoint) -> Void
    let onTrash: () -> Void
    @State private var hovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            onOpen()
        } label: {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(nsImage: app.icon)
                        .resizable()
                        .frame(width: 64, height: 64)
                    if isFavorite {
                        PikaIcon(AppIconName.favoriteFilled, size: 14, color: .cc.primary)
                            .offset(x: 5, y: -3)
                    }
                }
                Text(app.displayName)
                    .ccText(font: .cc.sm, color: .cc.foreground)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                if let version = app.version {
                    Text("v\(version)")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(backgroundColor)
            }
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(AppPressButtonStyle())
        .overlay(alignment: .topTrailing) {
            favoriteButton.padding(6)
        }
        .contextMenu {
            AppContextActions(
                title: app.displayName,
                isFavorite: isFavorite,
                onOpen: onOpen,
                onToggleFavorite: onToggleFavorite,
                onReveal: { NSWorkspace.shared.activateFileViewerSelecting([app.url]) },
                onCopyPath: { NSPasteboard.general.copyText(app.url.path) },
                onTrash: onTrash
            )
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .named(Self.gridSpace))
                .onChanged { value in
                    onDragChanged(value.location)
                }
                .onEnded { value in
                    onDragEnded(value.location)
                }
        )
        .offset(dragOffset)
        .zIndex(isDragged ? 10 : 0)
        .scaleEffect(isDragged ? 1.06 : 1)
        .shadow(color: .black.opacity(isDragged ? 0.35 : 0), radius: isDragged ? 14 : 0, y: isDragged ? 6 : 0)
        .onHover { hovered = $0 }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: hovered)
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8), value: isDragged)
        .help(app.url.path)
        .accessibilityHint("点按打开应用，长按拖动可排序")
        .accessibilityIdentifier("apps.card.\(app.id)")
    }

    /// 右上角收藏星标：已收藏时常显品牌色实心星；未收藏时悬停才出现描边星。
    private var favoriteButton: some View {
        Button {
            onToggleFavorite()
        } label: {
            PikaIcon(isFavorite ? AppIconName.favoriteFilled : AppIconName.favorite,
                     size: 13,
                     color: isFavorite ? .cc.primary : .cc.mutedForeground)
                .frame(width: 22, height: 22)
                .background {
                    Circle().fill(Color.cc.muted.opacity(0.9))
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .opacity(isFavorite || hovered ? 1 : 0)
        .allowsHitTesting(isFavorite || hovered)
        .help(isFavorite ? "从收藏中移除" : "添加到收藏")
        .accessibilityLabel(isFavorite ? "从收藏中移除" : "添加到收藏")
    }

    private var backgroundColor: Color {
        if isDragged { return Color.cc.muted.opacity(0.4) }
        return hovered ? Color.cc.muted.opacity(0.55) : .clear
    }
}

// MARK: - List row

/// 独立视图：悬停状态本地化，滚动/悬停只重渲染当前行，不牵动整页。
private struct AppRow: View {
    static let listSpace = "appsListSpace"

    let app: AppEntry
    let isDragged: Bool
    let dragOffset: CGSize
    let isFavorite: Bool
    let onOpen: () -> Void
    let onToggleFavorite: () -> Void
    let onDragChanged: (CGPoint) -> Void
    let onDragEnded: (CGPoint) -> Void
    let onTrash: () -> Void
    @State private var hovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            onOpen()
        } label: {
            HStack(spacing: 14) {
                Image(nsImage: app.icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .overlay(alignment: .topTrailing) {
                        if isFavorite {
                            PikaIcon(AppIconName.favoriteFilled, size: 10, color: .cc.primary)
                                .offset(x: 4, y: -2)
                        }
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(app.displayName)
                        .ccText(font: .cc.base, color: .cc.foreground)
                        .lineLimit(1)
                    Text(app.bundleID ?? app.url.path)
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text(app.displaySize)
                    .ccText(font: .cc.sm, color: .cc.mutedForeground)
                    .monospacedDigit()
                    .frame(width: 72, alignment: .trailing)
                Text(app.displayDate)
                    .ccText(font: .cc.sm, color: .cc.mutedForeground)
                    .monospacedDigit()
                    .frame(width: 120, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(backgroundColor)
                    .padding(.horizontal, 4)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(AppPressButtonStyle())
        .overlay(alignment: .topTrailing) {
            favoriteButton.padding(8)
        }
        .contextMenu {
            AppContextActions(
                title: app.displayName,
                isFavorite: isFavorite,
                onOpen: onOpen,
                onToggleFavorite: onToggleFavorite,
                onReveal: { NSWorkspace.shared.activateFileViewerSelecting([app.url]) },
                onCopyPath: { NSPasteboard.general.copyText(app.url.path) },
                onTrash: onTrash
            )
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .named(Self.listSpace))
                .onChanged { value in
                    onDragChanged(value.location)
                }
                .onEnded { value in
                    onDragEnded(value.location)
                }
        )
        .offset(dragOffset)
        .zIndex(isDragged ? 10 : 0)
        .shadow(color: .black.opacity(isDragged ? 0.3 : 0), radius: isDragged ? 10 : 0, y: isDragged ? 4 : 0)
        .onHover { hovered = $0 }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: hovered)
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8), value: isDragged)
        .help(app.url.path)
        .accessibilityLabel("\(app.displayName)，\(app.displaySize)")
        .accessibilityHint("点按打开应用，长按拖动可排序")
        .accessibilityIdentifier("apps.row.\(app.id)")
    }

    private var favoriteButton: some View {
        Button {
            onToggleFavorite()
        } label: {
            PikaIcon(isFavorite ? AppIconName.favoriteFilled : AppIconName.favorite,
                     size: 12,
                     color: isFavorite ? .cc.primary : .cc.mutedForeground)
                .frame(width: 20, height: 20)
                .background {
                    Circle().fill(Color.cc.muted.opacity(0.9))
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .opacity(isFavorite || hovered ? 1 : 0)
        .allowsHitTesting(isFavorite || hovered)
        .help(isFavorite ? "从收藏中移除" : "添加到收藏")
        .accessibilityLabel(isFavorite ? "从收藏中移除" : "添加到收藏")
    }

    private var backgroundColor: Color {
        if isDragged { return Color.cc.muted.opacity(0.4) }
        return hovered ? Color.cc.muted.opacity(0.55) : .clear
    }
}

// MARK: - Shared context menu

private struct AppContextActions: View {
    let title: String
    let isFavorite: Bool
    let onOpen: () -> Void
    let onToggleFavorite: () -> Void
    let onReveal: () -> Void
    let onCopyPath: () -> Void
    let onTrash: () -> Void

    var body: some View {
        Button("打开") { onOpen() }
        Button(isFavorite ? "从收藏中移除" : "添加到收藏") { onToggleFavorite() }
        Button("在访达中显示") { onReveal() }
        Button("拷贝路径") { onCopyPath() }
        Divider()
        Button("移到废纸篓…", role: .destructive) { onTrash() }
    }
}

// MARK: - Card frames preference

private struct CardFramesKey: SwiftUI.PreferenceKey {
    static var defaultValue: [String: CGRect] { [:] }
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - Press feedback style

/// 按压时轻微缩小并降低不透明度，给卡片和行一致的按压反馈。
struct AppPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension NSPasteboard {
    func copyText(_ string: String) {
        clearContents()
        writeObjects([string as NSString])
    }
}
