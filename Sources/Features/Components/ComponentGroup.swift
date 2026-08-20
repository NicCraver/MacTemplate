import Foundation

enum ComponentGroup: String, CaseIterable, Identifiable, Hashable {
    case tokens
    case buttons
    case forms
    case cards
    case rows
    case feedback
    case text
    case motion

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tokens: return "令牌"
        case .buttons: return "按钮"
        case .forms: return "表单"
        case .cards: return "卡片"
        case .rows: return "列表"
        case .feedback: return "反馈"
        case .text: return "文本"
        case .motion: return "动效"
        }
    }

    var icon: String {
        switch self {
        case .tokens: return AppIconName.tokens
        case .buttons: return "pointer-cursor-click"
        case .forms: return "toggle-on"
        case .cards: return "layer-two"
        case .rows: return AppIconName.checklist
        case .feedback: return "message-default"
        case .text: return "text-cursor"
        case .motion: return "animation01"
        }
    }

    nonisolated static func visible(filter: ComponentGroup?) -> [ComponentGroup] {
        guard let filter else { return Array(allCases) }
        return [filter]
    }
}
