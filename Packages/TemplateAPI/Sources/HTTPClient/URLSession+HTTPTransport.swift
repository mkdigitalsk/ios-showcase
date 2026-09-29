import Foundation
import HTTPTypesFoundation

extension URLSession: HTTPTransport {
    package func send(_ request: HTTPRequest, body: Data?) async throws -> (Data, HTTPResponse) {
        if let body {
            try await upload(for: request, from: body)
        } else {
            try await data(for: request)
        }
    }
}
