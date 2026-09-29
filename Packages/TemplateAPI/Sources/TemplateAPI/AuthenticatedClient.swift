import Foundation
import HTTPClient
import HTTPTypes
import SafeDecoding

/// The calls a session makes; the token rides every request as a bearer header.
public struct AuthenticatedClient: Sendable {
    private let api: JSONAPI

    public init(baseURL: URL, token: String) {
        self.init(baseURL: baseURL, token: token, transport: URLSession.shared)
    }

    package init(baseURL: URL, token: String, transport: any HTTPTransport) {
        api = JSONAPI(
            baseURL: baseURL,
            transport: transport,
            middlewares: [
                BearerAuthMiddleware(token: token),
                LoggingMiddleware(subsystem: UnauthenticatedClient.loggingSubsystem),
            ],
        )
    }

    /// A note that fails to decode is dropped, never the whole list.
    public func notes() async throws -> [NoteResponse] {
        let notes: LossyArray<NoteResponse> = try await api.get("notes")
        return notes.wrappedValue
    }

    public func createNote(_ note: NoteRequest) async throws -> NoteResponse {
        try await api.post("notes", body: note)
    }

    /// Throws `APIError.preconditionFailed(current:)` when `etag` no longer matches the server's.
    public func updateNote(id: Int, etag: String, _ note: NoteRequest) async throws -> NoteResponse {
        try await api.put("notes/\(id)", headers: [.ifMatch: etag], body: note)
    }

    public func deleteNote(id: Int) async throws {
        try await api.delete("notes/\(id)")
    }

    public func me() async throws -> UserResponse {
        try await api.get("users/me")
    }

    public func deleteMe() async throws {
        try await api.delete("users/me")
    }
}
