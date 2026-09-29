import Byte
import Byte
import RFC_2183
import Testing

@Suite
struct `RFC_2183.Filename Tests` {

    @Test
    func `a plain filename validates`() throws {
        let filename = try RFC_2183.Filename("my document.pdf")

        #expect(filename.rawValue == "my document.pdf")
        #expect(filename.value == "my document.pdf")
    }

    @Test
    func `a filename validates over bytes`() throws {
        let filename = try RFC_2183.Filename(ascii: [Byte](utf8: "photo.jpg"))

        #expect(filename == RFC_2183.Filename(rawValue: "photo.jpg"))
    }

    @Test
    func `an empty filename is refused`() {
        #expect(throws: RFC_2183.Filename.Error.empty) {
            try RFC_2183.Filename("")
        }
    }

    @Test
    func `path traversal and path separators are refused`() {
        #expect(throws: RFC_2183.Filename.Error.containsPathTraversal("../etc/passwd")) {
            try RFC_2183.Filename("../etc/passwd")
        }
        #expect(throws: RFC_2183.Filename.Error.containsPathSeparator("a/b.txt")) {
            try RFC_2183.Filename("a/b.txt")
        }
        #expect(throws: RFC_2183.Filename.Error.containsPathSeparator("\\share")) {
            try RFC_2183.Filename("\\share")
        }
    }

    @Test
    func `a control character is refused`() {
        #expect(throws: RFC_2183.Filename.Error.self) {
            try RFC_2183.Filename("bad\u{7}name.txt")
        }
    }
}
