import AppKit
import ChunUI
import SwiftUI

struct AboutIdentityView: View {
    var showsTagline: Bool = false
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .frame(width: 72, height: 72)

            Text(AppInfo.displayName)
                .ccText(font: .cc.lgBold, color: .cc.foreground)

            Text("版本 \(AppInfo.version)")
                .ccText(font: .cc.sm, color: .cc.mutedForeground)

            if showsTagline {
                Text("日常开发骨架 · ChunUI")
                    .ccText(font: .cc.sm, color: .cc.mutedForeground)
            }

            Text(AppInfo.copyright)
                .ccText(font: .cc.sm, color: .cc.mutedForeground)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                CCNeoButton(actionTitle, variant: .secondary, size: .medium) {
                    action()
                }
            }
        }
    }
}
