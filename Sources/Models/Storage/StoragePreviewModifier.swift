#if DEBUG
import SwiftUI

struct StoragePreviewModifier: PreviewModifier {
    static func makeSharedContext() async throws -> StorageModel {
        let model = StorageModel(repository: StubStorageRepository())
        try await model.load()
        return model
    }

    func body(content: Content, context: StorageModel) -> some View {
        content.environment(context)
    }
}
#endif
