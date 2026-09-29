import Foundation

struct LiveStorageRepository: StorageRepository {
    private static let key = "storage.persistentCount"
    /// UserDefaults is documented thread-safe and only its type lacks the annotation.
    private nonisolated(unsafe) let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func loadPersistentCount() async throws -> Int {
        defaults.integer(forKey: Self.key)
    }

    func savePersistentCount(_ count: Int) async throws {
        defaults.set(count, forKey: Self.key)
    }
}
