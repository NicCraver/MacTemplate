import ChunUI
import SwiftUI

struct SettingsTabPicker: View {
    @Binding var tab: SettingsTab
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var namespace
    @State private var hovered: SettingsTab?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(SettingsTab.allCases) { item in
                tabButton(item)
            }
        }
        .padding(4)
        .background(Color.cc.card, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.cc.border.opacity(0.6), lineWidth: CGFloat.cc.hairline)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("设置分类")
        .accessibilityIdentifier("settings.tabs")
    }

    private func tabButton(_ item: SettingsTab) -> some View {
        let selected = tab == item
        return Button {
            guard tab != item else { return }
            if reduceMotion {
                tab = item
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    tab = item
                }
            }
        } label: {
            HStack(spacing: 6) {
                PikaIcon(
                    item.icon,
                    size: 14,
                    color: selected ? .cc.primaryForeground : .cc.mutedForeground
                )
                Text(item.title)
                    .ccText(
                        font: selected ? .cc.smBold : .cc.sm,
                        color: selected ? .cc.primaryForeground : .cc.mutedForeground
                    )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background { pill(selected: selected, item: item) }
            .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { inside in
            hovered = inside ? item : (hovered == item ? nil : hovered)
        }
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("settings.tab.\(item.rawValue)")
    }

    @ViewBuilder
    private func pill(selected: Bool, item: SettingsTab) -> some View {
        if selected {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.cc.primary)
                .matchedGeometryEffect(id: "settingsTab", in: namespace)
        } else if hovered == item {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.cc.muted.opacity(0.55))
        }
    }
}
