#if DEBUG
import Observation

@MainActor
@Observable
final class StubPushClient: PushClient {
    private(set) var token: String?
    private(set) var lastReceived: PushMessage?
    private(set) var refreshes = 0

    init(token: String? = "stub-push-token-0123456789abcdef", lastReceived: PushMessage? = nil) {
        self.token = token
        self.lastReceived = lastReceived
    }

    func refreshToken() async {
        refreshes += 1
        token = "stub-push-token-refreshed-\(refreshes)"
    }

    func receive(_ message: PushMessage) {
        lastReceived = message
    }
}
#endif
