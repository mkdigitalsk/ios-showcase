import Foundation
import SafeDecoding
import Testing

private enum Colour: String, Decodable, Sendable {
    case red, green
}

private struct Payload: Decodable {
    @LossyArray var colours: [Colour]
    @LossyEnum var favourite: Colour?
}

struct LossyDecodingTests {
    @Test
    func `an unknown element is dropped and an unknown case is nil`() throws {
        let data = Data(#"{"colours":["red","blue","green"],"favourite":"blue"}"#.utf8)

        let payload = try JSONDecoder().decode(Payload.self, from: data)

        #expect(payload.colours == [.red, .green])
        #expect(payload.favourite == nil)
    }

    @Test
    func `a missing key is empty or nil`() throws {
        let payload = try JSONDecoder().decode(Payload.self, from: Data("{}".utf8))

        #expect(payload.colours.isEmpty)
        #expect(payload.favourite == nil)
    }
}
