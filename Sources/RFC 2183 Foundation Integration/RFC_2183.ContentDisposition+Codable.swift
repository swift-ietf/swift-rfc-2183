public import RFC_2183

extension RFC_2183.ContentDisposition: Encodable, Decodable {

    private enum CodingKeys: String, CodingKey {
        case type
        case parameters
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            type: try container.decode(RFC_2183.DispositionType.self, forKey: .type),
            parameters: try container.decodeIfPresent(
                RFC_2183.Parameters.self,
                forKey: .parameters
            ) ?? RFC_2183.Parameters()
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(parameters, forKey: .parameters)
    }
}
