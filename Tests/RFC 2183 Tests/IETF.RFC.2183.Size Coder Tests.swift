#if Coder
    import RFC_2183
    import Byte
    import Coder
    import Cursor
    import Testing

    @Suite
    struct `IETF.RFC.2183.Size Coder Tests` {

        @Test
        func `a size renders as decimal octets`() throws {
            let size = try IETF.RFC.`2183`.Size(bytes: 524_288)

            #expect(size.description == "524288")
            #expect(size.rawValue == "524288")
            var bytes: [Byte] = []
            try IETF.RFC.`2183`.Size.coder.serialize(size, into: &bytes)
            #expect(bytes == "524288")
        }

        @Test
        func `a size reads back from its raw text`() throws {
            #expect(IETF.RFC.`2183`.Size(rawValue: "1024") == (try IETF.RFC.`2183`.Size(bytes: 1024)))
            #expect(IETF.RFC.`2183`.Size(rawValue: "-1") == nil)
            #expect(IETF.RFC.`2183`.Size(rawValue: "many") == nil)
        }

        @Test
        func `the coder stops at the first non-digit`() throws {
            var input: ArraySlice<Byte> = "42; name=\"x\""

            #expect(try IETF.RFC.`2183`.Size.coder.parse(&input).bytes == 42)
            #expect(input == "; name=\"x\"")
        }
    }
#endif
