import ASCII
import Byte
import RFC_2183
import Testing

@Suite
struct `IETF.RFC.2183.DispositionType Tests` {

    @Test
    func `a disposition type compares without regard to case`() throws {
        let type = try IETF.RFC.`2183`.DispositionType("INLINE")

        #expect(type == .inline)
        #expect(type.description == "INLINE")
        #expect(IETF.RFC.`2183`.DispositionType(rawValue: "X-Custom")?.rawValue == "X-Custom")
        #expect(IETF.RFC.`2183`.DispositionType(rawValue: "x custom") == nil)
    }

    @Test
    func `a token validates from text and from bytes`() throws {
        #expect(try IETF.RFC.`2183`.DispositionType("Attachment") == .attachment)
        #expect(try IETF.RFC.`2183`.DispositionType(ascii: [Byte](utf8: "form-data")) == .formData)
    }

    @Test
    func `an empty type is refused`() {
        #expect(throws: IETF.RFC.`2183`.DispositionType.Error.empty) {
            try IETF.RFC.`2183`.DispositionType("")
        }
    }

    @Test
    func `a type containing a special or a space is refused`() {
        #expect(
            throws: IETF.RFC.`2183`.DispositionType.Error.invalidCharacter("in line", code: .space)
        ) {
            try IETF.RFC.`2183`.DispositionType("in line")
        }
        #expect(
            throws: IETF.RFC.`2183`.DispositionType.Error.invalidCharacter("a;b", code: .semicolon)
        ) {
            try IETF.RFC.`2183`.DispositionType("a;b")
        }
    }

    @Test
    func `a parameter name is a token too`() throws {
        #expect(try IETF.RFC.`2183`.ParameterName("Creation-Date") == .creationDate)
        #expect(throws: IETF.RFC.`2183`.ParameterName.Error.invalidCharacter("a=b", code: .equalsSign)) {
            try IETF.RFC.`2183`.ParameterName("a=b")
        }
    }
}
