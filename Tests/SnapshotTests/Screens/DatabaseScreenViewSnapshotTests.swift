import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct DatabaseScreenViewSnapshotTests {
    @Test
    func loaded() async {
        let model = NotesModel(repository: StubNotesRepository())
        await model.search("")

        assertScreenSnapshots(of: screen(model))
    }

    @Test
    func empty() async {
        let model = NotesModel(repository: StubNotesRepository(notes: []))
        await model.search("")

        assertScreenSnapshots(of: screen(model), variants: [.light])
    }

    private func screen(_ model: NotesModel) -> some View {
        NavigationStack {
            DatabaseScreenView()
        }
        .environment(model)
    }
}
