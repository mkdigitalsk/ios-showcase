@testable import TemplateIOS
import Testing

@MainActor
struct NotificationsModelTests {
    @Test
    func `load reads the permission and the token comes from the push client`() async {
        let push = StubPushClient(token: "abc")
        let model = NotificationsModel(localClient: StubLocalNotificationClient(permission: .denied), pushClient: push)

        await model.load()

        #expect(model.permission == .denied)
        #expect(model.pushToken == "abc")
    }

    @Test
    func `requesting permission takes the platform's answer`() async {
        let model = NotificationsModel(localClient: StubLocalNotificationClient(answer: .granted), pushClient: StubPushClient())

        await model.requestPermission()

        #expect(model.permission == .granted)
    }

    @Test
    func `a sent notification is scheduled on its category and remembered`() async {
        let local = StubLocalNotificationClient()
        let model = NotificationsModel(localClient: local, pushClient: StubPushClient())

        await model.send(title: "Reminder", body: "Check the calendar", category: .reminders)

        #expect(model.lastSent == "Reminder")
        #expect(await local.scheduled == [StubLocalNotificationClient.Scheduled(title: "Reminder", body: "Check the calendar", category: .reminders)])

        await model.cancelAll()
        #expect(model.lastSent == nil)
        #expect(await local.cancelled)
    }

    @Test
    func `a refresh asks the push client and a received message reaches the model`() async {
        let push = StubPushClient()
        let model = NotificationsModel(localClient: StubLocalNotificationClient(), pushClient: push)

        await model.refreshToken()
        #expect(model.pushToken == "stub-push-token-refreshed-1")

        push.receive(PushMessage(title: "Hi", body: "there"))
        #expect(model.lastReceived == PushMessage(title: "Hi", body: "there"))
    }
}
