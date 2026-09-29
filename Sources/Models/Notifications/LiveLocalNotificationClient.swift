import Foundation
import UserNotifications

struct LiveLocalNotificationClient: LocalNotificationClient {
    private static let delay: TimeInterval = 1

    func permission() async -> NotificationPermission {
        await NotificationPermission(UNUserNotificationCenter.current().notificationSettings().authorizationStatus)
    }

    func requestPermission() async -> NotificationPermission {
        let granted = await (try? UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        return granted ? .granted : await permission()
    }

    func schedule(title: String, body: String, category: NotificationCategory) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category.rawValue
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: Self.delay, repeats: false),
        )
        try await UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}

private extension NotificationPermission {
    init(_ status: UNAuthorizationStatus) {
        self = switch status {
        case .authorized, .provisional, .ephemeral: .granted
        case .denied: .denied
        case .notDetermined: .notDetermined
        @unknown default: .notDetermined
        }
    }
}
