protocol StorageRepository: Sendable {
    func loadPersistentCount() async throws -> Int
    func savePersistentCount(_ count: Int) async throws
}
