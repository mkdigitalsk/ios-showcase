/// An array that drops the elements that fail to decode instead of failing the whole payload.
@propertyWrapper
public struct LossyArray<Element: Decodable & Sendable>: Decodable, Sendable {
    public var wrappedValue: [Element]

    public init() {
        wrappedValue = []
    }

    public init(wrappedValue: [Element]) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode([LossyElement<Element>].self).compactMap(\.value)
    }
}

public extension KeyedDecodingContainer {
    /// A missing key decodes as an empty array.
    func decode<Element: Decodable & Sendable>(_ type: LossyArray<Element>.Type, forKey key: Key) throws -> LossyArray<Element> {
        try decodeIfPresent(type, forKey: key) ?? LossyArray()
    }
}

private struct LossyElement<Element: Decodable>: Decodable {
    let value: Element?

    init(from decoder: any Decoder) throws {
        value = try? Element(from: decoder)
    }
}
