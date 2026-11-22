#if Coder
    import Binary
    public import RFC_5322

    extension IETF.RFC.`5322`.Header {

        public init(
            _ contentDisposition: IETF.RFC.`2183`.ContentDisposition
        ) throws(IETF.RFC.`5322`.Header.Value.Error) {
            try self.init(
                name: .contentDisposition,
                value: IETF.RFC.`5322`.Header.Value(String(contentDisposition))
            )
        }
    }
#endif
