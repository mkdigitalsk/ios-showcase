#if DEBUG
actor StubUserRepository: UserRepository {
    private let user: User
    private let failure: UserError?
    private(set) var deleted = false

    init(user: User = .stub, failure: UserError? = nil) {
        self.user = user
        self.failure = failure
    }

    func me() async throws -> User {
        if let failure {
            throw failure
        }
        return user
    }

    func deleteAccount() async throws {
        if let failure {
            throw failure
        }
        deleted = true
    }
}

extension User {
    static let stub = User(id: 1, email: "preview@example.com", isDemo: true)
}
#endif
