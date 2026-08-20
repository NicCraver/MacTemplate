import ChunUI
import SwiftUI

struct SettingsGroupCard<Content: View>: View {
    let title: String?
    @ViewBuilder var content: () -> Content

    init(_ title: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .ccText(font: .cc.sm, color: .cc.mutedForeground)
                    .padding(.horizontal, 4)
            }
            CCAppleCard(radius: 16) {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
