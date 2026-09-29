@testable import TemplateIOS
import Testing

@MainActor
struct StorageModelTests {
    @Test
    func `load reads the persistent count`() async throws {
        let model = StorageModel(repository: StubStorageRepository(persistentCount: 3))

        try await model.load()

        #expect(model.persistentCount == 3)
        #expect(model.sessionCount == 0)
    }

    @Test
    func `increment persistent saves before it shows`() async throws {
        let repository = StubStorageRepository(persistentCount: 3)
        let model = StorageModel(repository: repository)
        try await model.load()

        try await model.incrementPersistent()

        #expect(model.persistentCount == 4)
        #expect(await repository.persistentCount == 4)
    }

    @Test
    func `a failed save leaves the count as it was`() async throws {
        let model = StorageModel(repository: StubStorageRepository(persistentCount: 3, savesFail: true))
        try await model.load()

        await #expect(throws: StubStorageRepository.SaveFailed.self) {
            try await model.incrementPersistent()
        }

        #expect(model.persistentCount == 3)
    }

    @Test
    func `reset clears both counts`() async throws {
        let model = StorageModel(repository: StubStorageRepository(persistentCount: 3))
        try await model.load()
        model.incrementSession()

        try await model.reset()

        #expect(model.sessionCount == 0)
        #expect(model.persistentCount == 0)
    }
}
