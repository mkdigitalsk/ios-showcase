import SafeDecoding

public struct AuthResponse: Decodable, Equatable, Sendable {
    public let token: String
    public let user: AuthUser

    public init(token: String, user: AuthUser) {
        self.token = token
        self.user = user
    }
}

public struct AuthUser: Decodable, Equatable, Sendable {
    public let id: Int
    public let email: String
    /// `nil` when the server sends a mode this build does not know.
    public let themeMode: ThemeMode?
    public let locale: String
    public let demo: Bool

    public init(id: Int, email: String, themeMode: ThemeMode?, locale: String, demo: Bool) {
        self.id = id
        self.email = email
        self.themeMode = themeMode
        self.locale = locale
        self.demo = demo
    }

    private enum CodingKeys: String, CodingKey {
        case id, email, themeMode, locale, demo
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        themeMode = try container.decode(LossyEnum<ThemeMode>.self, forKey: .themeMode).wrappedValue
        locale = try container.decode(String.self, forKey: .locale)
        demo = try container.decodeIfPresent(Bool.self, forKey: .demo) ?? false
    }
}
