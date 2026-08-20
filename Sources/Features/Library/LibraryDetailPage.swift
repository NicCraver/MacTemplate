import ChunUI
import SwiftUI

struct LibraryDetailPage: View {
    let item: LibraryItem

    var body: some View {
        MacPageScaffold(title: item.title, subtitle: item.subtitle) {
            CCAppleCard(radius: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        PikaIcon(item.icon, size: 20, color: .cc.mutedForeground)
                            .frame(width: 40, height: 40)
                            .background(
                                Color.cc.muted,
                                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                            )
                        Text("占位正文")
                            .ccText(font: .cc.baseBold, color: .cc.foreground)
                    }
                    Text("换成文档正文、预览或编辑器。Esc 返回列表。")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityIdentifier("library.detail")
    }
}
