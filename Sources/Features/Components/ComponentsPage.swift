import ChunUI
import SwiftUI

struct ComponentsPage: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var filter: ComponentGroup?
    @State private var revealed = false

    var body: some View {
        MacPageScaffold(
            title: "基础组件",
            subtitle: "点一下就能试的 ChunUI 积木",
            contentMaxWidth: .infinity
        ) {
            filterChips
            ForEach(Array(ComponentGroup.visible(filter: filter).enumerated()), id: \.element.id) { index, group in
                SettingsGroupCard(group.title) {
                    ComponentGroupCanvas(group: group)
                        .padding(16)
                }
                .ccReveal(reduceMotion || revealed, index: index)
            }
        }
        .onAppear {
            revealed = true
        }
        .onChange(of: filter) { _, _ in
            replayReveal()
        }
        .accessibilityIdentifier("components.page")
    }

    private var filterChips: some View {
        CCChipFlow(spacing: 8) {
            filterChip(title: "全部", group: nil)
            ForEach(ComponentGroup.allCases) { group in
                filterChip(title: group.title, group: group)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("components.filter")
    }

    private func filterChip(title: String, group: ComponentGroup?) -> some View {
        let selected = filter == group
        return Button {
            filter = group
        } label: {
            HStack(spacing: 6) {
                if let group {
                    PikaIcon(
                        group.icon,
                        size: 12,
                        color: selected ? .cc.primaryForeground : .cc.mutedForeground
                    )
                }
                Text(title)
                    .ccText(
                        font: selected ? .cc.smBold : .cc.sm,
                        color: selected ? .cc.primaryForeground : .cc.foreground
                    )
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(selected ? Color.cc.primary : Color.cc.muted, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier(group.map { "components.filter.\($0.rawValue)" } ?? "components.filter.all")
    }

    private func replayReveal() {
        guard !reduceMotion else { return }
        revealed = false
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 80_000_000)
            revealed = true
        }
    }
}
