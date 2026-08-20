import ChunUI
import SwiftUI

struct MacPageScaffold<Trailing: View, Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var contentMaxWidth: CGFloat = 720
    var scrolls: Bool = true
    @ViewBuilder var trailing: () -> Trailing
    @ViewBuilder var content: () -> Content

    init(
        title: String,
        subtitle: String? = nil,
        contentMaxWidth: CGFloat = 720,
        scrolls: Bool = true,
        @ViewBuilder trailing: @escaping () -> Trailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
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
        PageHeader(title: title, subtitle: subtitle, trailing: trailing)
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
        contentMaxWidth: CGFloat = 720,
        scrolls: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
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
