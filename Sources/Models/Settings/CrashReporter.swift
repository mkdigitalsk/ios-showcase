/// Where a handled error is reported; the live one is the crash SDK in `DependencyAdapters`.
protocol CrashReporter: Sendable {
    func record(_ error: any Error)
}

#if DEBUG
final class StubCrashReporter: CrashReporter, @unchecked Sendable {
    private(set) var recorded: [String] = []

    func record(_ error: any Error) {
        recorded.append(String(describing: error))
    }
}
#endif
