import Foundation

enum AppConfiguration {
    static let apiBaseURL = requiredURL("ApiBaseUrl")
    static let privacyURL = requiredURL("PrivacyUrl")
    static let urlScheme = requiredValue("UrlScheme")
    static let buildType = requiredValue("BuildType")
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    static let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"

    private static func requiredValue(_ key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else {
            preconditionFailure("Info.plist carries no \(key) — the xcconfig of this configuration sets it")
        }
        return value
    }

    private static func requiredURL(_ key: String) -> URL {
        guard let url = URL(string: requiredValue(key)) else {
            preconditionFailure("Info.plist value for \(key) is not a URL")
        }
        return url
    }
}
