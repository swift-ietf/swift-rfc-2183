public import Byte
import ASCII
import Byte

extension RFC_2183 {

    public struct Size: Hashable, Sendable, Comparable {

        public let bytes: Int

        init(__unchecked bytes: Int) {
            self.bytes = bytes
        }

        public init(bytes: Int) throws(Error) {
            guard bytes >= 0 else {
                throw Error.negative(bytes)
            }
            self.init(__unchecked: bytes)
        }
    }
}

extension RFC_2183.Size {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.bytes < rhs.bytes
    }
}

extension RFC_2183.Size {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        let string = String(decoding: bytes, as: UTF8.self)
        for byte in bytes {
            let code: ASCII.Code
            do throws(ASCII.Code.Error) {
                code = try ASCII.Code(byte)
            } catch {
                throw Error.invalidFormat(string)
            }
            guard code.isDigit else {
                throw Error.invalidFormat(string)
            }
        }
        guard let value = Int(string) else {
            throw Error.invalidFormat(string)
        }
        self.init(__unchecked: value)
    }
}
