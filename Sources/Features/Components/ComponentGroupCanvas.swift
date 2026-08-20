import ChunUI
import SwiftUI

struct ComponentGroupCanvas: View {
    let group: ComponentGroup

    var body: some View {
        switch group {
        case .tokens:
            TokensGallery()
        case .buttons:
            ButtonsGallery()
        case .forms:
            FormsGallery()
        case .cards:
            CardsGallery()
        case .rows:
            RowsGallery()
        case .feedback:
            FeedbackGallery()
        case .text:
            TextGallery()
        case .motion:
            MotionGallery()
        }
    }
}

private struct TokensGallery: View {
    private let swatches: [(String, Color)] = [
        ("primary", .cc.primary),
        ("background", .cc.background),
        ("card", .cc.card),
        ("muted", .cc.muted),
        ("accent", .cc.accent),
        ("border", .cc.border),
        ("destructive", .cc.destructive),
        ("success", .cc.success),
        ("foreground", .cc.foreground),
        ("mutedFg", .cc.mutedForeground),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 88), spacing: 10)],
                spacing: 10
            ) {
                ForEach(swatches, id: \.0) { name, color in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(color)
                            .frame(height: 40)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(Color.cc.border, lineWidth: CGFloat.cc.hairline)
                            }
                        Text(name)
                            .ccText(font: .cc.sm, color: .cc.mutedForeground)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("页面标题 · lg")
                    .ccText(font: .cc.lgBold, color: .cc.foreground)
                Text("正文锚点 · base")
                    .ccText(font: .cc.base, color: .cc.foreground)
                Text("辅助说明 · sm")
                    .ccText(font: .cc.sm, color: .cc.mutedForeground)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ButtonsGallery: View {
    @State private var lastTap = "点一个按钮试试"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(lastTap)
                .ccText(font: .cc.sm, color: .cc.mutedForeground)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 132), spacing: 10)],
                spacing: 10
            ) {
                CCNeoButton("Primary", variant: .primary, fullWidth: true) {
                    lastTap = "Primary"
                    try? await Task.sleep(nanoseconds: 600_000_000)
                }
                CCNeoButton("Secondary", variant: .secondary, fullWidth: true) {
                    lastTap = "Secondary"
                }
                CCNeoButton("Ghost", variant: .ghost, fullWidth: true) {
                    lastTap = "Ghost"
                }
                CCNeoButton("Outline", variant: .outline, fullWidth: true) {
                    lastTap = "Outline"
                }
                CCNeoButton("Danger", variant: .danger, icon: PikaIcon.Name.trash, fullWidth: true) {
                    lastTap = "Danger"
                }
                CCNeoButton("不可用", variant: .secondary, fullWidth: true, disabled: true) {}
            }

            HStack(spacing: 10) {
                CCNeoButton("Large", size: .large) { lastTap = "Large" }
                CCNeoButton("Medium", size: .medium) { lastTap = "Medium" }
                CCNeoButton("Small", size: .small, icon: PikaIcon.Name.plus) { lastTap = "Small" }
                Spacer(minLength: 0)
            }

            HStack(spacing: 12) {
                CCDesigin.GlassIconButton(icon: PikaIcon.Name.search) {
                    lastTap = "搜索"
                }
                CCDesigin.GlassIconButton(icon: AppIconName.settings, tint: .cc.primary, size: .small) {
                    lastTap = "设置"
                }
                CCDesigin.CircleButton(icon: PikaIcon.Name.arrowLeft) {
                    lastTap = "返回"
                }
                CCDesigin.CCTagButton(icon: PikaIcon.Name.plus, text: "添加") {
                    lastTap = "标签按钮"
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FormsGallery: View {
    @State private var name = ""
    @State private var note = ""
    @State private var neo = ""
    @State private var notify = true
    @State private var remember = true
    @State private var weekly = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            labeled("单行输入") {
                CCDesigin.CCInput(placeholder: "给你的项目起个名字", text: $name)
            }
            labeled("微拟物输入") {
                CCNeoInput(placeholder: "搜索资料", text: $neo, icon: AppIconName.search)
            }
            labeled("多行输入") {
                CCDesigin.CCTextArea(placeholder: "写一点说明", text: $note)
            }

            HStack(spacing: 20) {
                HStack(spacing: 10) {
                    Text("通知")
                        .ccText(font: .cc.base, color: .cc.foreground)
                    CCDesigin.CCToggle(isOn: $notify)
                }
                CCDesigin.CCCheckbox(isChecked: $remember, label: "记住选择")
                CCDesigin.CCCheckbox(isChecked: $weekly, label: "每周摘要")
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func labeled<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .ccText(font: .cc.sm, color: .cc.mutedForeground)
            content()
        }
    }
}

private struct CardsGallery: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CCAppleCard(radius: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Apple Card")
                        .ccText(font: .cc.baseBold, color: .cc.foreground)
                    Text("连续圆角、发丝边、软阴影。")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 8) {
                CCCuteTag("128 人", icon: "user-love-heart")
                CCCuteTag("本周", icon: AppIconName.checklist)
                CCKeycapTag("BETA")
                CCProTag()
                Spacer(minLength: 0)
            }

            CCChipFlow(spacing: 8) {
                ForEach(["SwiftUI", "ChunUI", "macOS", "Pika", "Neo", "Glass"], id: \.self) { chip in
                    Text(chip)
                        .ccText(font: .cc.sm, color: .cc.foreground)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.cc.muted, in: Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RowsGallery: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 0) {
                CCSettingRow(icon: AppIconName.settings, title: "通用", trailing: .chevron)
                rowDivider
                CCSettingRow(icon: "sparkle-ai01", title: "会员", trailing: .pro)
                rowDivider
                CCSettingRow(icon: AppIconName.library, title: "资料库", trailing: .text("12 项"))
                rowDivider
                CCSettingRow(icon: AppIconName.document, title: "版本", trailing: .value("1.0.0"))
            }
            .ccGroupCard()

            HStack(spacing: 8) {
                quickAction(icon: PikaIcon.Name.plus, title: "新建")
                quickAction(icon: PikaIcon.Name.search, title: "搜索")
                quickAction(icon: PikaIcon.Name.copy, title: "复制")
                quickAction(icon: PikaIcon.Name.save, title: "保存")
            }
            .ccGroupCard()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.cc.border.opacity(0.5))
            .frame(height: CGFloat.cc.hairline)
            .padding(.leading, CCSettingRow.separatorInset)
    }

    private func quickAction(icon: String, title: String) -> some View {
        CCQuickAction(icon: icon, title: title)
    }
}

