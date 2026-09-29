import Foundation

extension BiometricOutcome {
    var text: LocalizedStringResource {
        switch self {
        case .success: .apisBiometricsSuccess
        case let .failed(detail?): .apisBiometricsFailedDetail(detail)
        case .failed(nil): .apisBiometricsFailed
        case .cancelled: .apisBiometricsCancelled
        case .notAvailable: .apisBiometricsNotAvailable
        }
    }
}

extension BiometricKind {
    var text: LocalizedStringResource? {
        switch self {
        case .faceID: .apisBiometricsFaceId
        case .touchID: .apisBiometricsTouchId
        case .opticID: .apisBiometricsOpticId
        case .none: nil
        }
    }
}
