extension RFC_2183.Size {

    public enum Error: Swift.Error, Sendable, Equatable {

        case negative(Int)

        case invalidFormat(String)
    }
}
