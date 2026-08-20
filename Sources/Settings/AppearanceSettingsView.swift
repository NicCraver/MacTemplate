import ChunUI
import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppTheme.self) private var theme

    var body: some View {
        @Bindable var theme = theme
        VStack(alignment: .leading, spacing: 20) {
            SettingsGroupCard("外观") {
                HStack(alignment: .center, spacing: 16) {
                    Text("主题")
                        .ccText(font: .cc.base, color: .cc.foreground)
                    Spacer(minLength: 12)
                    Picker("主题", selection: $theme.appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .fixedSize(horizontal: true, vertical: false)
                    .accessibilityIdentifier("settings.appearance")
                }
                .padding(16)
            }

            SettingsGroupCard("品牌色") {
                VStack(alignment: .leading, spacing: 16) {
                    Text("全应用只有这一个彩色。")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                    HStack(spacing: 12) {
                        ForEach(BrandColor.presets) { preset in
                            brandSwatch(preset)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .padding(16)
            }
        }
    }

    private func brandSwatch(_ preset: BrandColor) -> some View {
        let selected = theme.brandHex.caseInsensitiveCompare(preset.hex) == .orderedSame
        return Button {
            theme.brand = preset
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.hex(preset.hex))
                        .frame(width: 28, height: 28)
                    Circle()
                        .strokeBorder(
                            selected ? Color.cc.foreground : Color.cc.foreground.opacity(0.14),
                            lineWidth: selected ? 2 : 1
                        )
                        .frame(width: 36, height: 36)
                }
                .frame(width: 36, height: 36)
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
        .help("\(preset.name) · #\(preset.hex)")
        .accessibilityLabel(preset.name)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityIdentifier("settings.brand.\(preset.id)")
    }
}
