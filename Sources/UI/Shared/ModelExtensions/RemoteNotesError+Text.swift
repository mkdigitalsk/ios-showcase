import Foundation

extension RemoteNotesError {
    var text: LocalizedStringResource {
        switch self {
        case .offline: .errorNoConnection
        case .unauthorized: .errorUnauthorized
        case .unavailable: .errorServer
        }
    }
}
