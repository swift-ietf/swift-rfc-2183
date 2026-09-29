public import RFC_2183
import RFC_5322
import RFC_5322_Foundation_Integration

extension RFC_2183.Parameters: Encodable, Decodable {

    private enum CodingKeys: String, CodingKey {
        case filename
        case creationDate = "creation-date"
        case modificationDate = "modification-date"
        case readDate = "read-date"
        case size
        case name
        case extensionParameters = "extension-parameters"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var extensionParameters: [RFC_2183.ParameterName: String] = [:]
        let raw = try container.decodeIfPresent([String: String].self, forKey: .extensionParameters)
        for (key, value) in raw ?? [:] {
            extensionParameters[try RFC_2183.ParameterName(key)] = value
        }

        self.init(
            filename: try container.decodeIfPresent(RFC_2183.Filename.self, forKey: .filename),
            creationDate: try container.decodeIfPresent(
                RFC_5322.DateTime.self,
                forKey: .creationDate
            ),
            modificationDate: try container.decodeIfPresent(
                RFC_5322.DateTime.self,
                forKey: .modificationDate
            ),
            readDate: try container.decodeIfPresent(RFC_5322.DateTime.self, forKey: .readDate),
            size: try container.decodeIfPresent(RFC_2183.Size.self, forKey: .size),
            name: try container.decodeIfPresent(String.self, forKey: .name),
            extensionParameters: extensionParameters
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(filename, forKey: .filename)
        try container.encodeIfPresent(creationDate, forKey: .creationDate)
        try container.encodeIfPresent(modificationDate, forKey: .modificationDate)
        try container.encodeIfPresent(readDate, forKey: .readDate)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(name, forKey: .name)

        if !extensionParameters.isEmpty {
            var raw: [String: String] = [:]
            for (key, value) in extensionParameters {
                raw[key.rawValue] = value
            }
            try container.encode(raw, forKey: .extensionParameters)
        }
    }
}
