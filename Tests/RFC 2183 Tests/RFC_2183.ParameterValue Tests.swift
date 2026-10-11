import ASCII
import Byte
import RFC_2183
import Testing

@Suite
struct `RFC_2183.ParameterValue Tests` {

    @Test
    func `a printable value validates`() throws {
        let value = try RFC_2183.ParameterValue(#"a "quoted" \ value; with=specials"#)

        #expect(value.rawValue == #"a "quoted" \ value; with=specials"#)
        #expect(value.value == #"a "quoted" \ value; with=specials"#)
    }

    @Test
    func `RFC 2045 §5.1: an empty quoted-string is a value`() throws {
        #expect(try RFC_2183.ParameterValue("").rawValue == "")
    }

    @Test
    func `a value validates over bytes`() throws {
        let value = try RFC_2183.ParameterValue(ascii: [Byte](utf8: "avatar"))

        #expect(value == RFC_2183.ParameterValue(rawValue: "avatar"))
    }

    @Test
    func `RFC 2183 §2 and RFC 2045 §5.1: CR is refused`() {
        #expect(throws: RFC_2183.ParameterValue.Error.containsControlCharacters("a\rb", byte: 0x0D)) {
            try RFC_2183.ParameterValue("a\rb")
        }
    }

    @Test
    func `RFC 2183 §2 and RFC 2045 §5.1: LF is refused`() {
        #expect(throws: RFC_2183.ParameterValue.Error.containsControlCharacters("a\nb", byte: 0x0A)) {
            try RFC_2183.ParameterValue("a\nb")
        }
    }

    @Test
    func `RFC 2183 §2 and RFC 2045 §5.1: other control bytes are refused`() {
        #expect(throws: RFC_2183.ParameterValue.Error.self) {
            try RFC_2183.ParameterValue("a\u{0}b")
        }
        #expect(throws: RFC_2183.ParameterValue.Error.self) {
            try RFC_2183.ParameterValue("a\tb")
        }
        #expect(throws: RFC_2183.ParameterValue.Error.self) {
            try RFC_2183.ParameterValue("a\u{7F}b")
        }
        #expect(RFC_2183.ParameterValue(rawValue: "a\u{1B}b") == nil)
    }

    @Test
    func `RFC 2183 §2: a value outside US-ASCII is refused`() {
        #expect(throws: RFC_2183.ParameterValue.Error.notASCII("é")) {
            try RFC_2183.ParameterValue("é")
        }
    }
}
