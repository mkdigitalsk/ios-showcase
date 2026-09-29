import Foundation
import HTTPClient
import HTTPTypes
import Testing

private actor RecordingTransport: HTTPTransport {
    private(set) var requests: [HTTPRequest] = []
    private let status: Int

    init(status: Int) {
        self.status = status
    }

    func send(_ request: HTTPRequest, body _: Data?) async throws -> (Data, HTTPResponse) {
        requests.append(request)
        return (Data("{}".utf8), HTTPResponse(status: HTTPResponse.Status(code: status)))
    }
}

private struct HeaderMiddleware: ClientMiddleware {
    let name: HTTPField.Name
    let value: String

    func intercept(
        _ request: HTTPRequest,
        body: Data?,
        next: @Sendable (HTTPRequest, Data?) async throws -> (Data, HTTPResponse),
    ) async throws -> (Data, HTTPResponse) {
        var request = request
        request.headerFields[name] = value
        return try await next(request, body)
    }
}

struct ClientTests {
    @Test
    func `the base path and the request path join with one slash`() async throws {
        let transport = RecordingTransport(status: 200)
        let client = try Client(baseURL: #require(URL(string: "https://host.example:8443/v1/")), transport: transport)

        _ = try await client.send(.get, path: "/notes/")

        let request = await transport.requests[0]
        #expect(request.authority == "host.example:8443")
        #expect(request.path == "/v1/notes")
    }

    @Test
    func `middlewares run in order, the first one outermost`() async throws {
        let transport = RecordingTransport(status: 200)
        let client = try Client(
            baseURL: #require(URL(string: "https://host.example")),
            transport: transport,
            middlewares: [
                HeaderMiddleware(name: .accept, value: "first"),
                HeaderMiddleware(name: .accept, value: "second"),
            ],
        )

        _ = try await client.send(.get, path: "x")

        #expect(await transport.requests[0].headerFields[.accept] == "second")
    }

    @Test
    func `a body gets a JSON content type and a non-2xx status throws`() async throws {
        let transport = RecordingTransport(status: 418)
        let client = try Client(baseURL: #require(URL(string: "https://host.example")), transport: transport)

        await #expect(throws: HTTPClientError.status(code: 418, body: Data("{}".utf8))) {
            try await client.send(.post, path: "x", body: Data("{}".utf8))
        }
        #expect(await transport.requests[0].headerFields[.contentType] == "application/json")
    }
}
