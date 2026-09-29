public import RFC_2183

extension RFC_2183.Size: Encodable, Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        try self.init(bytes: value)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(bytes)
    }
}
