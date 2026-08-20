import Foundation

nonisolated enum LibraryNavigation: Sendable {
    enum EscapeAction: Equatable, Sendable {
        case pop
        case clearSearch
        case none
    }

    static func escapeAction(query: String, pathCount: Int) -> EscapeAction {
        if pathCount > 0 { return .pop }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return .clearSearch }
        return .none
    }

    static func firstMatch(_ items: [LibraryItem], query: String) -> LibraryItem? {
        LibraryItem.filtered(items, query: query).first
    }

    static func canFocusSearch(pathCount: Int) -> Bool {
        pathCount == 0
    }
}
