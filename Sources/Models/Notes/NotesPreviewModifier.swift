#if DEBUG
import SwiftUI

struct NotesPreviewModifier: PreviewModifier {
    static func makeSharedContext() async throws -> NotesModel {
        let model = NotesModel(repository: StubNotesRepository())
        await model.search("")
        return model
    }

    func body(content: Content, context: NotesModel) -> some View {
        content.environment(context)
    }
}
#endif
