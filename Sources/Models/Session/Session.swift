struct Session: Equatable, Sendable {
    let token: String
    let userID: Int
    let email: String
    /// The shared test account — it can be signed into, never deleted.
    let isDemo: Bool
}
