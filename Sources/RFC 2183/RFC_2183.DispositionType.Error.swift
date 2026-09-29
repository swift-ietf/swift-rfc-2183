public import ASCII

extension RFC_2183.DispositionType {

    public enum Error: Swift.Error, Sendable, Equatable {

        case empty

        case notASCII(String)

        case invalidCharacter(String, code: ASCII.Code)
    }
}
