import OSLog
import UIKit
import UserNotifications

/// Registers for remote notifications and forwards what arrives to `pushClient`; every SDK that
/// needs an app delegate hook lands here, in this one file.
@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate {
    private(set) lazy var pushClient = LivePushClient {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushClient.tokenReceived(deviceToken.map { String(format: "%02x", $0) }.joined())
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        Self.logger.error("remote notifications unavailable: \(String(describing: error), privacy: .public)")
    }

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TemplateIOS", category: "push")
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let message = PushMessage(title: notification.request.content.title, body: notification.request.content.body)
        await pushClient.received(message)
        return [.banner, .sound]
    }

    nonisolated func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let content = response.notification.request.content
        let message = PushMessage(title: content.title, body: content.body)
        await pushClient.received(message)
    }
}
