import AppKit
import Foundation

/// 应用图标缓存：内存（本次会话）+ 磁盘 PNG（跨启动），键包含 bundleID、
/// 版本与修改日期，应用更新后自动换新。
nonisolated enum IconCache {
    static let iconSize: CGFloat = 128
    private static let pixelSize = 256
    nonisolated(unsafe) private static let memory = NSCache<NSString, NSImage>()
    private static let diskQueue = DispatchQueue(label: "com.nic.applist.iconcache", qos: .utility)
    nonisolated(unsafe) private static let knownOnDisk = NSMutableSet()

    static func icon(for appURL: URL, bundleID: String?, version: String?, modified: Date) -> NSImage {
        memory.countLimit = 4096
        let key = cacheKey(for: appURL, bundleID: bundleID, version: version, modified: modified)

        if let cached = memory.object(forKey: key as NSString) { return cached }

        if let dir = Self.directory {
            let fileURL = dir.appendingPathComponent(key + ".png")
            if let loaded = NSImage(contentsOf: fileURL) {
                loaded.size = NSSize(width: iconSize, height: iconSize)
                memory.setObject(loaded, forKey: key as NSString)
                diskQueue.sync { knownOnDisk.add(key) }
                return loaded
            }
        }

        let fresh = NSWorkspace.shared.icon(forFile: appURL.path)
        fresh.size = NSSize(width: iconSize, height: iconSize)
        memory.setObject(fresh, forKey: key as NSString)
        writeToDisk(key: key, image: fresh)
        return fresh
    }

    /// 清理 60 天未命中的缓存文件；幂等，多次调用无副作用。
    static func pruneStaleFiles(olderThanDays: Int = 60) {
        diskQueue.async {
            guard let dir = Self.directory else { return }
            let cutoff = Date().addingTimeInterval(-Double(olderThanDays) * 86400)
            let files = (try? FileManager.default.contentsOfDirectory(
                at: dir, includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
            for file in files where file.pathExtension.lowercased() == "png" {
                let modified = (try? file.resourceValues(forKeys: [.contentModificationDateKey]))?
                    .contentModificationDate ?? .distantPast
                if modified < cutoff {
                    try? FileManager.default.removeItem(at: file)
                }
            }
        }
    }

    private static var directory: URL? {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let dir = caches?.appendingPathComponent("com.nic.applist/icons", isDirectory: true)
        if let dir, !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private static func cacheKey(for appURL: URL, bundleID: String?, version: String?, modified: Date) -> String {
        let path = appURL.resolvingSymlinksInPath().path
        let ident = bundleID ?? appURL.deletingPathExtension().lastPathComponent
        return "\(ident)-\(version ?? "-")-\(Int(modified.timeIntervalSince1970))-\(SizeStore.stableHash(path))"
    }

    private static func writeToDisk(key: String, image: NSImage) {
        diskQueue.async {
            guard let dir = Self.directory else { return }
            if knownOnDisk.contains(key) { return }
            let fileURL = dir.appendingPathComponent(key + ".png")
            guard !FileManager.default.fileExists(atPath: fileURL.path) else {
                knownOnDisk.add(key)
                return
            }
            guard let data = pngData(from: image) else { return }
            try? data.write(to: fileURL, options: .atomic)
            knownOnDisk.add(key)
        }
    }

    private static func pngData(from image: NSImage) -> Data? {
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                         pixelsWide: pixelSize, pixelsHigh: pixelSize,
                                         bitsPerSample: 8, samplesPerPixel: 4,
                                         hasAlpha: true, isPlanar: false,
                                         colorSpaceName: .calibratedRGB,
                                         bytesPerRow: 0, bitsPerPixel: 0) else { return nil }
        rep.size = NSSize(width: iconSize, height: iconSize)
        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: rep)
        NSGraphicsContext.current = context
        context?.imageInterpolation = .high
        image.draw(in: NSRect(x: 0, y: 0, width: iconSize, height: iconSize),
                   from: .zero, operation: .sourceOver, fraction: 1)
        NSGraphicsContext.restoreGraphicsState()
        return rep.representation(using: .png, properties: [:])
    }
}
