import Foundation
import HTTPTypes

/// What sends one request and returns one response — `URLSession` in the app, a stub in a test.
package protocol HTTPTransport: Sendable {
    func send(_ request: HTTPRequest, body: Data?) async throws -> (Data, HTTPResponse)
}
