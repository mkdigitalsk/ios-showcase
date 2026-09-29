#if DEBUG
import SwiftUI

struct AccountPreviewModifier: PreviewModifier {
    static func makeSharedContext() async throws -> AccountModel {
        let model = AccountModel(repository: StubUserRepository())
        await model.load()
        return model
    }

    func body(content: Content, context: AccountModel) -> some View {
        content.environment(context)
    }
}
#endif
