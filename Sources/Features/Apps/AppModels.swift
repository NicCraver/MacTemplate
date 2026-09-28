import AppKit
import Foundation

/// 一个应用的快照。`sizeBytes == -1` 表示体积尚未计算（扫描后异步填充）。
struct AppEntry: Identifiable, Hashable, @unchecked Sendable {
    let url: URL
    let name: String
    let version: String?
    let bundleID: String?
    var sizeBytes: Int64 = -1
    let modified: Date
    let icon: NSImage

    var id: String { identityKey }

    /// 稳定身份：优先 bundleID，其次解析路径哈希。
    var identityKey: String {
        if let bundleID { return "b:" + bundleID }
        return "p:" + SizeStore.stableHash(url.resolvingSymlinksInPath().path)
    }

    var displayName: String { url.deletingPathExtension().lastPathComponent }

    var displaySize: String {
        sizeBytes < 0 ? "…" : ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file)
    }

    var displayDate: String {
        DateFormatter.localizedString(from: modified, dateStyle: .short, timeStyle: .short)
    }
}
