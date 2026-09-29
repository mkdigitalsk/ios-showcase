import Foundation

enum HomeFeature: CaseIterable, Identifiable {
    case uiComponents
    case networking
    case storage
    case apis
    case scanner
    case database
    case calendar
    case notifications

    var id: Self {
        self
    }

    var title: LocalizedStringResource {
        switch self {
        case .uiComponents: .homeFeatureUiComponents
        case .networking: .homeFeatureNetworking
        case .storage: .homeFeatureStorage
        case .apis: .homeFeatureApis
        case .scanner: .homeFeatureScanner
        case .database: .homeFeatureDatabase
        case .calendar: .homeFeatureCalendar
        case .notifications: .homeFeatureNotifications
        }
    }

    var systemImage: String {
        switch self {
        case .uiComponents: "square.grid.2x2"
        case .networking: "network"
        case .storage: "internaldrive"
        case .apis: "iphone.gen3"
        case .scanner: "qrcode.viewfinder"
        case .database: "tray.full"
        case .calendar: "calendar"
        case .notifications: "bell"
        }
    }

    init?(deepLink: DeepLinkDestination) {
        switch deepLink {
        case .uiComponents: self = .uiComponents
        case .networking: self = .networking
        case .storage: self = .storage
        case .apis: self = .apis
        case .scanner: self = .scanner
        case .database: self = .database
        case .calendar: self = .calendar
        case .notifications: self = .notifications
        default: return nil
        }
    }
}
