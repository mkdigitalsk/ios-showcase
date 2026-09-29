#if DEBUG
import SwiftUI

struct SettingsPreviewModifier: PreviewModifier {
    static func makeSharedContext() async throws -> SettingsModel {
        let model = SettingsModel(repository: StubSettingsRepository(), crashReporter: StubCrashReporter())
        await model.load()
        return model
    }

    func body(content: Content, context: SettingsModel) -> some View {
        content.environment(context)
    }
}
#endif
