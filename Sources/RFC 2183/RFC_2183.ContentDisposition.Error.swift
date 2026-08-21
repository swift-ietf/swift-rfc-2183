extension RFC_2183.ContentDisposition {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidFormat(String)

        case emptyDispositionType

        case emptyParameterKey

        case emptyParameterValue(key: String)

        case invalidParameter(key: String, value: String, reason: String)
    }
}
