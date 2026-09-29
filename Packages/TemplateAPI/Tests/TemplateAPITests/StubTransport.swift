import Foundation
import HTTPClient
import HTTPTypes

/// Answers every request with the next scripted response and keeps what it was sent.
actor StubTransport: HTTPTransport {
    struct Sent: Sendable {
        let request: HTTPRequest
        let body: Data?
    }

    enum Scripted: Sendable {
        case response(status: Int, body: String)
        case failure(URLError.Code)
    }

    private(set) var sent: [Sent] = []
    private var script: [Scripted]

    init(_ script: Scripted...) {
        self.script = script
    }

    func send(_ request: HTTPRequest, body: Data?) async throws -> (Data, HTTPResponse) {
        sent.append(Sent(request: request, body: body))
        guard !script.isEmpty else {
            throw URLError(.badServerResponse)
        }
        switch script.removeFirst() {
        case let .response(status, body):
            return (Data(body.utf8), HTTPResponse(status: HTTPResponse.Status(code: status)))
        case let .failure(code):
            throw URLError(code)
        }
    }

    /// The body sent at `index`, decoded as a flat string object — every request body here is one.
    func json(at index: Int) -> [String: String] {
        guard let body = sent[index].body else { return [:] }
        return (try? JSONDecoder().decode([String: String].self, from: body)) ?? [:]
    }
}

let baseURL = URL(string: "https://api.example.com/v1")!
