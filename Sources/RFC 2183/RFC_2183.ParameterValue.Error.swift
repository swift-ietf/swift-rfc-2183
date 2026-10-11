public import ASCII

extension RFC_2183.ParameterValue {

    public enum Error: Swift.Error, Sendable, Equatable {

        case notASCII(String)

        case containsControlCharacters(String, byte: ASCII.Code)
    }
}
