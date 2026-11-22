import Byte
import RFC_2183
import Testing

@Suite
struct `IETF.RFC.2183.Filename Tests` {

    @Test
    func `a plain filename validates`() throws {
        let filename = try IETF.RFC.`2183`.Filename("my document.pdf")

        #expect(filename.rawValue == "my document.pdf")
        #expect(filename.value == "my document.pdf")
    }

    @Test
    func `a filename validates over bytes`() throws {
        let filename = try IETF.RFC.`2183`.Filename(ascii: [Byte](utf8: "photo.jpg"))

        #expect(filename == IETF.RFC.`2183`.Filename(rawValue: "photo.jpg"))
    }

    @Test
    func `an empty filename is refused`() {
        #expect(throws: IETF.RFC.`2183`.Filename.Error.empty) {
            try IETF.RFC.`2183`.Filename("")
        }
    }

    @Test
    func `path traversal and path separators are refused`() {
        #expect(throws: IETF.RFC.`2183`.Filename.Error.containsPathTraversal("../etc/passwd")) {
            try IETF.RFC.`2183`.Filename("../etc/passwd")
        }
        #expect(throws: IETF.RFC.`2183`.Filename.Error.containsPathSeparator("a/b.txt")) {
            try IETF.RFC.`2183`.Filename("a/b.txt")
        }
        #expect(throws: IETF.RFC.`2183`.Filename.Error.containsPathSeparator("\\share")) {
            try IETF.RFC.`2183`.Filename("\\share")
        }
    }

    @Test
    func `a control character is refused`() {
        #expect(throws: IETF.RFC.`2183`.Filename.Error.self) {
            try IETF.RFC.`2183`.Filename("bad\u{7}name.txt")
        }
    }
}
