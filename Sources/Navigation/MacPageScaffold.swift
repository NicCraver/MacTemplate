import ChunUI
import SwiftUI

struct MacPageScaffold<Trailing: View, Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var onBack: (() -> Void)? = nil
    var contentMaxWidth: CGFloat = 720
    var scrolls: Bool = true
    @ViewBuilder var trailing: () -> Trailing
    @ViewBuilder var content: () -> Content

    init(
        title: String,
        subtitle: String? = nil,
        onBack: (() -> Void)? = nil,
        contentMaxWidth: CGFloat = 720,
        scrolls: Bool = true,
        @ViewBuilder trailing: @escaping () -> Trailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.onBack = onBack
        self.contentMaxWidth = contentMaxWidth
        self.scrolls = scrolls
        self.trailing = trailing
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            chrome
            if scrolls {
                ScrollView {
                    contentColumn
                }
            } else {
                contentColumn
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.cc.background)
    }

    private var contentColumn: some View {
        VStack(alignment: .leading, spacing: 20) {
            content()
        }
        .padding(.horizontal, MacChrome.pageInset)
        .padding(.bottom, MacChrome.pageInset)
        .pageColumn(maxWidth: contentMaxWidth)
    }

    private var chrome: some View {
        HStack(alignment: .top, spacing: 10) {
            if let onBack {
                Button(action: onBack) {
                    PikaIcon(PikaIcon.Name.arrowLeft, size: 16, color: .cc.mutedForeground)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("返回")
                .accessibilityLabel("返回")
            }
            PageHeader(title: title, subtitle: subtitle, trailing: trailing)
        }
        .padding(.horizontal, MacChrome.pageInset)
        .padding(.top, MacChrome.pageInset)
        .padding(.bottom, MacChrome.pageInset)
        .geometryGroup()
    }
}

extension MacPageScaffold where Trailing == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        onBack: (() -> Void)? = nil,
        contentMaxWidth: CGFloat = 720,
        scrolls: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            onBack: onBack,
            contentMaxWidth: contentMaxWidth,
            scrolls: scrolls,
            trailing: { EmptyView() },
            content: content
        )
    }
}

extension View {
    func pageColumn(maxWidth: CGFloat = 720) -> some View {
        frame(maxWidth: maxWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
