import Foundation
@testable import TemplateIOS
import Testing

/// The real SwiftData store, in memory — the predicate and the sort are what production runs.
struct LiveNotesRepositoryTests {
    private func makeRepository() throws -> LiveNotesRepository {
        try LiveNotesRepository(modelContainer: LiveNotesRepository.makeContainer(inMemory: true))
    }

    private let older = Note(id: UUID(), title: "Buy milk", content: "two litres", createdAt: Date(timeIntervalSince1970: 1000))
    private let newer = Note(id: UUID(), title: "apples", content: "for the pie", createdAt: Date(timeIntervalSince1970: 2000))

    @Test
    func `an empty query lists everything, newest first`() async throws {
        let repository = try makeRepository()
        try await repository.insert(older)
        try await repository.insert(newer)

        let notes = try await repository.notes(matching: "", sortedBy: .dateDescending)

        #expect(notes == [newer, older])
    }

    @Test
    func `a query matches the title or the content, ignoring case`() async throws {
        let repository = try makeRepository()
        try await repository.insert(older)
        try await repository.insert(newer)

        #expect(try await repository.notes(matching: "MILK", sortedBy: .dateDescending) == [older])
        #expect(try await repository.notes(matching: "pie", sortedBy: .dateDescending) == [newer])
        #expect(try await repository.notes(matching: "nothing", sortedBy: .dateDescending).isEmpty)
    }

    @Test
    func `title sorts ignore case`() async throws {
        let repository = try makeRepository()
        try await repository.insert(older)
        try await repository.insert(newer)

        #expect(try await repository.notes(matching: "", sortedBy: .titleAscending).map(\.title) == ["apples", "Buy milk"])
        #expect(try await repository.notes(matching: "", sortedBy: .titleDescending).map(\.title) == ["Buy milk", "apples"])
    }

    @Test
    func `delete removes one note and delete all removes the rest`() async throws {
        let repository = try makeRepository()
        try await repository.insert(older)
        try await repository.insert(newer)

        try await repository.delete(id: older.id)
        #expect(try await repository.notes(matching: "", sortedBy: .dateDescending) == [newer])

        try await repository.deleteAll()
        #expect(try await repository.notes(matching: "", sortedBy: .dateDescending).isEmpty)
    }
}
