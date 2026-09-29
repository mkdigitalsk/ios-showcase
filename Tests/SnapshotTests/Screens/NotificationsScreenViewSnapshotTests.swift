import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct NotificationsScreenViewSnapshotTests {
    @Test
    func granted() async {
        let model = NotificationsModel(
            localClient: StubLocalNotificationClient(permission: .granted),
            pushClient: StubPushClient(lastReceived: PushMessage(title: "Welcome", body: "Pushes reach this screen")),
        )
        await model.load()
        await model.send(title: "Reminder", body: "Check the calendar", category: .reminders)

        assertScreenSnapshots(of: screen(model))
    }

    @Test
    func undetermined() async {
        let model = NotificationsModel(localClient: StubLocalNotificationClient(), pushClient: StubPushClient(token: nil))
        await model.load()

        assertScreenSnapshots(of: screen(model), variants: [.light])
    }

    private func screen(_ model: NotificationsModel) -> some View {
        NavigationStack {
            NotificationsScreenView()
        }
        .environment(model)
    }
}
