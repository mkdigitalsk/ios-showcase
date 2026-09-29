import Observation

/// Fed by the app delegate: the APNs device token as it registers, and each message shown in front.
@MainActor
@Observable
final class LivePushClient: PushClient {
    private(set) var token: String?
    private(set) var lastReceived: PushMessage?
    private let register: @MainActor () -> Void

    init(register: @escaping @MainActor () -> Void) {
        self.register = register
    }

    func refreshToken() async {
        token = nil
        register()
    }

    func tokenReceived(_ token: String) {
        self.token = token
    }

    func received(_ message: PushMessage) {
        lastReceived = message
    }
}
