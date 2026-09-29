import Foundation
@testable import TemplateAPI
import Testing

struct AuthenticatedClientTests {
    private static let note = """
    {"id":7,"title":"Buy milk","content":"two litres","createdAt":1789575321537,"updatedAt":1789575321804,"etag":"\\"1\\""}
    """

    @Test
    func `every request carries the bearer token`() async throws {
        let transport = StubTransport(.response(status: 200, body: "[]"))
        let client = AuthenticatedClient(baseURL: baseURL, token: "t0k3n", transport: transport)

        _ = try await client.notes()

        let sent = await transport.sent[0]
        #expect(sent.request.headerFields[.authorization] == "Bearer t0k3n")
        #expect(sent.request.path == "/v1/notes")
    }

    @Test
    func `a note that does not decode is dropped from the list`() async throws {
        let body = "[\(Self.note), {\"id\":\"broken\"}]"
        let client = AuthenticatedClient(baseURL: baseURL, token: "t", transport: StubTransport(.response(status: 200, body: body)))

        let notes = try await client.notes()

        #expect(notes.map(\.id) == [7])
        #expect(notes[0].etag == "\"1\"")
        #expect(notes[0].createdAt == Date(timeIntervalSince1970: 1_789_575_321.537))
    }

    @Test
    func `an update sends If-Match and a 412 carries the server's note`() async throws {
        let transport = StubTransport(.response(status: 412, body: Self.note))
        let client = AuthenticatedClient(baseURL: baseURL, token: "t", transport: transport)

        let current = try JSONDecoder.api.decode(NoteResponse.self, from: Data(Self.note.utf8))
        await #expect(throws: APIError.preconditionFailed(current: current)) {
            try await client.updateNote(id: 7, etag: "\"0\"", NoteRequest(title: "Buy milk", content: "three litres"))
        }
        let sent = await transport.sent[0]
        #expect(sent.request.method == .put)
        #expect(sent.request.path == "/v1/notes/7")
        #expect(sent.request.headerFields[.ifMatch] == "\"0\"")
    }

    @Test
    func `a delete needs no body and a missing note is not found`() async throws {
        let transport = StubTransport(.response(status: 204, body: ""), .response(status: 404, body: ""))
        let client = AuthenticatedClient(baseURL: baseURL, token: "t", transport: transport)

        try await client.deleteNote(id: 7)
        await #expect(throws: APIError.notFound) {
            try await client.deleteNote(id: 7)
        }

        let sent = await transport.sent[0]
        #expect(sent.request.method == .delete)
        #expect(sent.body == nil)
    }

    @Test
    func `me decodes the demo flag and the created date`() async throws {
        let body = #"{"id":2,"email":"a@b.c","createdAt":1786414481469,"themeMode":"light","locale":"en-GB","demo":true}"#
        let client = AuthenticatedClient(baseURL: baseURL, token: "t", transport: StubTransport(.response(status: 200, body: body)))

        let user = try await client.me()

        #expect(user.demo)
        #expect(user.createdAt == Date(timeIntervalSince1970: 1_786_414_481.469))
    }
}

extension JSONDecoder {
    static var api: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
}
