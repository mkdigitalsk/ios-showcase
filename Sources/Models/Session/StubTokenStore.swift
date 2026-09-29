#if DEBUG
actor StubTokenStore: TokenStore {
    private(set) var token: String?

    init(token: String? = nil) {
        self.token = token
    }

    func load() async throws -> String? {
        token
    }

    func save(_ token: String) async throws {
        self.token = token
    }

    func remove() async throws {
        token = nil
    }
}
#endif
