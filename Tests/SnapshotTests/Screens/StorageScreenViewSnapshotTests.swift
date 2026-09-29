import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct StorageScreenViewSnapshotTests {
    @Test
    func loaded() async throws {
        let model = StorageModel(repository: StubStorageRepository(persistentCount: 7))
        try await model.load()

        assertScreenSnapshots(
            of: NavigationStack {
                StorageScreenView()
            }
            .environment(model),
        )
    }
}
