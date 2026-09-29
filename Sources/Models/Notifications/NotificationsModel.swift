import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class NotificationsModel {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TemplateIOS", category: "push")

    private(set) var permission = NotificationPermission.notDetermined
    private(set) var isRefreshingToken = false
    private(set) var lastSent: String?
    private(set) var sendFailed = false
    private let localClient: any LocalNotificationClient
    private let pushClient: any PushClient

    init(localClient: any LocalNotificationClient, pushClient: any PushClient) {
        self.localClient = localClient
        self.pushClient = pushClient
    }

    var pushToken: String? {
        pushClient.token
    }

    var lastReceived: PushMessage? {
        pushClient.lastReceived
    }

    func load() async {
        let current = await localClient.permission()
        guard !Task.isCancelled else { return }
        permission = current
    }

    func requestPermission() async {
        let answer = await localClient.requestPermission()
        guard !Task.isCancelled else { return }
        permission = answer
    }

    func refreshToken() async {
        isRefreshingToken = true
        defer { isRefreshingToken = false }
        await pushClient.refreshToken()
    }

    func logToken() {
        let token = pushClient.token ?? "none"
        Self.logger.notice("push token: \(token, privacy: .public)")
    }

    func send(title: String, body: String, category: NotificationCategory) async {
        do {
            try await localClient.schedule(title: title, body: body, category: category)
            guard !Task.isCancelled else { return }
            lastSent = title
            sendFailed = false
        } catch where error.isCancellation {
            return
        } catch {
            guard !Task.isCancelled else { return }
            sendFailed = true
        }
    }

    func cancelAll() async {
        await localClient.cancelAll()
        guard !Task.isCancelled else { return }
        lastSent = nil
    }
}
