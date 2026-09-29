public import Byte
public import RFC_5322
import ASCII
import Byte

extension RFC_2183 {

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

extension RFC_2183.ContentDisposition {

    public var filename: RFC_2183.Filename? {
        parameters.filename
    }

    public var creationDate: RFC_5322.DateTime? {
        parameters.creationDate
    }

    public var modificationDate: RFC_5322.DateTime? {
        parameters.modificationDate
    }

    public var readDate: RFC_5322.DateTime? {
        parameters.readDate
    }

    public var size: RFC_2183.Size? {
        parameters.size
    }

    public var name: String? {
        parameters.name
    }
}

extension RFC_2183.ContentDisposition {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        for byte in bytes {
            do throws(ASCII.Code.Error) {
                _ = try ASCII.Code(byte)
            } catch {
                throw Error.invalidFormat(String(decoding: bytes, as: UTF8.self))
            }
        }

        let segments = Fields.segments(String(decoding: bytes, as: UTF8.self))

        let type: RFC_2183.DispositionType
        do throws(RFC_2183.DispositionType.Error) {
            type = try RFC_2183.DispositionType(Fields.trimmed(segments[0]))
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

extension RFC_2183.ContentDisposition {

    public static func inline() -> Self {
        Self(type: .inline)
    }

    public static func attachment(
        filename: RFC_2183.Filename? = nil,
        size: RFC_2183.Size? = nil,
        creationDate: RFC_5322.DateTime? = nil,
        modificationDate: RFC_5322.DateTime? = nil,
        readDate: RFC_5322.DateTime? = nil
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

    public static func formData(name: String, filename: RFC_2183.Filename? = nil) -> Self {
        Self(
            type: .formData,
            parameters: .init(
                filename: filename,
                name: name
            )
        )
    }
}
