protocol LocalNotificationClient: Sendable {
    func permission() async -> NotificationPermission
    func requestPermission() async -> NotificationPermission
    /// Posts a notification a second from now, so it lands while the app is still in front.
    func schedule(title: String, body: String, category: NotificationCategory) async throws
    func cancelAll() async
}