private struct FeedbackGallery: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                CCEmptyState(
                    kind: .knowledge,
                    message: "还没有内容",
                    detail: "换成你的空态文案",
                    imageSize: 120,
                    compact: true
                )
                CCEmptyState(
                    kind: .tools,
                    message: "没有可用工具",
                    detail: "统一走 CCEmptyState",
                    imageSize: 120,
                    compact: true
                )
            }

            CCSkeleton {
                HStack(alignment: .top, spacing: 12) {
                    CCBone(height: 44, circle: true)
                    VStack(alignment: .leading, spacing: 8) {
                        CCBone(width: 120, height: 12)
                        CCBoneText(lines: 2)
                    }
                }
            }

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.cc.muted)
                .frame(height: 56)
                .overlay {
                    Text("shimmer")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                }
                .shimmer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TextGallery: View {
    @State private var streamed = ""
    private let full = "流式文本会带着光标逐字浮现，稳定后光标自动隐藏。"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("打字机")
                    .ccText(font: .cc.sm, color: .cc.mutedForeground)
                CCDesigin.CCTyperText(
                    "质感是一种可以携带的资产。",
                    duration: 2.4,
                    madaEnable: false,
                    font: .cc.base,
                    color: .cc.foreground
                )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("流式输出")
                    .ccText(font: .cc.sm, color: .cc.mutedForeground)
                CCStreamingText(
                    streamed,
                    font: .cc.base,
                    color: .cc.foreground,
                    madaEnable: false
                )
                .frame(minHeight: 24, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Markdown")
                    .ccText(font: .cc.sm, color: .cc.mutedForeground)
                MarkdownText(
                    "支持 **粗体**、*斜体* 和 `行内代码`。",
                    font: .cc.base,
                    color: .cc.foreground
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            streamed = ""
            for character in full {
                streamed.append(character)
                try? await Task.sleep(nanoseconds: 36_000_000)
            }
        }
    }
}

private struct MotionGallery: View {
    @State private var shown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 8) {
                ForEach(0 ..< 4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.cc.muted)
                        .frame(height: 36)
                        .overlay {
                            Text("ccReveal · \(index + 1)")
                                .ccText(font: .cc.sm, color: .cc.mutedForeground)
                        }
                        .ccReveal(shown, index: index)
                }
            }

            HStack(spacing: 8) {
                ForEach(0 ..< 5, id: \.self) { index in
                    Circle()
                        .fill(Color.cc.primary.opacity(0.85))
                        .frame(width: 28, height: 28)
                        .ccWaveReveal(shown, index: index)
                }
                Spacer(minLength: 0)
            }

            CCNeoButton("重播入场", variant: .outline, size: .small) {
                shown = false
                try? await Task.sleep(nanoseconds: 220_000_000)
                shown = true
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            shown = true
        }
    }
}
