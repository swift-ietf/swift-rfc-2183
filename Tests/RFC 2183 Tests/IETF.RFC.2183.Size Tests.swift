import Byte
import RFC_2183
import Testing

@Suite
struct `IETF.RFC.2183.Size Tests` {

    @Test
    func `a negative size is refused`() {
        #expect(throws: IETF.RFC.`2183`.Size.Error.negative(-1)) {
            try IETF.RFC.`2183`.Size(bytes: -1)
        }
    }

    @Test
    func `sizes order by octet count`() throws {
        #expect(try IETF.RFC.`2183`.Size(bytes: 1) < IETF.RFC.`2183`.Size(bytes: 2))
    }

    @Test
    func `a size reads its decimal digits`() throws {
        #expect(try IETF.RFC.`2183`.Size("1048576").bytes == 1_048_576)
        #expect(try IETF.RFC.`2183`.Size(ascii: [Byte](utf8: "42")).bytes == 42)
    }

    @Test
    func `a size is one or more digits and nothing else`() {
        #expect(throws: IETF.RFC.`2183`.Size.Error.invalidFormat("many")) {
            try IETF.RFC.`2183`.Size("many")
        }
        #expect(throws: IETF.RFC.`2183`.Size.Error.invalidFormat("-1")) {
            try IETF.RFC.`2183`.Size("-1")
        }
        #expect(throws: IETF.RFC.`2183`.Size.Error.invalidFormat("+5")) {
            try IETF.RFC.`2183`.Size("+5")
        }
        #expect(throws: IETF.RFC.`2183`.Size.Error.invalidFormat("")) {
            try IETF.RFC.`2183`.Size("")
        }
        #expect(throws: IETF.RFC.`2183`.Size.Error.invalidFormat("1 024")) {
            try IETF.RFC.`2183`.Size("1 024")
        }
    }
}
