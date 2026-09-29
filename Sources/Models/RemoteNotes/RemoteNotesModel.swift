import Observation

/// The notes on the server. An edit is one note at a time; a save the server refuses becomes a
/// conflict the screen resolves — keep the draft with the server's tag, or take the server's note.
@MainActor
@Observable
final class RemoteNotesModel {
    struct Draft: Equatable {
        let title: String
        let content: String
    }

    private(set) var notes: [RemoteNote] = []
    private(set) var isLoading = false
    private(set) var isSaving = false
    private(set) var editing: RemoteNote?
    private(set) var conflict: RemoteNote?
    private(set) var error: RemoteNotesError?
    private var draft: Draft?
    private let repository: any RemoteNotesRepository

    init(repository: any RemoteNotesRepository) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        await perform {
            notes = try await repository.notes()
        }
    }

    func create(title: String, content: String) async {
        await saving {
            _ = try await repository.create(title: title, content: content)
            notes = try await repository.notes()
        }
    }

    func startEditing(_ note: RemoteNote) {
        editing = note
        conflict = nil
    }

    func cancelEditing() {
        editing = nil
        conflict = nil
        draft = nil
    }

    /// Saves the edit against the tag the edit started from.
    func save(title: String, content: String) async {
        guard let editing else { return }
        draft = Draft(title: title, content: content)
        await update(editing, with: Draft(title: title, content: content))
    }

    /// Keeps the draft the conflict interrupted, sent against the tag the server just returned.
    func keepMine() async {
        guard let conflict, let draft else { return }
        self.conflict = nil
        await update(conflict, with: draft)
    }

    /// Takes the server's version and drops the draft.
    func discardMine() {
        guard let conflict else { return }
        notes = notes.map { $0.id == conflict.id ? conflict : $0 }
        cancelEditing()
    }

    func delete(id: Int) async {
        await perform {
            try await repository.delete(id: id)
            notes = try await repository.notes()
        }
    }

    private func update(_ note: RemoteNote, with draft: Draft) async {
        await saving {
            do {
                _ = try await repository.update(id: note.id, etag: note.etag, title: draft.title, content: draft.content)
                editing = nil
                self.draft = nil
                notes = try await repository.notes()
            } catch let refused as RemoteNoteConflict {
                conflict = refused.current
            }
        }
    }

    private func saving(_ change: () async throws -> Void) async {
        isSaving = true
        defer { isSaving = false }
        await perform(change)
    }

    private func perform(_ change: () async throws -> Void) async {
        error = nil
        do {
            try await change()
        } catch let failure as RemoteNotesError {
            guard !Task.isCancelled else { return }
            error = failure
        } catch where error.isCancellation {
            return
        } catch {
            guard !Task.isCancelled else { return }
            self.error = .unavailable
        }
    }
}
