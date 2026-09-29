#if DEBUG
actor StubStorageRepository: StorageRepository {
    struct SaveFailed: Error {}

    private(set) var persistentCount: Int
    private let savesFail: Bool

    init(persistentCount: Int = 3, savesFail: Bool = false) {
        self.persistentCount = persistentCount
        self.savesFail = savesFail
    }

    func loadPersistentCount() async throws -> Int {
        persistentCount
    }

    func savePersistentCount(_ count: Int) async throws {
        guard !savesFail else { throw SaveFailed() }
        persistentCount = count
    }
}
#endif
