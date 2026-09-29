protocol LocationClient: Sendable {
    /// One fix, asking for permission on the way if it was never asked.
    func currentLocation() async throws -> Location
    /// A fix per movement until the stream is cancelled.
    func updates() -> AsyncThrowingStream<Location, any Error>
}

enum LocationError: Error, Equatable {
    case denied
    case unavailable
}
