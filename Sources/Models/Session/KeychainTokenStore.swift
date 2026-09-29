import Foundation

struct KeychainTokenStore: TokenStore {
    private static let claimedKey = "session.keychainClaimed"
    private let store = KeychainStore(account: "session-token")

    /// The keychain outlives the app: a token left by a deleted install would sign the next one in.
    /// The first launch after an install claims the keychain by clearing it.
    init(defaults: UserDefaults) {
        guard !defaults.bool(forKey: Self.claimedKey) else { return }
        try? store.remove()
        defaults.set(true, forKey: Self.claimedKey)
    }

    func load() async throws -> String? {
        try store.load().map { String(decoding: $0, as: UTF8.self) }
    }

    func save(_ token: String) async throws {
        try store.save(Data(token.utf8))
    }

    func remove() async throws {
        try store.remove()
    }
}
