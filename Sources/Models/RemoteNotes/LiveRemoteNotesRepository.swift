import TemplateAPI

struct LiveRemoteNotesRepository: RemoteNotesRepository {
    private let client: AuthenticatedClient

    init(client: AuthenticatedClient) {
        self.client = client
    }

    func notes() async throws -> [RemoteNote] {
        try await mapped { try await client.notes().map(RemoteNote.init) }
    }

    func create(title: String, content: String) async throws -> RemoteNote {
        try await mapped { try await RemoteNote(client.createNote(NoteRequest(title: title, content: content))) }
    }

    func update(id: Int, etag: String, title: String, content: String) async throws -> RemoteNote {
        try await mapped { try await RemoteNote(client.updateNote(id: id, etag: etag, NoteRequest(title: title, content: content))) }
    }

    func delete(id: Int) async throws {
        try await mapped { try await client.deleteNote(id: id) }
    }

    private func mapped<Value>(_ call: () async throws -> Value) async throws -> Value {
        do {
            return try await call()
        } catch let APIError.preconditionFailed(current) {
            throw RemoteNoteConflict(current: RemoteNote(current))
        } catch let error as APIError {
            throw RemoteNotesError(error)
        }
    }
}

private extension RemoteNote {
    init(_ response: NoteResponse) {
        self.init(
            id: response.id,
            title: response.title,
            content: response.content,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt,
            etag: response.etag,
        )
    }
}

private extension RemoteNotesError {
    init(_ error: APIError) {
        self = switch error {
        case .unauthorized: .unauthorized
        case .offline: .offline
        default: .unavailable
        }
    }
}
