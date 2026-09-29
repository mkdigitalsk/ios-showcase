import Foundation

extension AuthError {
    var text: LocalizedStringResource {
        switch self {
        case .invalidCredentials: .errorInvalidCredentials
        case .emailTaken: .signUpEmailAlreadyExists
        case .sessionExpired: .errorUnauthorized
        case .offline: .errorNoConnection
        case .unavailable: .errorServer
        }
    }
}
