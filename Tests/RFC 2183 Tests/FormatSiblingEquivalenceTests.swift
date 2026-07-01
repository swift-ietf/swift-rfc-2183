import Testing

@testable import RFC_2045
@testable import RFC_2183

/// [FAM-012] per-sibling equivalence: for each dual (`ASCII.Serializable` +
/// `Binary.Serializable`) conformer in the Content-Disposition connected
/// component, the two INDEPENDENT verb bodies must agree byte-for-byte —
/// `asciiCodes.map(\.byte) == bytes`. Content-Disposition and all its drained
/// sub-parts are ASCII text, so the ASCII and Byte forms are byte-equal; this
/// test is what guards the duplicated bodies against drift.
@Suite
struct `Format Sibling Equivalence Tests` {

    /// A representative header exercising every parameter branch: an
    /// escaped-quote filename, a date (composes `RFC_5322.DateTime`), an
    /// unquoted size (composes `RFC_2183.Size`), an RFC 7578 name, and an
    /// extension parameter.
    private func makeDisposition() throws -> RFC_2183.ContentDisposition {
        try RFC_2183.ContentDisposition(
            #"attachment; filename="my\"file\".txt"; creation-date="Mon, 01 Jan 2024 12:00:00 +0000"; size=2048; name="field"; x-custom="val""#
        )
    }

    @Test
    func `ContentDisposition ASCII verb equals Binary verb`() throws {
        let disposition = try makeDisposition()
        #expect(disposition.asciiCodes.map(\.byte) == disposition.bytes)
    }

    @Test
    func `DispositionType ASCII verb equals Binary verb`() throws {
        let type = try makeDisposition().type
        #expect(type.asciiCodes.map(\.byte) == type.bytes)
    }

    @Test
    func `Parameters ASCII verb equals Binary verb`() throws {
        let parameters = try makeDisposition().parameters
        // Sanity: every branch is populated so both bodies are exercised.
        #expect(parameters.filename != nil)
        #expect(parameters.creationDate != nil)
        #expect(parameters.size != nil)
        #expect(parameters.name != nil)
        #expect(!parameters.extensionParameters.isEmpty)
        #expect(parameters.asciiCodes.map(\.byte) == parameters.bytes)
    }

    @Test
    func `Filename ASCII verb equals Binary verb (with quotes)`() throws {
        let filename = try RFC_2183.Filename(#"my"file".txt"#)
        #expect(filename.asciiCodes.map(\.byte) == filename.bytes)
    }

    @Test
    func `Size ASCII verb equals Binary verb`() throws {
        let size = try RFC_2183.Size(bytes: 1_048_576)
        #expect(size.asciiCodes.map(\.byte) == size.bytes)
    }
}
