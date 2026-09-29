protocol RemoteNotesRepository: Sendable {
    func notes() async throws -> [RemoteNote]
    func create(title: String, content: String) async throws -> RemoteNote
    /// Throws `RemoteNoteConflict` when `etag` is no longer the server's.
    func update(id: Int, etag: String, title: String, content: String) async throws -> RemoteNote
    func delete(id: Int) async throws
}

/// The server refused an update because the note changed elsewhere — `current` is its version now.
struct RemoteNoteConflict: Error, Equatable {
    let current: RemoteNote
}

enum RemoteNotesError: Error, Equatable {
    case offline
    case unauthorized
    case unavailable
}
