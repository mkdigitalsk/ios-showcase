import Observation

/// The signed-in account as the server sees it; deleting it is the one thing it can do.
@MainActor
@Observable
final class AccountModel {
    private(set) var user: User?
    private(set) var isDeleting = false
    private(set) var deleteFailed = false
    private let repository: any UserRepository

    init(repository: any UserRepository) {
        self.repository = repository
    }

    func load() async {
        guard let loaded = try? await repository.me(), !Task.isCancelled else { return }
        user = loaded
    }

    /// The account goes first and the answer decides; only a server that agreed makes this `true`.
    func deleteAccount() async -> Bool {
        isDeleting = true
        deleteFailed = false
        defer { isDeleting = false }
        do {
            try await repository.deleteAccount()
            return !Task.isCancelled
        } catch where error.isCancellation {
            return false
        } catch {
            guard !Task.isCancelled else { return false }
            deleteFailed = true
            return false
        }
    }
}
