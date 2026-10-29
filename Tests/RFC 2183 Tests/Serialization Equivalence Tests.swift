#if Coder
    import ASCII
    import Binary
    import Byte
    import RFC_5322
    import Testing

    @Suite
    struct `Serialization Equivalence` {

        @Test
        func `a content disposition serializes to the same octets through both verbs`() throws {
            let disposition = RFC_2183.ContentDisposition.attachment(
                filename: try RFC_2183.Filename("document.pdf")
            )

            var ascii: [ASCII.Code] = []
            RFC_2183.ContentDisposition.serialize(disposition, into: &ascii)

            #expect(
                ascii.map(\.byte) == [Byte](utf8: #"attachment; filename="document.pdf""#)
            )
            #expect([Byte](disposition) == [Byte](utf8: #"attachment; filename="document.pdf""#))
        }

        @Test
        func `the scalar parameters serialize to their raw text`() throws {
            #expect([Byte](RFC_2183.DispositionType.formData) == [Byte](utf8: "form-data"))
            #expect([Byte](try RFC_2183.Filename("photo.jpg")) == [Byte](utf8: "photo.jpg"))
            #expect([Byte](try RFC_2183.Size(bytes: 1024)) == [Byte](utf8: "1024"))
            #expect([Byte](RFC_2183.ParameterName.creationDate) == [Byte](utf8: "creation-date"))
        }

        @Test
        func `a Content-Disposition header carries the rendered field body`() throws {
            let header = try RFC_5322.Header(RFC_2183.ContentDisposition.inline())

            #expect(header.name == .contentDisposition)
            #expect(header.value.rawValue == "inline")
        }
    }
#endif
