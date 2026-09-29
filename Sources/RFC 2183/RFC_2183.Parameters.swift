public import RFC_5322

extension RFC_2183 {

    public struct Parameters: Hashable, Sendable {

        public var filename: Filename?

        public var creationDate: RFC_5322.DateTime?

        public var modificationDate: RFC_5322.DateTime?

        public var readDate: RFC_5322.DateTime?

        public var size: Size?

        public var name: String?

        public var extensionParameters: [ParameterName: String]

        public init(
            filename: Filename? = nil,
            creationDate: RFC_5322.DateTime? = nil,
            modificationDate: RFC_5322.DateTime? = nil,
            readDate: RFC_5322.DateTime? = nil,
            size: Size? = nil,
            name: String? = nil,
            extensionParameters: [ParameterName: String] = [:]
        ) {
            self.filename = filename
            self.creationDate = creationDate
            self.modificationDate = modificationDate
            self.readDate = readDate
            self.size = size
            self.name = name
            self.extensionParameters = extensionParameters
        }
    }
}
