#if Coder
    import Binary
    public import RFC_5322

    extension RFC_5322.Header {

        public init(
            _ contentDisposition: RFC_2183.ContentDisposition
        ) throws(RFC_5322.Header.Value.Error) {
            try self.init(
                name: .contentDisposition,
                value: RFC_5322.Header.Value(String(contentDisposition))
            )
        }
    }
#endif
