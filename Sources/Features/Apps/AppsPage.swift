import ChunUI
import SwiftUI

struct AppsPage: View {
    @Environment(AppLibrary.self) private var library
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var query = ""
    @State private var pendingTrash: AppEntry?
    @FocusState private var searchFocused: Bool

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
            ForEach(library.visibleApps) { app in
                AppCard(app: app, library: library) { pendingTrash = $0 }
            }
        }
        .accessibilityIdentifier("apps.grid")
    }

    private var listView: some View {
        CCAppleCard(radius: 16) {
            LazyVStack(spacing: 0) {
                ForEach(library.visibleApps) { app in
                    AppRow(app: app, library: library) { pendingTrash = $0 }
                }
            }
        }
        .accessibilityIdentifier("apps.list")
    }
}

// MARK: - Grid card

/// 独立视图：悬停状态本地化，滚动/悬停只重渲染当前卡片，不牵动整页。
private struct AppCard: View {
    let app: AppEntry
    let library: AppLibrary
    let onTrashRequest: (AppEntry) -> Void
    @State private var hovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            library.open(app)
        } label: {
            VStack(spacing: 8) {
                Image(nsImage: app.icon)
                    .resizable()
                    .frame(width: 64, height: 64)
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
                    .fill(hovered ? Color.cc.muted.opacity(0.55) : .clear)
            }
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(AppPressButtonStyle())
        .contextMenu { AppContextActions(app: app, library: library, onTrashRequest: onTrashRequest) }
        .onHover { hovered = $0 }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: hovered)
        .help(app.url.path)
        .accessibilityHint("点按打开应用")
        .accessibilityIdentifier("apps.card.\(app.id)")
    }
}

// MARK: - List row

private struct AppRow: View {
    let app: AppEntry
    let library: AppLibrary
    let onTrashRequest: (AppEntry) -> Void
    @State private var hovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            library.open(app)
        } label: {
            HStack(spacing: 14) {
                Image(nsImage: app.icon)
                    .resizable()
                    .frame(width: 32, height: 32)

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
                    .fill(hovered ? Color.cc.muted.opacity(0.55) : .clear)
                    .padding(.horizontal, 4)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(AppPressButtonStyle())
        .contextMenu { AppContextActions(app: app, library: library, onTrashRequest: onTrashRequest) }
        .onHover { hovered = $0 }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: hovered)
        .help(app.url.path)
        .accessibilityLabel("\(app.displayName)，\(app.displaySize)")
        .accessibilityHint("点按打开应用")
        .accessibilityIdentifier("apps.row.\(app.id)")
    }
}

// MARK: - Shared context menu

private struct AppContextActions: View {
    let app: AppEntry
    let library: AppLibrary
    let onTrashRequest: (AppEntry) -> Void

    var body: some View {
        Button("打开") { library.open(app) }
        Button("在访达中显示") { library.reveal(app) }
        Button("拷贝路径") { library.copyPath(app) }
        Divider()
        Button("移到废纸篓…", role: .destructive) { onTrashRequest(app) }
    }
}

/// 按压时轻微缩小并降低不透明度，给卡片和行一致的按压反馈。
struct AppPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
