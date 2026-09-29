import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct NetworkingScreenViewSnapshotTests {
    @Test
    func loaded() async {
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository())
        await model.load()

        assertScreenSnapshots(of: screen(model))
    }

    @Test
    func empty() async {
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository(notes: []))
        await model.load()

        assertScreenSnapshots(of: screen(model), variants: [.light])
    }

    @Test
    func editing() async {
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository())
        await model.load()
        model.startEditing(model.notes[0])

        assertScreenSnapshots(of: screen(model), variants: [.light])
    }

    @Test
    func failed() async {
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository(failure: .offline))
        await model.load()

        assertScreenSnapshots(of: screen(model), variants: [.light])
    }

    private func screen(_ model: RemoteNotesModel) -> some View {
        NavigationStack {
            NetworkingScreenView()
        }
        .environment(model)
    }
}
