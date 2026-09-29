import Foundation
import HTTPTypes

package struct BearerAuthMiddleware: ClientMiddleware {
    private let token: String

    package init(token: String) {
        self.token = token
    }

    package func intercept(
        _ request: HTTPRequest,
        body: Data?,
        next: @Sendable (HTTPRequest, Data?) async throws -> (Data, HTTPResponse),
    ) async throws -> (Data, HTTPResponse) {
        var request = request
        request.headerFields[.authorization] = "Bearer \(token)"
        return try await next(request, body)
    }
}
