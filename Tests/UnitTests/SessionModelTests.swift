@testable import TemplateIOS
import Testing

@MainActor
struct SessionModelTests {
    @Test
    func `a stored token that still opens restores the session`() async {
        let model = SessionModel(repository: StubAuthRepository(), tokenStore: StubTokenStore(token: Session.stub.token))

        await model.restore()

        #expect(model.session == .stub)
        #expect(!model.isRestoring)
    }

    @Test
    func `no stored token ends restoring with no session`() async {
        let model = SessionModel(repository: StubAuthRepository(), tokenStore: StubTokenStore())

        await model.restore()

        #expect(model.session == nil)
        #expect(!model.isRestoring)
    }

    @Test
    func `a rejected token is removed`() async {
        let store = StubTokenStore(token: "stale")
        let model = SessionModel(repository: StubAuthRepository(), tokenStore: store)

        await model.restore()

        #expect(model.session == nil)
        #expect(await store.token == nil)
    }

    @Test
    func `a token the network could not check stays for the next launch`() async {
        let store = StubTokenStore(token: Session.stub.token)
        let model = SessionModel(repository: StubAuthRepository(failure: .offline), tokenStore: store)

        await model.restore()

        #expect(model.session == nil)
        #expect(await store.token == Session.stub.token)
    }

    @Test
    func `signing in saves the token before the session shows`() async throws {
        let store = StubTokenStore()
        let model = SessionModel(repository: StubAuthRepository(), tokenStore: store)

        try await model.signIn(email: "a@b.co", password: "Secret1@")

        #expect(model.session?.email == "a@b.co")
        #expect(await store.token == Session.stub.token)
    }

    @Test
    func `a failed sign-in throws and opens nothing`() async {
        let model = SessionModel(repository: StubAuthRepository(failure: .invalidCredentials), tokenStore: StubTokenStore())

        await #expect(throws: AuthError.invalidCredentials) {
            try await model.signIn(email: "a@b.co", password: "wrong")
        }

        #expect(model.session == nil)
    }

    @Test
    func `signing out removes the token and the session`() async throws {
        let store = StubTokenStore()
        let model = SessionModel(repository: StubAuthRepository(), tokenStore: store)
        try await model.signUp(email: "a@b.co", password: "Secret1@")

        await model.signOut()

        #expect(model.session == nil)
        #expect(await store.token == nil)
    }
}
