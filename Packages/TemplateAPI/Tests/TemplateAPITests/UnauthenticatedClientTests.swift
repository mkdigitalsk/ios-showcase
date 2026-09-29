import Foundation
@testable import TemplateAPI
import Testing

struct UnauthenticatedClientTests {
    private static let authBody = """
    {"token":"t0k3n","user":{"id":2,"email":"a@b.c","themeMode":"light","locale":"en-GB","demo":true}}
    """

    @Test
    func `sign-in posts the credentials and decodes the session`() async throws {
        let transport = StubTransport(.response(status: 200, body: Self.authBody))
        let client = UnauthenticatedClient(baseURL: baseURL, transport: transport)

        let response = try await client.signIn(email: "a@b.c", password: "secret")

        #expect(response.token == "t0k3n")
        #expect(response.user == AuthUser(id: 2, email: "a@b.c", themeMode: .light, locale: "en-GB", demo: true))
        let sent = await transport.sent[0]
        #expect(sent.request.method == .post)
        #expect(sent.request.path == "/v1/auth/sign-in")
        #expect(sent.request.headerFields[.contentType] == "application/json")
        let body = await transport.json(at: 0)
        #expect(body["email"] == "a@b.c")
        #expect(body["password"] == "secret")
    }

    @Test
    func `a 401 is unauthorized`() async throws {
        let transport = StubTransport(.response(status: 401, body: #"{"message":"Invalid credentials"}"#))
        let client = UnauthenticatedClient(baseURL: baseURL, transport: transport)

        await #expect(throws: APIError.unauthorized) {
            try await client.signIn(email: "a@b.c", password: "wrong")
        }
    }

    @Test
    func `a 409 on sign-up is a conflict`() async throws {
        let transport = StubTransport(.response(status: 409, body: #"{"title":"Conflict","status":409,"detail":"User already exists"}"#))
        let client = UnauthenticatedClient(baseURL: baseURL, transport: transport)

        await #expect(throws: APIError.conflict) {
            try await client.signUp(email: "a@b.c", password: "secret")
        }
    }

    @Test
    func `an unknown theme mode decodes as nil, not as a failure`() async throws {
        let body = #"{"token":"t","user":{"id":1,"email":"a@b.c","themeMode":"sepia","locale":"en-GB"}}"#
        let client = UnauthenticatedClient(baseURL: baseURL, transport: StubTransport(.response(status: 200, body: body)))

        let response = try await client.signIn(email: "a@b.c", password: "secret")

        #expect(response.user.themeMode == nil)
        #expect(response.user.demo == false)
    }

    @Test
    func `the session call carries the token as a bearer`() async throws {
        let transport = StubTransport(.response(status: 200, body: Self.authBody))
        let client = UnauthenticatedClient(baseURL: baseURL, transport: transport)

        _ = try await client.session(token: "stored")

        let sent = await transport.sent[0]
        #expect(sent.request.path == "/v1/auth/token")
        #expect(sent.request.headerFields[.authorization] == "Bearer stored")
    }

    @Test
    func `a lost connection is offline and a cancelled request stays a cancellation`() async throws {
        let offline = UnauthenticatedClient(baseURL: baseURL, transport: StubTransport(.failure(.notConnectedToInternet)))
        await #expect(throws: APIError.offline) {
            try await offline.signIn(email: "a@b.c", password: "secret")
        }

        let cancelled = UnauthenticatedClient(baseURL: baseURL, transport: StubTransport(.failure(.cancelled)))
        await #expect(throws: CancellationError.self) {
            try await cancelled.signIn(email: "a@b.c", password: "secret")
        }
    }

    @Test
    func `a server error carries the problem detail`() async throws {
        let transport = StubTransport(.response(status: 500, body: #"{"title":"Internal Server Error","status":500,"detail":"database down"}"#))
        let client = UnauthenticatedClient(baseURL: baseURL, transport: transport)

        await #expect(throws: APIError.status(500, detail: "database down")) {
            try await client.signIn(email: "a@b.c", password: "secret")
        }
    }
}
