public import ASCII

extension IETF.RFC.`2183`.ParameterName {

    public enum Error: Swift::Error, Sendable, Equatable {

        case empty

        case notASCII(String)

        case invalidCharacter(String, code: ASCII.Code)
    }
}
