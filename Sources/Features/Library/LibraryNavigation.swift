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
}
