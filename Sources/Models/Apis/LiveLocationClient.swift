import CoreLocation

struct LiveLocationClient: LocationClient {
    func currentLocation() async throws -> Location {
        for try await update in CLLocationUpdate.liveUpdates() {
            if update.authorizationDenied || update.authorizationDeniedGlobally || update.authorizationRestricted {
                throw LocationError.denied
            }
            if let location = update.location {
                return Location(location)
            }
            if update.locationUnavailable {
                throw LocationError.unavailable
            }
        }
        throw LocationError.unavailable
    }

    func updates() -> AsyncThrowingStream<Location, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await update in CLLocationUpdate.liveUpdates() {
                        if update.authorizationDenied || update.authorizationDeniedGlobally || update.authorizationRestricted {
                            throw LocationError.denied
                        }
                        if let location = update.location {
                            continuation.yield(Location(location))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

private extension Location {
    init(_ location: CLLocation) {
        self.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}
