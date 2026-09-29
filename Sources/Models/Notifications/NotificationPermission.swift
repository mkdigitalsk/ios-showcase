enum NotificationPermission: Equatable, Sendable {
    case notDetermined
    case granted
    case denied
}

/// The two channels the demo posts to; a client project names its own.
enum NotificationCategory: String, CaseIterable, Sendable {
    case reminders
    case promotions
}

struct PushMessage: Equatable, Sendable {
    let title: String
    let body: String
}
