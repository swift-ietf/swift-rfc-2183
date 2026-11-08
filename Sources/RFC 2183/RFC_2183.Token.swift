import ASCII
import Byte

extension RFC_2183 {
    enum Token {
    }
}

extension RFC_2183.Token {

    static func validate<Bytes: Swift::Collection>(_ bytes: Bytes) -> Failure?
    where Bytes.Element == Byte {
        guard !bytes.isEmpty else {
            return .empty
        }

        for byte in bytes {
            let code: ASCII.Code
            do throws(ASCII.Code.Error) {
                code = try ASCII.Code(byte)
            } catch {
                return .notASCII
            }

            guard code.isVisible, !specials.contains(code) else {
                return .invalidCharacter(code)
            }
        }

        return nil
    }

    static let specials: [ASCII.Code] = [
        .leftParenthesis,
        .rightParenthesis,
        .lessThanSign,
        .greaterThanSign,
        .atSign,
        .comma,
        .semicolon,
        .colon,
        .backslash,
        .quotationMark,
        .solidus,
        .leftSquareBracket,
        .rightSquareBracket,
        .questionMark,
        .equalsSign,
    ]
}
