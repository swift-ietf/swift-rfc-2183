import ASCII
import Byte
import Byte
import RFC_2183
import Testing

@Suite
struct `RFC_2183.DispositionType Tests` {

    @Test
    func `a disposition type compares without regard to case`() throws {
        let type = try RFC_2183.DispositionType("INLINE")

        #expect(type == .inline)
        #expect(type.description == "INLINE")
        #expect(RFC_2183.DispositionType(rawValue: "X-Custom")?.rawValue == "X-Custom")
        #expect(RFC_2183.DispositionType(rawValue: "x custom") == nil)
    }

    @Test
    func `a token validates from text and from bytes`() throws {
        #expect(try RFC_2183.DispositionType("Attachment") == .attachment)
        #expect(try RFC_2183.DispositionType(ascii: [Byte](utf8: "form-data")) == .formData)
    }

    @Test
    func `an empty type is refused`() {
        #expect(throws: RFC_2183.DispositionType.Error.empty) {
            try RFC_2183.DispositionType("")
        }
    }

    @Test
    func `a type containing a special or a space is refused`() {
        #expect(
            throws: RFC_2183.DispositionType.Error.invalidCharacter("in line", code: .space)
        ) {
            try RFC_2183.DispositionType("in line")
        }
        #expect(
            throws: RFC_2183.DispositionType.Error.invalidCharacter("a;b", code: .semicolon)
        ) {
            try RFC_2183.DispositionType("a;b")
        }
    }

    @Test
    func `a parameter name is a token too`() throws {
        #expect(try RFC_2183.ParameterName("Creation-Date") == .creationDate)
        #expect(throws: RFC_2183.ParameterName.Error.invalidCharacter("a=b", code: .equalsSign)) {
            try RFC_2183.ParameterName("a=b")
        }
    }
}
