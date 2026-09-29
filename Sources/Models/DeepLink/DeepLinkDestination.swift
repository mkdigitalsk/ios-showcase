/// Every place a `<scheme>://<destination>` link can open; the raw value is the link's own spelling.
enum DeepLinkDestination: String, CaseIterable, Equatable, Sendable {
    case home
    case settings
    case signIn = "sign-in"
    case signUp = "sign-up"
    case networking
    case storage
    case uiComponents = "ui-components"
    case apis
    case scanner
    case database
    case calendar
    case notifications
}
