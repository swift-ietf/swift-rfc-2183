public import RFC_5322

extension RFC_5322.Header {

    public init(
        _ contentDisposition: RFC_2183.ContentDisposition
    ) throws(Value.Error) {
        try self.init(name: .contentDisposition, value: .init(String(contentDisposition)))
    }
}
