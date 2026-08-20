import ChunUI
import SwiftUI

struct RootSplitView: View {
    @Environment(AppSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        @Bindable var session = session
        NavigationSplitView(columnVisibility: $session.sidebarVisibility) {
            SidebarView(section: $session.section)
                .navigationSplitViewColumnWidth(
                    min: 180,
                    ideal: MacChrome.sidebarWidth,
                    max: 280
                )
        } detail: {
            ZStack(alignment: .topLeading) {
                session.section.destination
                    .id(session.section)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(Color.cc.background)
                    .transition(.opacity)
            }
            .frame(
                minWidth: MacChrome.detailMinWidth,
                maxWidth: .infinity,
                minHeight: MacChrome.detailMinHeight,
                maxHeight: .infinity
            )
            .animation(reduceMotion ? nil : MacChrome.sidebarAnimation, value: session.section)
        }
        .navigationSplitViewStyle(.balanced)
        .tint(Color.cc.primary)
        .toolbar(removing: .title)
        .toolbar(removing: .sidebarToggle)
        .background(WindowChrome())
        .accessibilityIdentifier("root.split")
    }
}
