#if DEBUG
actor StubAuthRepository: AuthRepository {
    private let session: Session
    private let failure: AuthError?
    private(set) var signIns: [(email: String, password: String)] = []

    init(session: Session = .stub, failure: AuthError? = nil) {
        self.session = session
        self.failure = failure
    }

    func signIn(email: String, password: String) async throws -> Session {
        signIns.append((email, password))
        if let failure {
            throw failure
        }
        return Session(token: session.token, userID: session.userID, email: email, isDemo: session.isDemo)
    }

    func signUp(email: String, password: String) async throws -> Session {
        try await signIn(email: email, password: password)
    }

    func restore(token: String) async throws -> Session {
        if let failure {
            throw failure
        }
        guard token == session.token else { throw AuthError.sessionExpired }
        return session
    }
}

extension Session {
    static let stub = Session(token: "stub-token", userID: 1, email: "preview@example.com", isDemo: true)
}
#endif
