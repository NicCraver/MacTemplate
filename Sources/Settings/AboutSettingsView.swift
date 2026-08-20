import ChunUI
import SwiftUI

struct AboutSettingsView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        CCAppleCard(radius: 16) {
            AboutIdentityView(
                actionTitle: "打开关于窗口",
                action: { openWindow(id: "about") }
            )
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: 420)
    }
}
