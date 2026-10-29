#if Coder
    import Byte
    import Coder
    import Cursor
    import Testing

    @Suite
    struct `RFC_2183.ContentDisposition Coder Tests` {

        @Test
        func `parses an attachment with a quoted filename`() throws {
            var input: ArraySlice<Byte> = "attachment; filename=\"document.pdf\""

            let disposition = try RFC_2183.ContentDisposition.coder.parse(&input)

            #expect(disposition.type == .attachment)
            #expect(disposition.filename?.value == "document.pdf")
        }

        @Test
        func `stops at the line break`() throws {
            var input: ArraySlice<Byte> = "inline\r\nContent-Type: text/plain"

            let disposition = try RFC_2183.ContentDisposition.coder.parse(&input)

            #expect(disposition.type == .inline)
            #expect(input == "\r\nContent-Type: text/plain")
        }

        @Test
        func `a semicolon inside a quoted value does not split the parameter`() throws {
            var input: ArraySlice<Byte> = "attachment; filename=\"a;b.txt\""

            let disposition = try RFC_2183.ContentDisposition.coder.parse(&input)

            #expect(disposition.filename?.value == "a;b.txt")
        }

        @Test
        func `an escaped quote survives the round trip`() throws {
            let disposition = RFC_2183.ContentDisposition(
                type: .attachment,
                parameters: .init(filename: try RFC_2183.Filename(#"file"with"quotes.txt"#))
            )

            var bytes: [Byte] = []
            try RFC_2183.ContentDisposition.coder.serialize(disposition, into: &bytes)
            #expect(
                bytes
                    == #"attachment; filename="file\"with\"quotes.txt""#
            )
            #expect(try RFC_2183.ContentDisposition(ascii: bytes) == disposition)
        }

        @Test
        func `RFC 2183 §2, RFC 2045 §5.1 and RFC 822 §3.3: a backslash in a quoted value is written as a quoted-pair`() throws {
            let disposition = RFC_2183.ContentDisposition(
                type: .formData,
                parameters: .init(name: try RFC_2183.ParameterValue(#"a\b"#))
            )

            var bytes: [Byte] = []
            try RFC_2183.ContentDisposition.coder.serialize(disposition, into: &bytes)
            #expect(bytes == #"form-data; name="a\\b""#)
            #expect(try RFC_2183.ContentDisposition(ascii: bytes) == disposition)
        }

        @Test
        func `form data renders its field name and filename`() throws {
            let disposition = RFC_2183.ContentDisposition.formData(
                name: try RFC_2183.ParameterValue("avatar"),
                filename: try RFC_2183.Filename("photo.jpg")
            )

            #expect(
                disposition.description
                    == #"form-data; filename="photo.jpg"; name="avatar""#
            )
        }

        @Test
        func `an empty disposition type is refused`() {
            var input: ArraySlice<Byte> = "; filename=\"x.txt\""

            #expect(throws: RFC_2183.ContentDisposition.Error.emptyDispositionType) {
                try RFC_2183.ContentDisposition.coder.parse(&input)
            }
        }
    }
#endif
