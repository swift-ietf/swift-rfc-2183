public import RFC_5322

extension IETF.RFC.`2183` {

    public struct Parameters: Hashable, Sendable {

        public var filename: Filename?

        public var creationDate: IETF.RFC.`5322`.DateTime?

        public var modificationDate: IETF.RFC.`5322`.DateTime?

        public var readDate: IETF.RFC.`5322`.DateTime?

        public var size: Size?

        public var name: ParameterValue?

        public var extensionParameters: [ParameterName: ParameterValue]

        public init(
            filename: Filename? = nil,
            creationDate: IETF.RFC.`5322`.DateTime? = nil,
            modificationDate: IETF.RFC.`5322`.DateTime? = nil,
            readDate: IETF.RFC.`5322`.DateTime? = nil,
            size: Size? = nil,
            name: ParameterValue? = nil,
            extensionParameters: [ParameterName: ParameterValue] = [:]
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
