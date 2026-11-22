import ASCII
import Byte
import RFC_2183
import Testing

@Suite
struct `IETF.RFC.2183.ParameterValue Tests` {

    @Test
    func `a printable value validates`() throws {
        let value = try IETF.RFC.`2183`.ParameterValue(#"a "quoted" \ value; with=specials"#)

        #expect(value.rawValue == #"a "quoted" \ value; with=specials"#)
        #expect(value.value == #"a "quoted" \ value; with=specials"#)
    }

    @Test
    func `RFC 2045 §5.1: an empty quoted-string is a value`() throws {
        #expect(try IETF.RFC.`2183`.ParameterValue("").rawValue == "")
    }

    @Test
    func `a value validates over bytes`() throws {
        let value = try IETF.RFC.`2183`.ParameterValue(ascii: [Byte](utf8: "avatar"))

        #expect(value == IETF.RFC.`2183`.ParameterValue(rawValue: "avatar"))
    }

    @Test
    func `RFC 2183 §2 and RFC 2045 §5.1: CR is refused`() {
        #expect(throws: IETF.RFC.`2183`.ParameterValue.Error.containsControlCharacters("a\rb", byte: 0x0D)) {
            try IETF.RFC.`2183`.ParameterValue("a\rb")
        }
    }

    @Test
    func `RFC 2183 §2 and RFC 2045 §5.1: LF is refused`() {
        #expect(throws: IETF.RFC.`2183`.ParameterValue.Error.containsControlCharacters("a\nb", byte: 0x0A)) {
            try IETF.RFC.`2183`.ParameterValue("a\nb")
        }
    }

    @Test
    func `RFC 2183 §2 and RFC 2045 §5.1: other control bytes are refused`() {
        #expect(throws: IETF.RFC.`2183`.ParameterValue.Error.self) {
            try IETF.RFC.`2183`.ParameterValue("a\u{0}b")
        }
        #expect(throws: IETF.RFC.`2183`.ParameterValue.Error.self) {
            try IETF.RFC.`2183`.ParameterValue("a\tb")
        }
        #expect(throws: IETF.RFC.`2183`.ParameterValue.Error.self) {
            try IETF.RFC.`2183`.ParameterValue("a\u{7F}b")
        }
        #expect(IETF.RFC.`2183`.ParameterValue(rawValue: "a\u{1B}b") == nil)
    }

    @Test
    func `RFC 2183 §2: a value outside US-ASCII is refused`() {
        #expect(throws: IETF.RFC.`2183`.ParameterValue.Error.notASCII("é")) {
            try IETF.RFC.`2183`.ParameterValue("é")
        }
    }
}
