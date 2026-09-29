import Foundation
import HTTPTypes

/// One base URL, one transport, one middleware chain; a request is a method and a relative path.
package struct Client: Sendable {
    private let scheme: String
    private let authority: String
    private let basePath: String
    private let transport: any HTTPTransport
    private let middlewares: [any ClientMiddleware]

    package init(baseURL: URL, transport: any HTTPTransport, middlewares: [any ClientMiddleware] = []) {
        let components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        scheme = components?.scheme ?? "https"
        let host = components?.host ?? ""
        authority = components?.port.map { "\(host):\($0)" } ?? host
        var path = components?.path ?? ""
        while path.hasSuffix("/") {
            path.removeLast()
        }
        basePath = path
        self.transport = transport
        self.middlewares = middlewares
    }

    /// Runs the request through every middleware and returns a 2xx response; any other status throws
    /// `HTTPClientError.status`, and a transport failure throws what the transport threw.
    package func send(
        _ method: HTTPRequest.Method,
        path: String,
        headers: HTTPFields = [:],
        body: Data? = nil,
    ) async throws -> (Data, HTTPResponse) {
        var headerFields = headers
        if body != nil, headerFields[.contentType] == nil {
            headerFields[.contentType] = "application/json"
        }
        let request = HTTPRequest(
            method: method,
            scheme: scheme,
            authority: authority,
            path: basePath + "/" + path.trimmingCharacters(in: CharacterSet(charactersIn: "/")),
            headerFields: headerFields,
        )

        var next: @Sendable (HTTPRequest, Data?) async throws -> (Data, HTTPResponse) = { [transport] request, body in
            try await transport.send(request, body: body)
        }
        for middleware in middlewares.reversed() {
            let inner = next
            next = { request, body in
                try await middleware.intercept(request, body: body, next: inner)
            }
        }

        let (data, response) = try await next(request, body)
        guard (200 ..< 300).contains(response.status.code) else {
            throw HTTPClientError.status(code: response.status.code, body: data)
        }
        return (data, response)
    }
}
