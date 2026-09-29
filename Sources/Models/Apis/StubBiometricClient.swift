#if DEBUG
struct StubBiometricClient: BiometricClient {
    private let kind: BiometricKind
    private let outcome: BiometricOutcome

    init(kind: BiometricKind = .faceID, outcome: BiometricOutcome = .success) {
        self.kind = kind
        self.outcome = outcome
    }

    func availableKind() -> BiometricKind {
        kind
    }

    func authenticate(reason _: String) async -> BiometricOutcome {
        outcome
    }
}
#endif
