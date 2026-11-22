extension IETF.RFC.`2183`.ContentDisposition {

    public enum Error: Swift::Error, Sendable, Equatable {

        case invalidFormat(String)

        case emptyDispositionType
    }
}
