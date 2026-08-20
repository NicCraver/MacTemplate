import ChunUI
import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppTheme.self) private var theme

    var body: some View {
        @Bindable var theme = theme
        VStack(alignment: .leading, spacing: 20) {
            SettingsGroupCard("主题") {
                HStack(spacing: 12) {
                    Text("外观")
                        .ccText(font: .cc.base, color: .cc.foreground)
                    Spacer(minLength: 12)
                    Picker("外观", selection: $theme.appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .horizontalRadioGroupLayout()
                    .labelsHidden()
                    .accessibilityIdentifier("settings.appearance")
                }
                .padding(16)
            }

            SettingsGroupCard("品牌色") {
                VStack(alignment: .leading, spacing: 16) {
                    Text("全应用只有这一个彩色。选中后会重建窗口以套用 ChunUI 色板。")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                    HStack(spacing: 16) {
                        ForEach(BrandColor.presets) { preset in
                            brandSwatch(preset)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            previewCard
        }
    }

    private var previewCard: some View {
        CCAppleCard(radius: 16) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.cc.primary)
                    .frame(width: 8, height: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前品牌色 · \(theme.brand.name)")
                        .ccText(font: .cc.smBold, color: .cc.foreground)
                    Text("#\(theme.brand.hex)")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
        }
    }

    private func brandSwatch(_ preset: BrandColor) -> some View {
        let selected = theme.brandHex.caseInsensitiveCompare(preset.hex) == .orderedSame
        return Button {
            theme.brand = preset
        } label: {
            VStack(spacing: 8) {
                Circle()
                    .fill(Color.hex(preset.hex))
                    .frame(width: 28, height: 28)
                    .overlay {
                        Circle()
                            .stroke(
                                Color.cc.foreground.opacity(selected ? 0.9 : 0.15),
                                lineWidth: selected ? 2 : 1
                            )
                    }
                Text(preset.name)
                    .ccText(
                        font: selected ? .cc.smBold : .cc.sm,
                        color: selected ? .cc.foreground : .cc.mutedForeground
                    )
            }
            .frame(width: 72)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(preset.name)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityIdentifier("settings.brand.\(preset.id)")
    }
}
