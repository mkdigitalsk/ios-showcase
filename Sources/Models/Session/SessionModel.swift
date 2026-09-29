import Observation

/// Who is signed in. `isRestoring` holds the root on the splash until the stored token has been asked.
@MainActor
@Observable
final class SessionModel {
    private(set) var session: Session?
    private(set) var isRestoring = true
    private let repository: any AuthRepository
    private let tokenStore: any TokenStore

    init(repository: any AuthRepository, tokenStore: any TokenStore) {
        self.repository = repository
        self.tokenStore = tokenStore
    }

    /// Opens the session a stored token still holds. A rejected token is removed; a token the
    /// network could not check stays for the next launch.
    func restore() async {
        guard isRestoring else { return }
        defer { isRestoring = false }
        guard let token = try? await tokenStore.load(), !Task.isCancelled else { return }
        do {
            let restored = try await repository.restore(token: token)
            guard !Task.isCancelled else { return }
            session = restored
        } catch AuthError.sessionExpired, AuthError.invalidCredentials {
            try? await tokenStore.remove()
        } catch {}
    }

    func signIn(email: String, password: String) async throws {
        try await open(repository.signIn(email: email, password: password))
    }

    func signUp(email: String, password: String) async throws {
        try await open(repository.signUp(email: email, password: password))
    }

    func signOut() async {
        try? await tokenStore.remove()
        session = nil
    }

    private func open(_ opened: Session) async throws {
        try await tokenStore.save(opened.token)
        session = opened
    }
}
