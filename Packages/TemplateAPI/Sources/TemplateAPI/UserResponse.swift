import Foundation
import SafeDecoding

public struct UserResponse: Decodable, Equatable, Sendable {
    public let id: Int
    public let email: String
    public let createdAt: Date
    public let themeMode: ThemeMode?
    /// Falls back, so a newer server never fails the read.
    public let language: Language
    public let demo: Bool

    public init(id: Int, email: String, createdAt: Date, themeMode: ThemeMode?, language: Language, demo: Bool) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
        self.themeMode = themeMode
        self.language = language
        self.demo = demo
    }

    private enum CodingKeys: String, CodingKey {
        case id, email, createdAt, themeMode, language, demo
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        themeMode = try container.decode(LossyEnum<ThemeMode>.self, forKey: .themeMode).wrappedValue
        language = try container.decode(LossyEnum<Language>.self, forKey: .language).wrappedValue ?? .fallback
        demo = try container.decodeIfPresent(Bool.self, forKey: .demo) ?? false
    }
}
