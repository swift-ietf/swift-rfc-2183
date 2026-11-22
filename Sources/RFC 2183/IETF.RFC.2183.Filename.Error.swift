public import ASCII

extension IETF.RFC.`2183`.Filename {

    public enum Error: Swift::Error, Sendable, Equatable {

        case empty

        case notASCII(String)

        case containsControlCharacters(String, byte: ASCII.Code)

        case containsPathTraversal(String)

        case containsPathSeparator(String)

        case isAbsolutePath(String)
    }
}
