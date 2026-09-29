import Observation

/// The push side: the token the server addresses this install by, and the last message that arrived
/// while the app was open. Observable, so a screen follows both as they change.
@MainActor
protocol PushClient: AnyObject, Observable {
    var token: String? { get }
    var lastReceived: PushMessage? { get }
    /// Asks the platform for a new token; the new one lands in `token`.
    func refreshToken() async
}
