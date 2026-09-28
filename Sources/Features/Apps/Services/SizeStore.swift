import Foundation

/// 按需计算并记忆应用体积（不在扫描路径上），列表先出、体积后填。
nonisolated enum SizeStore {
    nonisolated(unsafe) private static let memory = NSCache<NSString, NSNumber>()

    static func size(resolvedPath: String, modified: Date) -> Int64 {
        let key = stableHash(resolvedPath + "|\(Int(modified.timeIntervalSince1970))")
        if let cached = memory.object(forKey: key as NSString) { return cached.int64Value }
        let value = directorySize(URL(fileURLWithPath: resolvedPath))
        memory.setObject(NSNumber(value: value), forKey: key as NSString)
        return value
    }

    static func directorySize(_ directory: URL) -> Int64 {
        let fm = FileManager.default
        var total: Int64 = 0
        guard let en = fm.enumerator(at: directory,
                                     includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileSizeKey]) else { return 0 }
        for case let fileURL as URL in en {
            if let v = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileSizeKey]) {
                total += Int64(v.totalFileAllocatedSize ?? v.fileSize ?? 0)
            }
        }
        return total
    }

    /// FNV-1a：跨启动稳定（String.hashValue 不是）。
    static func stableHash(_ string: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return String(hash, radix: 16)
    }
}
