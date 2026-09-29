enum BiometricKind: Equatable, Sendable {
    case faceID
    case touchID
    case opticID
    case none
}

enum BiometricOutcome: Equatable, Sendable {
    case success
    case failed(String?)
    case cancelled
    case notAvailable
}

protocol BiometricClient: Sendable {
    func availableKind() -> BiometricKind
    func authenticate(reason: String) async -> BiometricOutcome
}
