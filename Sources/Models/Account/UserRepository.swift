protocol UserRepository: Sendable {
    func me() async throws -> User
    func deleteAccount() async throws
}

enum UserError: Error, Equatable {
    case offline
    case unauthorized
    case unavailable
}
