import Foundation

protocol NotesRepository: Sendable {
    func notes(matching query: String, sortedBy sort: NoteSort) async throws -> [Note]
    func insert(_ note: Note) async throws
    func delete(id: UUID) async throws
    func deleteAll() async throws
}
