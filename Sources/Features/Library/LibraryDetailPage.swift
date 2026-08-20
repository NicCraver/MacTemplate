import ChunUI
import SwiftUI

struct LibraryDetailPage: View {
    let item: LibraryItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        MacPageScaffold(title: item.title, subtitle: item.subtitle, onBack: { dismiss() }) {
            CCAppleCard(radius: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("这是详情占位。换成文档正文、预览或编辑器。")
                        .ccText(font: .cc.sm, color: .cc.mutedForeground)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityIdentifier("library.detail")
    }
}
