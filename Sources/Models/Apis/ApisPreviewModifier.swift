#if DEBUG
import SwiftUI

struct ApisPreviewModifier: PreviewModifier {
    static func makeSharedContext() async throws -> ApisModel {
        let model = ApisModel(locationClient: StubLocationClient(), biometricClient: StubBiometricClient())
        model.load()
        return model
    }

    func body(content: Content, context: ApisModel) -> some View {
        content.environment(context)
    }
}
#endif
