import AppKit
import SwiftUI

enum MacChrome {
    static let sidebarWidth: CGFloat = 220
    static let sidebarRowHeight: CGFloat = 40
    static let pageInset: CGFloat = 20

    /// 窗口最小尺寸由「侧栏最小宽 + detail 最小宽」推出，所以下限必须挂在 detail 上。
    /// 挂到 WindowGroup 根视图会同时约束窗口和 detail 两级，而两者天然差一个侧栏宽度，
    /// 展开时 detail 排不进下限就会退化成整体平移，收尾再跳一下。
    static let detailMinWidth: CGFloat = 520
    static let detailMinHeight: CGFloat = 480

    /// 侧栏开合、选中条滑动共用。默认 `withAnimation` 是弹簧，回弹会让 detail 宽度过冲。
    static let sidebarAnimation = Animation.easeInOut(duration: 0.22)
}

/// 去掉标题栏分隔线，让侧栏材质连到窗口顶。
struct WindowChrome: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        TitlebarHost()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class TitlebarHost: NSView {
    private weak var configuredWindow: NSWindow?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        DispatchQueue.main.async { [weak self] in
            self?.apply()
        }
    }

    private func apply() {
        guard let window else { return }
        guard configuredWindow !== window else { return }
        configuredWindow = window
        window.titlebarSeparatorStyle = .none
        window.titlebarAppearsTransparent = true
    }
}
