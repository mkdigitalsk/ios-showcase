import Foundation
import HTTPTypes
import OSLog

/// Logs every exchange to the unified log; a body on a redacted path is logged as `<redacted>`.
package struct LoggingMiddleware: ClientMiddleware {
    private let logger: Logger
    private let redactedPaths: [String]

    package init(subsystem: String, redactedPaths: [String] = []) {
        logger = Logger(subsystem: subsystem, category: "network")
        self.redactedPaths = redactedPaths
    }

    package func intercept(
        _ request: HTTPRequest,
        body: Data?,
        next: @Sendable (HTTPRequest, Data?) async throws -> (Data, HTTPResponse),
    ) async throws -> (Data, HTTPResponse) {
        let path = request.path ?? ""
        let redacted = redactedPaths.contains { path.contains($0) }
        logger.notice("→ \(request.method.rawValue, privacy: .public) \(path, privacy: .public)")
        if let body {
            logger.debug("→ body \(Self.describe(body, redacted: redacted), privacy: .public)")
        }
        do {
            let (data, response) = try await next(request, body)
            logger.notice("← \(response.status.code, privacy: .public) \(path, privacy: .public)")
            logger.debug("← body \(Self.describe(data, redacted: redacted), privacy: .public)")
            return (data, response)
        } catch {
            logger.notice("✗ \(path, privacy: .public) — \(String(describing: error), privacy: .public)")
            throw error
        }
    }

    private static func describe(_ data: Data, redacted: Bool) -> String {
        guard !redacted else { return "<redacted>" }
        guard
            let json = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
        else {
            return String(decoding: data, as: UTF8.self)
        }
        return String(decoding: pretty, as: UTF8.self)
    }
}
