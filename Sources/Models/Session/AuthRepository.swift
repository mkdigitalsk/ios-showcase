protocol AuthRepository: Sendable {
    func signIn(email: String, password: String) async throws -> Session
    func signUp(email: String, password: String) async throws -> Session
    /// The session a stored token still opens; `AuthError.sessionExpired` once it does not.
    func restore(token: String) async throws -> Session
}
