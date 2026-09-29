import Byte
import Byte
import RFC_2183
import RFC_5322
import Testing

@Suite
struct `RFC_2183.ContentDisposition Tests` {

    @Test
    func `an inline disposition carries no parameters`() {
        let disposition = RFC_2183.ContentDisposition.inline()

        #expect(disposition.type == .inline)
        #expect(disposition.filename == nil)
        #expect(disposition.parameters == RFC_2183.Parameters())
    }

    @Test
    func `the attachment factory agrees with the grammar`() throws {
        #expect(
            try RFC_2183.ContentDisposition(#"attachment; filename="report.pdf"; size=1048576"#)
                == .attachment(
                    filename: try RFC_2183.Filename("report.pdf"),
                    size: try RFC_2183.Size(bytes: 1_048_576)
                )
        )
    }

    @Test
    func `the form-data factory agrees with the grammar`() throws {
        #expect(
            try RFC_2183.ContentDisposition(#"form-data; name="avatar"; filename="photo.jpg""#)
                == .formData(
                    name: "avatar",
                    filename: try RFC_2183.Filename("photo.jpg")
                )
        )
    }

    @Test
    func `dates and extension parameters travel on the parameters`() throws {
        let date = try RFC_5322.DateTime("Mon, 1 Jan 2024 12:00:00 +0000")
        let disposition = RFC_2183.ContentDisposition(
            type: .attachment,
            parameters: .init(
                creationDate: date,
                extensionParameters: [try RFC_2183.ParameterName("x-token"): "abc"]
            )
        )

        #expect(disposition.creationDate == date)
        #expect(
            disposition.parameters.extensionParameters[
                try RFC_2183.ParameterName("X-Token")
            ] == "abc"
        )
    }

    @Test
    func `the Content-Disposition field name is spelled once`() {
        #expect(RFC_5322.Header.Name.contentDisposition.rawValue == "Content-Disposition")
    }
}

@Suite
struct `RFC_2183.ContentDisposition from text` {

    @Test
    func `reads a bare disposition type`() throws {
        let disposition = try RFC_2183.ContentDisposition("inline")

        #expect(disposition.type == .inline)
        #expect(disposition.parameters == RFC_2183.Parameters())
    }

    @Test
    func `reads a quoted filename and a size`() throws {
        let disposition = try RFC_2183.ContentDisposition(
            #"attachment; filename="report.pdf"; size=1024"#
        )

        #expect(disposition.type == .attachment)
        #expect(disposition.filename?.value == "report.pdf")
        #expect(disposition.size?.bytes == 1024)
    }

    @Test
    func `reads over bytes`() throws {
        let disposition = try RFC_2183.ContentDisposition(
            ascii: [Byte](utf8: #"form-data; name="avatar"; filename="photo.jpg""#)
        )

        #expect(disposition.type == .formData)
        #expect(disposition.name == "avatar")
        #expect(disposition.filename?.value == "photo.jpg")
    }

    @Test
    func `folds the case of the type and parameter names`() throws {
        let disposition = try RFC_2183.ContentDisposition(#"ATTACHMENT; FILENAME="a.txt""#)

        #expect(disposition.type == .attachment)
        #expect(disposition.filename?.value == "a.txt")
    }

    @Test
    func `a semicolon inside a quoted value does not split the parameter`() throws {
        let disposition = try RFC_2183.ContentDisposition(#"attachment; filename="a;b.txt""#)

        #expect(disposition.filename?.value == "a;b.txt")
    }

    @Test
    func `an escaped quote inside a quoted value is unescaped`() throws {
        let disposition = try RFC_2183.ContentDisposition(
            #"attachment; filename="file\"with\"quotes.txt""#
        )

        #expect(disposition.filename?.value == #"file"with"quotes.txt"#)
    }

    @Test
    func `reads the RFC 5322 dates`() throws {
        let disposition = try RFC_2183.ContentDisposition(
            #"attachment; creation-date="Wed, 12 Feb 1997 16:29:51 -0500""#
        )

        #expect(disposition.creationDate == (try RFC_5322.DateTime("Wed, 12 Feb 1997 16:29:51 -0500")))
    }

    @Test
    func `unknown parameters land in the extension parameters`() throws {
        let disposition = try RFC_2183.ContentDisposition("inline; x-token=abc")

        #expect(disposition.parameters.extensionParameters[try RFC_2183.ParameterName("x-token")] == "abc")
    }

    @Test
    func `an unsafe filename is dropped rather than accepted`() throws {
        let disposition = try RFC_2183.ContentDisposition(#"attachment; filename="../etc/passwd""#)

        #expect(disposition.filename == nil)
    }

    @Test
    func `an empty disposition type is refused`() {
        #expect(throws: RFC_2183.ContentDisposition.Error.emptyDispositionType) {
            try RFC_2183.ContentDisposition(#"; filename="x.txt""#)
        }
    }

    @Test
    func `a disposition type that is not a token is refused`() {
        #expect(throws: RFC_2183.ContentDisposition.Error.invalidFormat(#"in line; filename="x.txt""#)) {
            try RFC_2183.ContentDisposition(#"in line; filename="x.txt""#)
        }
    }

    @Test
    func `a parameter whose name is not a token is skipped`() throws {
        let disposition = try RFC_2183.ContentDisposition("inline; x token=abc; x-token=def")

        #expect(disposition.parameters.extensionParameters.count == 1)
        #expect(disposition.parameters.extensionParameters[try RFC_2183.ParameterName("x-token")] == "def")
    }

    @Test
    func `non-ASCII input is refused`() {
        #expect(throws: RFC_2183.ContentDisposition.Error.invalidFormat("attachment; filename=\"é.txt\"")) {
            try RFC_2183.ContentDisposition("attachment; filename=\"é.txt\"")
        }
    }
}
