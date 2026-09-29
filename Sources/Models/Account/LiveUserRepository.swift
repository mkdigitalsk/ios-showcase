import TemplateAPI

struct LiveUserRepository: UserRepository {
    private let client: AuthenticatedClient

    init(client: AuthenticatedClient) {
        self.client = client
    }

    func me() async throws -> User {
        try await mapped {
            let response = try await client.me()
            return User(id: response.id, email: response.email, isDemo: response.demo)
        }
    }

    func deleteAccount() async throws {
        try await mapped { try await client.deleteMe() }
    }

    private func mapped<Value>(_ call: () async throws -> Value) async throws -> Value {
        do {
            return try await call()
        } catch let error as APIError {
            throw UserError(error)
        }
    }
}

private extension UserError {
    init(_ error: APIError) {
        self = switch error {
        case .unauthorized: .unauthorized
        case .offline: .offline
        default: .unavailable
        }
    }
}
