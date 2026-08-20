import Foundation
import Testing
@testable import MacTemplate

struct LibraryItemTests {
    @Test
    func emptyQueryReturnsAll() {
        let result = LibraryItem.filtered(LibraryItem.placeholders, query: "  ")
        #expect(result == LibraryItem.placeholders)
    }

    @Test
    func titleMatchIsCaseInsensitive() {
        let result = LibraryItem.filtered(LibraryItem.placeholders, query: "BRIEF")
        #expect(result.map(\.id) == ["brief"])
    }

    @Test
    func subtitleMatch() {
        let result = LibraryItem.filtered(LibraryItem.placeholders, query: "色板")
        #expect(result.map(\.id) == ["tokens"])
    }

    @Test
    func noMatch() {
        let result = LibraryItem.filtered(LibraryItem.placeholders, query: "xyz-not-found")
        #expect(result.isEmpty)
    }

    @Test
    func placeholdersHaveDistinctCatalogIcons() {
        let items = LibraryItem.placeholders
        let icons = items.map(\.icon)
        #expect(Set(icons).count == icons.count)
        #expect(items.map(\.id) == ["brief", "tokens", "release", "notes"])
        #expect(items[0].icon == AppIconName.document)
        #expect(items[1].icon == AppIconName.tokens)
        #expect(items[2].icon == AppIconName.checklist)
        #expect(items[3].icon == AppIconName.note)
    }
}
