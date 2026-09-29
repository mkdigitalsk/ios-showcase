import Observation

@MainActor
@Observable
final class StorageModel {
    private(set) var sessionCount = 0
    private(set) var persistentCount = 0
    private let repository: any StorageRepository

    init(repository: any StorageRepository) {
        self.repository = repository
    }

    func load() async throws {
        persistentCount = try await repository.loadPersistentCount()
    }

    func incrementSession() {
        sessionCount += 1
    }

    func incrementPersistent() async throws {
        let next = persistentCount + 1
        try await repository.savePersistentCount(next)
        persistentCount = next
    }

    func reset() async throws {
        try await repository.savePersistentCount(0)
        persistentCount = 0
        sessionCount = 0
    }
}
