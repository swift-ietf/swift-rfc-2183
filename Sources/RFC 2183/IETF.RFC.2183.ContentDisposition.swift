import ASCII
public import Byte
public import RFC_5322

extension IETF.RFC.`2183` {

    public struct ContentDisposition: Hashable, Sendable {

        public let type: DispositionType

        public let parameters: Parameters

        public init(
            type: DispositionType,
            parameters: Parameters = Parameters()
        ) {
            self.type = type
            self.parameters = parameters
        }
    }
}

extension IETF.RFC.`2183`.ContentDisposition {

    public var filename: IETF.RFC.`2183`.Filename? {
        parameters.filename
    }

    public var creationDate: IETF.RFC.`5322`.DateTime? {
        parameters.creationDate
    }

    public var modificationDate: IETF.RFC.`5322`.DateTime? {
        parameters.modificationDate
    }

    public var readDate: IETF.RFC.`5322`.DateTime? {
        parameters.readDate
    }

    public var size: IETF.RFC.`2183`.Size? {
        parameters.size
    }

    public var name: IETF.RFC.`2183`.ParameterValue? {
        parameters.name
    }
}

extension IETF.RFC.`2183`.ContentDisposition {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift::Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        for byte in bytes {
            do throws(ASCII.Code.Error) {
                _ = try ASCII.Code(byte)
            } catch {
                throw Error.invalidFormat(String(decoding: bytes, as: UTF8.self))
            }
        }

        let segments = Fields.segments(String(decoding: bytes, as: UTF8.self))

        let type: IETF.RFC.`2183`.DispositionType
        do throws(IETF.RFC.`2183`.DispositionType.Error) {
            type = try IETF.RFC.`2183`.DispositionType(Fields.trimmed(segments[0]))
        } catch {
            switch error {
            case .empty:
                throw Error.emptyDispositionType
            case .notASCII, .invalidCharacter:
                throw Error.invalidFormat(String(decoding: bytes, as: UTF8.self))
            }
        }

        self.init(
            type: type,
            parameters: Fields.parameters(Fields.attributes(segments.dropFirst()))
        )
    }
}

extension IETF.RFC.`2183`.ContentDisposition {

    public static func inline() -> Self {
        Self(type: .inline)
    }

    public static func attachment(
        filename: IETF.RFC.`2183`.Filename? = nil,
        size: IETF.RFC.`2183`.Size? = nil,
        creationDate: IETF.RFC.`5322`.DateTime? = nil,
        modificationDate: IETF.RFC.`5322`.DateTime? = nil,
        readDate: IETF.RFC.`5322`.DateTime? = nil
    ) -> Self {
        Self(
            type: .attachment,
            parameters: .init(
                filename: filename,
                creationDate: creationDate,
                modificationDate: modificationDate,
                readDate: readDate,
                size: size
            )
        )
    }

    public static func formData(
        name: IETF.RFC.`2183`.ParameterValue,
        filename: IETF.RFC.`2183`.Filename? = nil
    ) -> Self {
        Self(
            type: .formData,
            parameters: .init(
                filename: filename,
                name: name
            )
        )
    }
}
