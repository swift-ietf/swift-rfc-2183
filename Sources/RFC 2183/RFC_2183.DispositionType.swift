public import Byte
import Byte

extension RFC_2183 {

    public struct DispositionType: Sendable {

        public let rawValue: String

        public init(
            __unchecked: (),
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_2183.DispositionType: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    public static func == (lhs: RFC_2183.DispositionType, rhs: RFC_2183.DispositionType) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }
}

extension RFC_2183.DispositionType: Swift.RawRepresentable {

    public init?(rawValue: String) {
        do throws(Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }
}

extension RFC_2183.DispositionType: CustomStringConvertible {

    public var description: String {
        rawValue
    }
}

extension RFC_2183.DispositionType {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        switch RFC_2183.Token.validate(bytes) {
        case .none:
            self.init(__unchecked: (), rawValue: String(decoding: bytes, as: UTF8.self))
        case .some(.empty):
            throw Error.empty
        case .some(.notASCII):
            throw Error.notASCII(String(decoding: bytes, as: UTF8.self))
        case .some(.invalidCharacter(let code)):
            throw Error.invalidCharacter(String(decoding: bytes, as: UTF8.self), code: code)
        }
    }
}

extension RFC_2183.DispositionType {

    public static let inline: Self = .init(__unchecked: (), rawValue: "inline")

    public static let attachment: Self = .init(__unchecked: (), rawValue: "attachment")

    public static let formData: Self = .init(__unchecked: (), rawValue: "form-data")
}
