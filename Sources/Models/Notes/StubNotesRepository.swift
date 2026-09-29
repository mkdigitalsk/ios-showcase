#if DEBUG
import Foundation

actor StubNotesRepository: NotesRepository {
    struct Failed: Error {}

    private(set) var notes: [Note]
    private let fails: Bool

    init(notes: [Note] = .stub, fails: Bool = false) {
        self.notes = notes
        self.fails = fails
    }

    func notes(matching query: String, sortedBy sort: NoteSort) async throws -> [Note] {
        guard !fails else { throw Failed() }
        return notes.matching(query, sortedBy: sort)
    }

    func insert(_ note: Note) async throws {
        guard !fails else { throw Failed() }
        notes.append(note)
    }

    func delete(id: UUID) async throws {
        guard !fails else { throw Failed() }
        notes.removeAll { $0.id == id }
    }

    func deleteAll() async throws {
        guard !fails else { throw Failed() }
        notes.removeAll()
    }
}

extension [Note] {
    static let stub: [Note] = [
        Note(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, title: "Groceries", content: "Milk, bread, apples", createdAt: .stubNow.addingTimeInterval(-3600)),
        Note(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, title: "Ideas", content: "A calendar that syncs with the server", createdAt: .stubNow),
    ]
}
#endif
