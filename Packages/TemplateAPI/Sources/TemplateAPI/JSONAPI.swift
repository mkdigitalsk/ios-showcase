import Foundation
import HTTPClient
import HTTPTypes

/// JSON in, JSON out, `APIError` on the way back — the one place a client's request is performed.
struct JSONAPI: Sendable {
    private let client: Client
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL, transport: any HTTPTransport, middlewares: [any ClientMiddleware]) {
        client = Client(baseURL: baseURL, transport: transport, middlewares: middlewares)
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        encoder = JSONEncoder()
    }

    func get<Response: Decodable>(_ path: String) async throws -> Response {
        try await decode(send(.get, path: path, headers: [:], body: nil))
    }

    func post<Response: Decodable>(_ path: String, headers: HTTPFields = [:]) async throws -> Response {
        try await decode(send(.post, path: path, headers: headers, body: nil))
    }

    func post<Response: Decodable>(_ path: String, headers: HTTPFields = [:], body: some Encodable) async throws -> Response {
        try await decode(send(.post, path: path, headers: headers, body: encode(body)))
    }

    func put<Response: Decodable>(_ path: String, headers: HTTPFields = [:], body: some Encodable) async throws -> Response {
        try await decode(send(.put, path: path, headers: headers, body: encode(body)))
    }

    func delete(_ path: String) async throws {
        _ = try await send(.delete, path: path, headers: [:], body: nil)
    }

    private func send(_ method: HTTPRequest.Method, path: String, headers: HTTPFields, body: Data?) async throws -> Data {
        do {
            return try await client.send(method, path: path, headers: headers, body: body).0
        } catch {
            throw APIError.map(error, decoder: decoder)
        }
    }

    private func encode(_ body: some Encodable) throws -> Data {
        do {
            return try encoder.encode(body)
        } catch {
            throw APIError.map(error, decoder: decoder)
        }
    }

    private func decode<Response: Decodable>(_ data: Data) throws -> Response {
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.map(error, decoder: decoder)
        }
    }
}
