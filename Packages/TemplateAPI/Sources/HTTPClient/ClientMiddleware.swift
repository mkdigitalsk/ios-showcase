import Foundation
import HTTPTypes

/// Sees every request on its way out and every response on its way back.
package protocol ClientMiddleware: Sendable {
    func intercept(
        _ request: HTTPRequest,
        body: Data?,
        next: @Sendable (HTTPRequest, Data?) async throws -> (Data, HTTPResponse),
    ) async throws -> (Data, HTTPResponse)
}
