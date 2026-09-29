import Foundation
import HTTPClient
import HTTPTypes

/// The calls that need no session: signing in, signing up, and turning a stored token back into one.
public struct UnauthenticatedClient: Sendable {
    private let api: JSONAPI

    public init(baseURL: URL) {
        self.init(baseURL: baseURL, transport: URLSession.shared)
    }

    package init(baseURL: URL, transport: any HTTPTransport) {
        api = JSONAPI(
            baseURL: baseURL,
            transport: transport,
            middlewares: [LoggingMiddleware(subsystem: Self.loggingSubsystem, redactedPaths: ["/auth/"])],
        )
    }

    public func signIn(email: String, password: String) async throws -> AuthResponse {
        try await api.post("auth/sign-in", body: Credentials(email: email, password: password))
    }

    public func signUp(email: String, password: String) async throws -> AuthResponse {
        try await api.post("auth/sign-up", body: Credentials(email: email, password: password))
    }

    /// The session behind a token — 401 once the token expired.
    public func session(token: String) async throws -> AuthResponse {
        try await api.post("auth/token", headers: [.authorization: "Bearer \(token)"])
    }

    static let loggingSubsystem = Bundle.main.bundleIdentifier ?? "TemplateAPI"
}

private struct Credentials: Encodable {
    let email: String
    let password: String
}
