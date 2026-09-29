import LocalAuthentication

struct LiveBiometricClient: BiometricClient {
    func availableKind() -> BiometricKind {
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else { return .none }
        return switch context.biometryType {
        case .faceID: .faceID
        case .touchID: .touchID
        case .opticID: .opticID
        default: .none
        }
    }

    func authenticate(reason: String) async -> BiometricOutcome {
        let context = LAContext()
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) ? .success : .failed(nil)
        } catch let error as LAError {
            return switch error.code {
            case .userCancel, .appCancel, .systemCancel, .userFallback: .cancelled
            case .biometryNotAvailable, .biometryNotEnrolled, .passcodeNotSet: .notAvailable
            default: .failed(error.localizedDescription)
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}
