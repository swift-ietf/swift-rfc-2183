#if Coder
    import Byte
    import Coder
    import Cursor
    import Testing

    @Suite
    struct `RFC_2183.ParameterName Coder Tests` {

        @Test
        func `the coder stops before the equals sign`() throws {
            var input: ArraySlice<Byte> = "filename=\"a.txt\""

            #expect(try RFC_2183.ParameterName.coder.parse(&input) == .filename)
            #expect(input == "=\"a.txt\"")
        }

        @Test
        func `a parameter name compares without regard to case`() throws {
            var input: ArraySlice<Byte> = "Creation-Date="

            let name = try RFC_2183.ParameterName.coder.parse(&input)

            #expect(name == .creationDate)
            #expect(name.rawValue == "Creation-Date")
        }

        @Test
        func `a missing name restores the cursor`() {
            var input: ArraySlice<Byte> = "=value"

            #expect(throws: RFC_2183.ParameterName.Error.empty) {
                try RFC_2183.ParameterName.coder.parse(&input)
            }
            #expect(input == "=value")
        }

        @Test
        func `a parameter name round-trips through its encoded form`() throws {
            let name = try RFC_2183.ParameterName("x-token")

            var bytes: [Byte] = []
            try RFC_2183.ParameterName.coder.serialize(name, into: &bytes)
            var encoded = bytes[...]

            #expect(encoded == "x-token")
            #expect(try RFC_2183.ParameterName.coder.parse(&encoded) == name)
            #expect(encoded.isEmpty)
        }
    }
#endif
