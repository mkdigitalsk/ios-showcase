protocol TokenStore: Sendable {
    func load() async throws -> String?
    func save(_ token: String) async throws
    func remove() async throws
}
