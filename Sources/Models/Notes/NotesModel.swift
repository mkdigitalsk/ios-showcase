import Foundation
import Observation

/// The notes on this device, as the current search and sort show them.
@MainActor
@Observable
final class NotesModel {
    private(set) var notes: [Note] = []
    private(set) var query = ""
    private(set) var sort = NoteSort.dateDescending
    private(set) var isLoading = true
    private(set) var loadFailed = false
    private let repository: any NotesRepository

    init(repository: any NotesRepository) {
        self.repository = repository
    }

    func search(_ query: String) async {
        self.query = query
        await reload()
    }

    func sort(by sort: NoteSort) async {
        self.sort = sort
        await reload()
    }

    func insert(title: String, content: String) async {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        await perform {
            try await repository.insert(Note(id: UUID(), title: trimmedTitle, content: content.trimmingCharacters(in: .whitespacesAndNewlines), createdAt: Date()))
        }
    }

    func delete(id: UUID) async {
        await perform {
            try await repository.delete(id: id)
        }
    }

    func deleteAll() async {
        await perform {
            try await repository.deleteAll()
        }
    }

    private func perform(_ change: () async throws -> Void) async {
        do {
            try await change()
            await reload()
        } catch where error.isCancellation {
            return
        } catch {
            guard !Task.isCancelled else { return }
            loadFailed = true
        }
    }

    private func reload() async {
        do {
            let loaded = try await repository.notes(matching: query, sortedBy: sort)
            guard !Task.isCancelled else { return }
            notes = loaded
            loadFailed = false
        } catch where error.isCancellation {
            return
        } catch {
            guard !Task.isCancelled else { return }
            loadFailed = true
        }
        isLoading = false
    }
}
