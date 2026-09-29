public import Byte
import ASCII
import Byte

extension RFC_2183 {

    public struct Filename: Hashable, Sendable {

        public let rawValue: String

        public init(
            __unchecked: (),
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_2183.Filename {

    public var value: String { rawValue }
}

extension RFC_2183.Filename: Swift.RawRepresentable {

    public init?(rawValue: String) {
        do throws(RFC_2183.Filename.Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }
}

extension RFC_2183.Filename: CustomStringConvertible {

    public var description: String { rawValue }
}

extension RFC_2183.Filename {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        guard !bytes.isEmpty else {
            throw Error.empty
        }

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

        let value = String(decoding: bytes, as: UTF8.self)

        guard !value.contains("..") else {
            throw Error.containsPathTraversal(value)
        }

        guard !value.contains("/"), !value.contains("\\") else {
            throw Error.containsPathSeparator(value)
        }

        guard !value.hasPrefix("/"), !value.hasPrefix("\\") else {
            throw Error.isAbsolutePath(value)
        }

        self.init(__unchecked: (), rawValue: value)
    }
}
