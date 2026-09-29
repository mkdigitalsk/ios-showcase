#if DEBUG
import SwiftUI

struct NotificationsPreviewModifier: PreviewModifier {
    static func makeSharedContext() async throws -> NotificationsModel {
        let model = NotificationsModel(
            localClient: StubLocalNotificationClient(permission: .granted),
            pushClient: StubPushClient(lastReceived: PushMessage(title: "Welcome", body: "Pushes reach this screen")),
        )
        await model.load()
        return model
    }

    func body(content: Content, context: NotificationsModel) -> some View {
        content.environment(context)
    }
}
#endif
