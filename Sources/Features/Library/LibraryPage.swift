import ChunUI
import SwiftUI

struct LibraryPage: View {
    @Environment(AppSession.self) private var session
    @State private var query = ""
    @State private var path = NavigationPath()
    @FocusState private var searchFocused: Bool

    private var filtered: [LibraryItem] {
        LibraryItem.filtered(LibraryItem.placeholders, query: query)
    }

    var body: some View {
        NavigationStack(path: $path) {
            MacPageScaffold(
                title: "资料库",
                subtitle: "搜索和打开资料",
                scrolls: false
            ) {
                librarySearch
            } content: {
                if filtered.isEmpty {
                    CCEmptyState(
                        kind: .knowledge,
                        message: "没有匹配的资料",
                        detail: "换个关键词，或清空搜索",
                        compact: true
                    )
                    .frame(maxWidth: .infinity, minHeight: 240)
                } else {
                    libraryList
                }
            }
            .navigationDestination(for: LibraryItem.self) { item in
                LibraryDetailPage(item: item)
            }
        }
        .onChange(of: session.navigationEpoch) { _, _ in
            path = NavigationPath()
            query = ""
            searchFocused = false
        }
        .background { shortcutButtons }
        .accessibilityIdentifier("library.page")
    }

    private var libraryList: some View {
        List(filtered) { item in
            NavigationLink(value: item) {
                libraryRow(item)
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .listRowSeparatorTint(Color.cc.border.opacity(0.5))
            .listRowBackground(Color.cc.card)
            .accessibilityLabel("\(item.title)，\(item.subtitle)")
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cc.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.cc.border.opacity(0.5), lineWidth: CGFloat.cc.hairline)
        }
        .accessibilityIdentifier("library.list")
    }

    private func libraryRow(_ item: LibraryItem) -> some View {
        HStack(alignment: .center, spacing: 16) {
            PikaIcon(PikaIcon.Name.fileText, size: 20, color: .cc.mutedForeground)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .ccText(font: .cc.baseBold, color: .cc.foreground)
                Text(item.subtitle)
                    .ccText(font: .cc.sm, color: .cc.mutedForeground)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var librarySearch: some View {
        HStack(spacing: 8) {
            PikaIcon(AppIconName.search, size: 14, color: .cc.mutedForeground)
            TextField("搜索资料", text: $query)
                .textFieldStyle(.plain)
                .ccText(font: .cc.sm, color: .cc.foreground)
                .focused($searchFocused)
                .accessibilityIdentifier("library.search")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(width: 220)
        .background(Color.cc.muted, in: Capsule())
    }

    private var shortcutButtons: some View {
        ZStack {
            Button("搜索资料") {
                searchFocused = true
            }
            .keyboardShortcut("f", modifiers: .command)

            Button("返回") {
                handleEscape()
            }
            .keyboardShortcut(.escape, modifiers: [])
        }
        .opacity(0)
        .frame(width: 0, height: 0)
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private func handleEscape() {
        switch LibraryNavigation.escapeAction(query: query, pathCount: path.count) {
        case .pop:
            path.removeLast()
        case .clearSearch:
            query = ""
        case .none:
            break
        }
    }
}
