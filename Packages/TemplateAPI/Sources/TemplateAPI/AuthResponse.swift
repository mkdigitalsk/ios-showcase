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
    /// Falls back, so a newer server never fails the sign-in.
    public let language: Language
    public let demo: Bool

    public init(id: Int, email: String, themeMode: ThemeMode?, language: Language, demo: Bool) {
        self.id = id
        self.email = email
        self.themeMode = themeMode
        self.language = language
        self.demo = demo
    }

    private enum CodingKeys: String, CodingKey {
        case id, email, themeMode, language, demo
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        themeMode = try container.decode(LossyEnum<ThemeMode>.self, forKey: .themeMode).wrappedValue
        language = try container.decode(LossyEnum<Language>.self, forKey: .language).wrappedValue ?? .fallback
        demo = try container.decodeIfPresent(Bool.self, forKey: .demo) ?? false
    }
}
