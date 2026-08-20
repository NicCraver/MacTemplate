import ChunUI
import SwiftUI

struct OverviewPage: View {
    @State private var showsPlaceholder = false

    var body: some View {
        MacPageScaffold(
            title: "概览",
            subtitle: "从这里开始搭你的 Mac 应用",
            contentMaxWidth: .infinity
        ) {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 152), spacing: 12)],
                spacing: 12
            ) {
                metricCard(title: "项目", value: "12", tag: "本周")
                metricCard(title: "待办", value: "4", tag: "进行中")
                metricCard(title: "完成", value: "28", tag: "累计")
            }

            CCAppleCard(radius: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("下一步")
                        .ccText(font: .cc.baseBold, color: .cc.foreground)
                    Text("改侧栏分区与本页内容。外观和品牌色在左侧「设置」里改。开新 App 跑 Scripts/rename.sh。")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                    CCNeoButton("新建项目", variant: .primary, size: .medium, icon: PikaIcon.Name.plus) {
                        showsPlaceholder = true
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .alert("占位", isPresented: $showsPlaceholder) {
            Button("好", role: .cancel) {}
        } message: {
            Text("换成你的创建流程。")
        }
        .accessibilityIdentifier("overview.page")
    }

    private func metricCard(title: String, value: String, tag: String) -> some View {
        CCAppleCard(radius: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                    Spacer()
                    CCCuteTag(tag)
                }
                Text(value)
                    .ccText(font: .cc.lgBold, color: .cc.foreground)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
