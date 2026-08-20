import ChunUI
import SwiftUI

struct LibraryPage: View {
    @Environment(AppSession.self) private var session
    @State private var query = ""
    @State private var path = NavigationPath()
    @State private var hoveredID: String?
    @FocusState private var searchFocused: Bool

    private var filtered: [LibraryItem] {
        LibraryItem.filtered(LibraryItem.placeholders, query: query)
    }

    var body: some View {
        NavigationStack(path: $path) {
            MacPageScaffold(
                title: "资料库",
                subtitle: "搜索和打开资料",
                contentMaxWidth: .infinity
            ) {
                librarySearch
            } content: {
                libraryCard
            }
            .navigationDestination(for: LibraryItem.self) { item in
                LibraryDetailPage(item: item)
            }
        }
        .onChange(of: session.navigationEpoch) { _, _ in
            path = NavigationPath()
            query = ""
            searchFocused = false
            hoveredID = nil
        }
        .onKeyPress(.escape) {
            let action = LibraryNavigation.escapeAction(query: query, pathCount: path.count)
            guard action != .none else { return .ignored }
            handleEscape()
            return .handled
        }
        .background { shortcutButtons }
        .accessibilityIdentifier("library.page")
    }

    private var libraryCard: some View {
        CCAppleCard(radius: 16) {
            if filtered.isEmpty {
                CCEmptyState(
                    kind: .knowledge,
                    message: "没有匹配的资料",
                    detail: "换个关键词，或清空搜索",
                    compact: true
                )
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding(24)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, item in
                        libraryRow(item)
                        if index < filtered.count - 1 {
                            Rectangle()
                                .fill(Color.cc.border.opacity(0.5))
                                .frame(height: CGFloat.cc.hairline)
                                .padding(.leading, 66)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("library.list")
    }

    private func libraryRow(_ item: LibraryItem) -> some View {
        NavigationLink(value: item) {
            HStack(alignment: .center, spacing: 14) {
                PikaIcon(item.icon, size: 18, color: .cc.mutedForeground)
                    .frame(width: 36, height: 36)
                    .background(
                        Color.cc.muted,
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .ccText(font: .cc.baseBold, color: .cc.foreground)
                    Text(item.subtitle)
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                }
                Spacer(minLength: 8)
                PikaIcon(PikaIcon.Name.chevronRight, size: 14, color: .cc.mutedForeground)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if hoveredID == item.id {
                    Color.cc.muted.opacity(0.55)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { inside in
            hoveredID = inside ? item.id : (hoveredID == item.id ? nil : hoveredID)
        }
        .accessibilityLabel("\(item.title)，\(item.subtitle)")
        .accessibilityIdentifier("library.item.\(item.id)")
    }

    private var librarySearch: some View {
        HStack(spacing: 8) {
            PikaIcon(AppIconName.search, size: 14, color: .cc.mutedForeground)
            TextField("搜索资料", text: $query)
                .textFieldStyle(.plain)
                .ccText(font: .cc.sm, color: .cc.foreground)
                .focused($searchFocused)
                .onSubmit(openFirstMatch)
                .accessibilityIdentifier("library.search")
            if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button {
                    query = ""
                } label: {
                    PikaIcon(AppIconName.close, size: 12, color: .cc.mutedForeground)
                }
                .buttonStyle(.plain)
                .help("清除搜索")
                .accessibilityLabel("清除搜索")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(minWidth: 180, idealWidth: 240, maxWidth: 280)
        .background(Color.cc.muted, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(
                    searchFocused ? Color.cc.primary.opacity(0.7) : Color.clear,
                    lineWidth: 1
                )
        }
    }

    private var shortcutButtons: some View {
        Button("搜索资料") {
            guard LibraryNavigation.canFocusSearch(pathCount: path.count) else { return }
            searchFocused = true
        }
        .keyboardShortcut("f", modifiers: .command)
        .opacity(0)
        .frame(width: 0, height: 0)
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private func openFirstMatch() {
        guard let item = LibraryNavigation.firstMatch(LibraryItem.placeholders, query: query) else {
            return
        }
        path.append(item)
    }

    private func handleEscape() {
        switch LibraryNavigation.escapeAction(query: query, pathCount: path.count) {
        case .pop:
            path.removeLast()
        case .clearSearch:
            query = ""
            searchFocused = false
        case .none:
            break
        }
    }
}
