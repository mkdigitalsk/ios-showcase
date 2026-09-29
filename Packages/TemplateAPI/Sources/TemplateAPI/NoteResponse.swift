import Foundation

public struct NoteResponse: Decodable, Equatable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let content: String
    public let createdAt: Date
    public let updatedAt: Date
    /// Sent back as `If-Match` on an update; the server answers 412 with the current note when it moved on.
    public let etag: String

    public init(id: Int, title: String, content: String, createdAt: Date, updatedAt: Date, etag: String) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.etag = etag
    }
}

public struct NoteRequest: Encodable, Equatable, Sendable {
    public let title: String
    public let content: String

    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}
