public import RFC_2045

extension RFC_2183 {

    public typealias ParameterName = RFC_2045.Parameter.Name
}

extension RFC_2045.Parameter.Name {

    public static let filename = Self(rawValue: "filename")

    public static let creationDate = Self(rawValue: "creation-date")

    public static let modificationDate = Self(rawValue: "modification-date")

    public static let readDate = Self(rawValue: "read-date")

    public static let size = Self(rawValue: "size")

    public static let name = Self(rawValue: "name")
}
