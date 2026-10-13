public import Byte
import ASCII

extension RFC_2183 {

    public struct ParameterValue: Hashable, Sendable {

        public let rawValue: String

        public init(
            __unchecked: (),
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_2183.ParameterValue {

    public var value: String { rawValue }
}

extension RFC_2183.ParameterValue: Swift::RawRepresentable {

    public init?(rawValue: String) {
        do throws(RFC_2183.ParameterValue.Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }
}

extension RFC_2183.ParameterValue: CustomStringConvertible {

    public var description: String { rawValue }
}

extension RFC_2183.ParameterValue {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift::Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        for byte in bytes {

            let code: ASCII.Code
            do throws(ASCII.Code.Error) {
                code = try ASCII.Code(byte)
            } catch {
                throw Error.notASCII(String(decoding: bytes, as: UTF8.self))
            }
            guard code.isVisible || code == ASCII.Code.space else {
                throw Error.containsControlCharacters(
                    String(decoding: bytes, as: UTF8.self),
                    byte: code
                )
            }
        }

        self.init(__unchecked: (), rawValue: String(decoding: bytes, as: UTF8.self))
    }
}
