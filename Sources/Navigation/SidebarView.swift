import ChunUI
import SwiftUI

/// 全高侧边栏：上半部分是应用库分类（含收藏/常用），底部钉住设置。
/// 分类行高亮 = 应用页当前分类；「收藏」行接受应用拖放以加入收藏。
struct SidebarView: View {
    @Environment(AppSession.self) private var session
    @Environment(AppLibrary.self) private var library
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var favoriteRowTargeted = false

    var onToggleSidebar: (() -> Void)?

    private var selectionAnimation: Animation? {
        reduceMotion ? nil : MacChrome.sidebarAnimation
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            header
            categoryRows
            Spacer(minLength: 0)
            settingsRow
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .animation(selectionAnimation, value: session.section)
        .animation(selectionAnimation, value: library.category)
        .accessibilityIdentifier("sidebar")
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text(AppInfo.displayName)
                .ccText(font: .cc.smBold, color: .cc.mutedForeground)
                .lineLimit(1)
            Spacer(minLength: 0)
            Button {
                onToggleSidebar?()
            } label: {
                PikaIcon(PikaIcon.Name.close, size: 14, color: .cc.mutedForeground)
                    .frame(width: 24, height: 22)
            }
            .buttonStyle(.plain)
            .help("收起侧边栏")
            .accessibilityLabel("收起侧边栏")
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var categoryRows: some View {
        @Bindable var library = library
        VStack(alignment: .leading, spacing: 2) {
            ForEach(AppLibrary.Category.allCases, id: \.self) { category in
                categoryRow(category)
            }
        }
    }

    private func categoryRow(_ category: AppLibrary.Category) -> some View {
        let selected = session.section == .apps && library.category == category
        let acceptsDrop = category == .favorites
        return Button {
            if session.section != .apps { session.go(to: .apps) }
            library.category = category
        } label: {
            HStack(spacing: 8) {
                PikaIcon(category.iconName, size: 16,
                         color: selected ? .cc.primary : .cc.mutedForeground)
                Text(category.title)
                    .ccText(font: .cc.sm, color: selected ? .cc.primary : .cc.foreground)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text("\(library.categoryCount(category))")
                    .ccText(font: .cc.sm, color: selected ? .cc.primary.opacity(0.8) : .cc.mutedForeground)
                    .monospacedDigit()
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: MacChrome.sidebarRowHeight, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(rowFill(selected: selected, targeted: favoriteRowTargeted && acceptsDrop))
            }
            .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
        .help(acceptsDrop ? "拖入应用即可收藏" : category.title)
        .dropDestination(for: String.self) { items, _ in
            guard acceptsDrop, let identityKey = items.first else { return false }
            library.addFavorite(identityKey: identityKey)
            return true
        } isTargeted: { targeted in
            favoriteRowTargeted = targeted
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(category.title)，\(library.categoryCount(category)) 个应用")
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("sidebar.category.\(category.rawValue)")
    }

    private var settingsRow: some View {
        let selected = session.section == .settings
        return Button {
            session.go(to: .settings)
        } label: {
            HStack(spacing: 8) {
                PikaIcon(AppIconName.settings, size: 16,
                         color: selected ? .cc.primary : .cc.mutedForeground)
                Text(AppSection.settings.title)
                    .ccText(font: .cc.sm, color: selected ? .cc.primary : .cc.foreground)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: MacChrome.sidebarRowHeight, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(selected ? Color.cc.primary.opacity(0.14) : .clear)
            }
            .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppSection.settings.title)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("sidebar.settings")
    }

    private func rowFill(selected: Bool, targeted: Bool) -> Color {
        if targeted { return Color.cc.primary.opacity(0.22) }
        if selected { return Color.cc.muted.opacity(0.75) }
        return .clear
    }
}
