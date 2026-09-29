#if DEBUG
struct StubLocationClient: LocationClient {
    private let location: Location
    private let track: [Location]
    private let failure: LocationError?

    init(location: Location = .stub, track: [Location] = .stubTrack, failure: LocationError? = nil) {
        self.location = location
        self.track = track
        self.failure = failure
    }

    func currentLocation() async throws -> Location {
        if let failure {
            throw failure
        }
        return location
    }

    func updates() -> AsyncThrowingStream<Location, any Error> {
        AsyncThrowingStream { continuation in
            if let failure {
                continuation.finish(throwing: failure)
                return
            }
            for point in track {
                continuation.yield(point)
            }
            continuation.finish()
        }
    }
}

extension Location {
    static let stub = Location(latitude: 48.148598, longitude: 17.107748)
}

extension [Location] {
    static let stubTrack: [Location] = [
        Location(latitude: 48.148598, longitude: 17.107748),
        Location(latitude: 48.148700, longitude: 17.107900),
        Location(latitude: 48.148810, longitude: 17.108050),
    ]
}
#endif
