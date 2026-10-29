#if Coder
    import Byte
    import Coder
    import Cursor
    import Testing

    @Suite
    struct `RFC_2183.DispositionType Coder Tests` {

        @Test
        func `the coder reads the token before the parameters`() throws {
            var input: ArraySlice<Byte> = "attachment; filename=\"a.txt\""

            #expect(try RFC_2183.DispositionType.coder.parse(&input) == .attachment)
            #expect(input == "; filename=\"a.txt\"")
        }

        @Test
        func `the coder stops at a space`() throws {
            var input: ArraySlice<Byte> = "inline text"

            #expect(try RFC_2183.DispositionType.coder.parse(&input) == .inline)
            #expect(input == " text")
        }

        @Test
        func `an extension token is accepted as written`() throws {
            var input: ArraySlice<Byte> = "X-Custom\r\n"

            #expect(try RFC_2183.DispositionType.coder.parse(&input).rawValue == "X-Custom")
            #expect(input == "\r\n")
        }

        @Test
        func `a missing token restores the cursor`() {
            var input: ArraySlice<Byte> = "; filename=\"a.txt\""

            #expect(throws: RFC_2183.DispositionType.Error.empty) {
                try RFC_2183.DispositionType.coder.parse(&input)
            }
            #expect(input == "; filename=\"a.txt\"")
        }

        @Test
        func `a disposition type round-trips through its encoded form`() throws {
            var bytes: [Byte] = []
            try RFC_2183.DispositionType.coder.serialize(RFC_2183.DispositionType.formData, into: &bytes)
            var encoded = bytes[...]

            #expect(encoded == "form-data")
            #expect(try RFC_2183.DispositionType.coder.parse(&encoded) == .formData)
            #expect(encoded.isEmpty)
        }
    }
#endif
