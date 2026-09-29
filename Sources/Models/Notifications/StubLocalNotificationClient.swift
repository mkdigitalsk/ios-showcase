#if DEBUG
actor StubLocalNotificationClient: LocalNotificationClient {
    struct Scheduled: Equatable {
        let title: String
        let body: String
        let category: NotificationCategory
    }

    private var granted: NotificationPermission
    private let answer: NotificationPermission
    private(set) var scheduled: [Scheduled] = []
    private(set) var cancelled = false

    init(permission: NotificationPermission = .notDetermined, answer: NotificationPermission = .granted) {
        granted = permission
        self.answer = answer
    }

    func permission() async -> NotificationPermission {
        granted
    }

    func requestPermission() async -> NotificationPermission {
        granted = answer
        return granted
    }

    func schedule(title: String, body: String, category: NotificationCategory) async throws {
        scheduled.append(Scheduled(title: title, body: body, category: category))
    }

    func cancelAll() async {
        scheduled.removeAll()
        cancelled = true
    }
}
#endif
