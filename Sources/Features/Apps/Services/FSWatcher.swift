import AppKit
import Foundation

/// 监听多个目录的变更，去抖后在主线程回调。
/// source 的 queue 是 .main，回调里用 MainActor.assumeIsolated 桥回主执行器。
@MainActor
final class FSWatcher {
    nonisolated(unsafe) private var sources: [DispatchSourceFileSystemObject] = []
    nonisolated(unsafe) private var reloadPending = false
    var onChange: (() -> Void)?

    func watch(paths: [String]) {
        stop()
        for path in paths {
            let fd = open(path, O_EVTONLY)
            guard fd >= 0 else { continue }
            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fd,
                eventMask: .write,
                queue: .main
            )
            source.setEventHandler { [weak self, weak source] in
                guard let source, !source.data.isEmpty else { return }
                MainActor.assumeIsolated {
                    self?.handleEvent()
                }
            }
            source.setCancelHandler { close(fd) }
            sources.append(source)
            source.resume()
        }
    }

    nonisolated func stop() {
        for source in sources { source.cancel() }
        sources.removeAll()
        reloadPending = false
    }

    deinit { stop() }

    private func handleEvent() {
        guard !reloadPending else { return }
        reloadPending = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            MainActor.assumeIsolated {
                self?.reloadPending = false
                self?.onChange?()
            }
        }
    }
}
