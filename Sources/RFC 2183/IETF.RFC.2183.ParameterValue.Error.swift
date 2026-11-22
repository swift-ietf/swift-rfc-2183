public import ASCII

extension IETF.RFC.`2183`.ParameterValue {

    public enum Error: Swift::Error, Sendable, Equatable {

        case notASCII(String)

        case containsControlCharacters(String, byte: ASCII.Code)
    }
}
