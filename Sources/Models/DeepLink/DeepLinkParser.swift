import Foundation

struct DeepLinkParser: Sendable {
    private let scheme: String

    init(scheme: String) {
        self.scheme = scheme.lowercased()
    }

    /// `<scheme>://<destination>`; an empty destination is Home, an unknown one is nothing.
    func parse(_ url: URL) -> DeepLinkDestination? {
        guard url.scheme?.lowercased() == scheme else { return nil }
        let segment = (url.host() ?? url.path())
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .lowercased()
        switch segment {
        case "": return .home
        case "uicomponents": return .uiComponents
        default: return DeepLinkDestination(rawValue: segment)
        }
    }
}
