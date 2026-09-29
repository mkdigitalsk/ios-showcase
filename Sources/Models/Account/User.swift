struct User: Equatable, Sendable {
    let id: Int
    let email: String
    /// The shared test account, which the server refuses to delete.
    let isDemo: Bool
}
