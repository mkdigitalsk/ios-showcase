#if DEBUG
import SwiftUI

struct RemoteNotesPreviewModifier: PreviewModifier {
    static func makeSharedContext() async throws -> RemoteNotesModel {
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository())
        await model.load()
        return model
    }

    func body(content: Content, context: RemoteNotesModel) -> some View {
        content.environment(context)
    }
}
#endif
