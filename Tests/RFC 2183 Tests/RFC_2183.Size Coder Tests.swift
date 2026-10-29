#if Coder
    import RFC_2183
    import Byte
    import Coder
    import Cursor
    import Testing

    @Suite
    struct `RFC_2183.Size Coder Tests` {

        @Test
        func `a size renders as decimal octets`() throws {
            let size = try RFC_2183.Size(bytes: 524_288)

            #expect(size.description == "524288")
            #expect(size.rawValue == "524288")
            var bytes: [Byte] = []
            try RFC_2183.Size.coder.serialize(size, into: &bytes)
            #expect(bytes == "524288")
        }

        @Test
        func `a size reads back from its raw text`() throws {
            #expect(RFC_2183.Size(rawValue: "1024") == (try RFC_2183.Size(bytes: 1024)))
            #expect(RFC_2183.Size(rawValue: "-1") == nil)
            #expect(RFC_2183.Size(rawValue: "many") == nil)
        }

        @Test
        func `the coder stops at the first non-digit`() throws {
            var input: ArraySlice<Byte> = "42; name=\"x\""

            #expect(try RFC_2183.Size.coder.parse(&input).bytes == 42)
            #expect(input == "; name=\"x\"")
        }
    }
#endif
