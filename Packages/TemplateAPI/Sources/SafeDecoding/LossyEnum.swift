/// A raw-value enum that decodes an unknown case as `nil` instead of failing the whole payload.
@propertyWrapper
public struct LossyEnum<Value: RawRepresentable & Sendable>: Decodable, Sendable
    where Value.RawValue: Decodable & Sendable
{
    public var wrappedValue: Value?

    public init() {
        wrappedValue = nil
    }

    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try Value(rawValue: container.decode(Value.RawValue.self))
    }
}

public extension KeyedDecodingContainer {
    /// A missing key decodes as `nil`.
    func decode<Value: RawRepresentable & Sendable>(_ type: LossyEnum<Value>.Type, forKey key: Key) throws -> LossyEnum<Value>
        where Value.RawValue: Decodable & Sendable
    {
        try decodeIfPresent(type, forKey: key) ?? LossyEnum()
    }
}
