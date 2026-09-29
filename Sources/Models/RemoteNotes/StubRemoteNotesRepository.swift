#if DEBUG
import Foundation

actor StubRemoteNotesRepository: RemoteNotesRepository {
    private(set) var notes: [RemoteNote]
    private let failure: RemoteNotesError?
    /// When set, the next update is refused with this as the server's version, once.
    private var conflict: RemoteNote?
    private var nextID: Int

    init(notes: [RemoteNote] = .stub, failure: RemoteNotesError? = nil, conflict: RemoteNote? = nil) {
        self.notes = notes
        self.failure = failure
        self.conflict = conflict
        nextID = (notes.map(\.id).max() ?? 0) + 1
    }

    func notes() async throws -> [RemoteNote] {
        try failIfAsked()
        return notes
    }

    func create(title: String, content: String) async throws -> RemoteNote {
        try failIfAsked()
        let note = RemoteNote(id: nextID, title: title, content: content, createdAt: .stubNow, updatedAt: .stubNow, etag: "\"0\"")
        nextID += 1
        notes.insert(note, at: 0)
        return note
    }

    func update(id: Int, etag: String, title: String, content: String) async throws -> RemoteNote {
        try failIfAsked()
        if let conflict {
            self.conflict = nil
            throw RemoteNoteConflict(current: conflict)
        }
        guard let index = notes.firstIndex(where: { $0.id == id }) else { throw RemoteNotesError.unavailable }
        guard notes[index].etag == etag else { throw RemoteNoteConflict(current: notes[index]) }
        let version = (Int(etag.trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? 0) + 1
        let updated = RemoteNote(
            id: id,
            title: title,
            content: content,
            createdAt: notes[index].createdAt,
            updatedAt: .stubNow,
            etag: "\"\(version)\"",
        )
        notes[index] = updated
        return updated
    }

    func delete(id: Int) async throws {
        try failIfAsked()
        notes.removeAll { $0.id == id }
    }

    private func failIfAsked() throws {
        if let failure {
            throw failure
        }
    }
}

extension [RemoteNote] {
    static let stub: [RemoteNote] = [
        RemoteNote(id: 2, title: "Buy milk", content: "Two litres, semi-skimmed", createdAt: .stubNow, updatedAt: .stubNow, etag: "\"0\""),
        RemoteNote(id: 1, title: "Call the studio", content: "About the Thursday demo", createdAt: .stubNow, updatedAt: .stubNow, etag: "\"3\""),
    ]
}

extension Date {
    /// A fixed instant, so a preview and a snapshot render the same date.
    static let stubNow = Date(timeIntervalSince1970: 1_789_500_000)
}
#endif
