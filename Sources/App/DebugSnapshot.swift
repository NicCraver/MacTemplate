import AppKit
import SwiftUI

/// 开发验证工具：设置环境变量 APPLIST_SNAPSHOT=<png 路径> 后，启动约 8 秒
/// 把主窗口渲染成 PNG（APPLIST_SNAPSHOT_EXIT=1 时随后退出），供自动化检查。
struct SnapshotWatcher: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { SnapshotHost() }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class SnapshotHost: NSView {
    private var scheduled = false

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard !scheduled, window != nil else { return }
        scheduled = true

        guard let path = ProcessInfo.processInfo.environment["APPLIST_SNAPSHOT"] else { return }
        let exitAfter = ProcessInfo.processInfo.environment["APPLIST_SNAPSHOT_EXIT"] == "1"

        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            guard let contentView = self?.window?.contentView else { return }
            // 主题帧（contentView.superview）包含标题栏与红绿灯；拿不到就退回内容区。
            let view = contentView.superview ?? contentView
            if let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) {
                view.cacheDisplay(in: view.bounds, to: rep)
                if let data = rep.representation(using: .png, properties: [:]) {
                    try? data.write(to: URL(fileURLWithPath: path))
                }
            }
            if exitAfter { NSApp.terminate(nil) }
        }
    }
}
