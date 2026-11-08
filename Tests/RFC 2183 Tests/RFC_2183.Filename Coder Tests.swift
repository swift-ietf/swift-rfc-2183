#if Coder
    import RFC_2183
    import Byte
    import Coder
    import Cursor
    import Testing

    @Suite
    struct `RFC_2183.Filename Coder Tests` {

        @Test
        func `the coder stops at the semicolon and leaves the rest`() throws {
            var input: ArraySlice<Byte> = "report.pdf; size=1024"

            let filename = try RFC_2183.Filename.coder.parse(&input)

            #expect(filename.rawValue == "report.pdf")
            #expect(input == "; size=1024")
        }

        @Test
        func `the coder stops at the line break`() throws {
            var input: ArraySlice<Byte> = "photo.jpg\r\nContent-Type: image/jpeg"

            #expect(try RFC_2183.Filename.coder.parse(&input).rawValue == "photo.jpg")
            #expect(input == "\r\nContent-Type: image/jpeg")
        }

        @Test
        func `an unsafe filename restores the cursor`() {
            var input: ArraySlice<Byte> = "../etc/passwd; size=1"

            #expect(throws: RFC_2183.Filename.Error.containsPathTraversal("../etc/passwd")) {
                try RFC_2183.Filename.coder.parse(&input)
            }
            #expect(input == "../etc/passwd; size=1")
        }

        @Test
        func `an empty filename restores the cursor`() {
            var input: ArraySlice<Byte> = "; size=1"

            #expect(throws: RFC_2183.Filename.Error.empty) {
                try RFC_2183.Filename.coder.parse(&input)
            }
            #expect(input == "; size=1")
        }

        @Test
        func `a filename round-trips through its encoded form`() throws {
            let filename = try RFC_2183.Filename("my document.pdf")

            var bytes: [Byte] = []
            try RFC_2183.Filename.coder.serialize(filename, into: &bytes)
            var encoded = bytes[...]

            #expect(encoded == "my document.pdf")
            #expect(try RFC_2183.Filename.coder.parse(&encoded) == filename)
            #expect(encoded.isEmpty)
        }
    }
#endif
