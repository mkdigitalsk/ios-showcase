import Observation

/// The platform integrations the Apis screen demonstrates: one location fix, live tracking, biometrics.
@MainActor
@Observable
final class ApisModel {
    private(set) var location: Location?
    private(set) var isLocating = false
    private(set) var locationFailed = false
    private(set) var isTracking = false
    private(set) var trackedLocation: Location?
    private(set) var trackingFailed = false
    private(set) var biometricKind = BiometricKind.none
    private(set) var isAuthenticating = false
    private(set) var biometricOutcome: BiometricOutcome?
    private(set) var copied = false
    private(set) var unavailableApps: Set<ExternalApp> = []
    private var trackingTask: Task<Void, Never>?
    private let locationClient: any LocationClient
    private let biometricClient: any BiometricClient

    init(locationClient: any LocationClient, biometricClient: any BiometricClient) {
        self.locationClient = locationClient
        self.biometricClient = biometricClient
    }

    func load() {
        biometricKind = biometricClient.availableKind()
    }

    func locate() async {
        isLocating = true
        defer { isLocating = false }
        do {
            let fix = try await locationClient.currentLocation()
            guard !Task.isCancelled else { return }
            location = fix
            locationFailed = false
        } catch where error.isCancellation {
            return
        } catch {
            guard !Task.isCancelled else { return }
            locationFailed = true
        }
    }

    func startTracking() {
        guard trackingTask == nil else { return }
        isTracking = true
        trackingFailed = false
        trackingTask = Task { [weak self, locationClient] in
            do {
                for try await fix in locationClient.updates() {
                    guard !Task.isCancelled else { return }
                    self?.trackedLocation = fix
                }
            } catch {
                guard !Task.isCancelled else { return }
                self?.trackingFailed = true
            }
            self?.isTracking = false
            self?.trackingTask = nil
        }
    }

    func stopTracking() {
        trackingTask?.cancel()
        trackingTask = nil
        isTracking = false
    }

    func authenticate(reason: String) async {
        isAuthenticating = true
        biometricOutcome = nil
        defer { isAuthenticating = false }
        let outcome = await biometricClient.authenticate(reason: reason)
        guard !Task.isCancelled else { return }
        biometricOutcome = outcome
    }

    func markCopied() {
        copied = true
    }

    func externalAppOpened(_ app: ExternalApp, accepted: Bool) {
        if accepted {
            unavailableApps.remove(app)
        } else {
            unavailableApps.insert(app)
        }
    }
}
