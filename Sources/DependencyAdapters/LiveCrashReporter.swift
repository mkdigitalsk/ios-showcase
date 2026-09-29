import Foundation
import OSLog

/// Logs a recorded error; a crash SDK replaces the body of `record` and nothing else.
struct LiveCrashReporter: CrashReporter {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TemplateIOS", category: "crash")

    func record(_ error: any Error) {
        Self.logger.error("recorded: \(String(describing: error), privacy: .public)")
    }
}
