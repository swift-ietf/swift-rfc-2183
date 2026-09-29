import Byte
import Byte
import RFC_2183
import Testing

@Suite
struct `RFC_2183.Size Tests` {

    @Test
    func `a negative size is refused`() {
        #expect(throws: RFC_2183.Size.Error.negative(-1)) {
            try RFC_2183.Size(bytes: -1)
        }
    }

    @Test
    func `sizes order by octet count`() throws {
        #expect(try RFC_2183.Size(bytes: 1) < RFC_2183.Size(bytes: 2))
    }

    @Test
    func `a size reads its decimal digits`() throws {
        #expect(try RFC_2183.Size("1048576").bytes == 1_048_576)
        #expect(try RFC_2183.Size(ascii: [Byte](utf8: "42")).bytes == 42)
    }

    @Test
    func `a size is one or more digits and nothing else`() {
        #expect(throws: RFC_2183.Size.Error.invalidFormat("many")) {
            try RFC_2183.Size("many")
        }
        #expect(throws: RFC_2183.Size.Error.invalidFormat("-1")) {
            try RFC_2183.Size("-1")
        }
        #expect(throws: RFC_2183.Size.Error.invalidFormat("+5")) {
            try RFC_2183.Size("+5")
        }
        #expect(throws: RFC_2183.Size.Error.invalidFormat("")) {
            try RFC_2183.Size("")
        }
        #expect(throws: RFC_2183.Size.Error.invalidFormat("1 024")) {
            try RFC_2183.Size("1 024")
        }
    }
}
