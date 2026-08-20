import ChunUI
import SwiftUI

struct AboutView: View {
    var body: some View {
        AboutIdentityView(showsTagline: true)
            .padding(.horizontal, 36)
            .padding(.vertical, 28)
            .frame(width: 360)
            .background(Color.cc.background)
            .accessibilityIdentifier("about.window")
    }
}
