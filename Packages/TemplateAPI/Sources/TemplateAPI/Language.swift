/// A language the account reads the app in, by its key on the wire.
public enum Language: String, Codable, Sendable, CaseIterable {
    case sk = "SK"
    case en = "EN"

    /// What a key this build does not know reads as.
    public static let fallback: Language = .en
}
