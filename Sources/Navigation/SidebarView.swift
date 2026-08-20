import ChunUI
import SwiftUI

struct SidebarView: View {
    @Binding var section: AppSection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var selectionNamespace
    @State private var hovered: AppSection?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            header
            ForEach(AppSection.primary) { item in
                sidebarRow(item)
            }
            Spacer(minLength: 0)
            sidebarRow(.settings)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .animation(selectionAnimation, value: section)
        .accessibilityIdentifier("sidebar")
    }

    private var selectionAnimation: Animation? {
        reduceMotion ? nil : MacChrome.sidebarAnimation
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text(AppInfo.displayName)
                .ccText(font: .cc.smBold, color: .cc.mutedForeground)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func sidebarRow(_ item: AppSection) -> some View {
        let selected = section == item
        let color: Color = selected ? .cc.foreground : .cc.mutedForeground
        return Button {
            section = item
        } label: {
            Label {
                Text(item.title)
                    .ccText(font: .cc.sm, color: color)
            } icon: {
                PikaIcon(item.icon, size: 16, color: color)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: MacChrome.sidebarRowHeight, alignment: .leading)
            .background { rowBackground(item, selected: selected) }
            .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { inside in
            hovered = inside ? item : (hovered == item ? nil : hovered)
        }
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("sidebar.\(item.rawValue)")
    }

    @ViewBuilder
    private func rowBackground(_ item: AppSection, selected: Bool) -> some View {
        if selected {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.cc.primary)
                .matchedGeometryEffect(id: "sidebarSelection", in: selectionNamespace)
        } else if hovered == item {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.cc.muted.opacity(0.55))
        }
    }
}
