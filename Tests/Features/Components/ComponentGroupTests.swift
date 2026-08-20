import Testing
@testable import MacTemplate

struct ComponentGroupTests {
    @Test
    func catalogHasEightGroupsWithUniqueIcons() {
        let groups = ComponentGroup.allCases
        #expect(groups.map(\.id) == [
            "tokens", "buttons", "forms", "cards", "rows", "feedback", "text", "motion",
        ])
        #expect(groups.map(\.title) == [
            "令牌", "按钮", "表单", "卡片", "列表", "反馈", "文本", "动效",
        ])
        let icons = groups.map(\.icon)
        #expect(Set(icons).count == icons.count)
        #expect(ComponentGroup.tokens.icon == AppIconName.tokens)
        #expect(ComponentGroup.buttons.icon == "pointer-cursor-click")
        #expect(ComponentGroup.forms.icon == "toggle-on")
        #expect(ComponentGroup.cards.icon == "layer-two")
        #expect(ComponentGroup.rows.icon == AppIconName.checklist)
        #expect(ComponentGroup.feedback.icon == "message-default")
        #expect(ComponentGroup.text.icon == "text-cursor")
        #expect(ComponentGroup.motion.icon == "animation01")
    }

    @Test
    func visibleFilterReturnsOneOrAll() {
        #expect(ComponentGroup.visible(filter: nil) == Array(ComponentGroup.allCases))
        #expect(ComponentGroup.visible(filter: .buttons) == [.buttons])
    }
}
