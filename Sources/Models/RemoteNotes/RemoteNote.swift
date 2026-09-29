import Foundation

struct RemoteNote: Equatable, Identifiable, Sendable {
    let id: Int
    let title: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    /// The version the server holds; an update carries it and is refused once it moved on.
    let etag: String
}
