import TemplateAPI

struct LiveAuthRepository: AuthRepository {
    private let client: UnauthenticatedClient

    init(client: UnauthenticatedClient) {
        self.client = client
    }

    func signIn(email: String, password: String) async throws -> Session {
        try await mapped { try await Session(client.signIn(email: email, password: password)) }
    }

    func signUp(email: String, password: String) async throws -> Session {
        try await mapped { try await Session(client.signUp(email: email, password: password)) }
    }

    func restore(token: String) async throws -> Session {
        do {
            return try await mapped { try await Session(client.session(token: token)) }
        } catch AuthError.invalidCredentials {
            throw AuthError.sessionExpired
        }
    }

    private func mapped(_ call: () async throws -> Session) async throws -> Session {
        do {
            return try await call()
        } catch let error as APIError {
            throw AuthError(error)
        }
    }
}

private extension Session {
    init(_ response: AuthResponse) {
        self.init(token: response.token, userID: response.user.id, email: response.user.email, isDemo: response.user.demo)
    }
}

private extension AuthError {
    init(_ error: APIError) {
        self = switch error {
        case .unauthorized: .invalidCredentials
        case .conflict: .emailTaken
        case .offline: .offline
        default: .unavailable
        }
    }
}
