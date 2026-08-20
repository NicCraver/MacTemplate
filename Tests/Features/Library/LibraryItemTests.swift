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
}
