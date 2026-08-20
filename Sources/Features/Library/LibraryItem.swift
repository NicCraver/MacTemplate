import Foundation

struct LibraryItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String

    static let placeholders: [LibraryItem] = [
        LibraryItem(
            id: "brief",
            title: "项目 Brief",
            subtitle: "把产品目标写成一页",
            icon: AppIconName.document
        ),
        LibraryItem(
            id: "tokens",
            title: "设计令牌",
            subtitle: "色板 · 字号 · 间距",
            icon: AppIconName.tokens
        ),
        LibraryItem(
            id: "release",
            title: "发布清单",
            subtitle: "打包前核对",
            icon: AppIconName.checklist
        ),
        LibraryItem(
            id: "notes",
            title: "会议记录",
            subtitle: "上周同步",
            icon: AppIconName.note
        ),
    ]

    nonisolated static func filtered(_ items: [LibraryItem], query: String) -> [LibraryItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return items }
        return items.filter {
            $0.title.localizedCaseInsensitiveContains(q)
                || $0.subtitle.localizedCaseInsensitiveContains(q)
        }
    }
}
