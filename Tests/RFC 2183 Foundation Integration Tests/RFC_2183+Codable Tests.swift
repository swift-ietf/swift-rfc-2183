import Foundation
import RFC_2183
import RFC_2183_Foundation_Integration
import RFC_5322
import RFC_5322_Foundation_Integration
import Testing

@Suite
struct `RFC_2183+Codable Tests` {

    @Test
    func `a disposition type codes as its text form`() throws {
        let type = RFC_2183.DispositionType.attachment

        let encoded = try JSONEncoder().encode(type)

        #expect(String(decoding: encoded, as: UTF8.self) == #""attachment""#)
        #expect(try JSONDecoder().decode(RFC_2183.DispositionType.self, from: encoded) == type)
    }

    @Test
    func `a size codes as its octet count`() throws {
        let size = try RFC_2183.Size(bytes: 1024)

        let encoded = try JSONEncoder().encode(size)

        #expect(String(decoding: encoded, as: UTF8.self) == "1024")
        #expect(try JSONDecoder().decode(RFC_2183.Size.self, from: encoded) == size)
    }

    @Test
    func `a content disposition round-trips through JSON`() throws {
        let disposition = RFC_2183.ContentDisposition(
            type: .attachment,
            parameters: .init(
                filename: try RFC_2183.Filename("report.pdf"),
                creationDate: try RFC_5322.DateTime("Mon, 1 Jan 2024 12:00:00 +0000"),
                size: try RFC_2183.Size(bytes: 1024),
                name: "document",
                extensionParameters: [try RFC_2183.ParameterName("x-token"): "abc"]
            )
        )

        let encoded = try JSONEncoder().encode(disposition)

        #expect(
            try JSONDecoder().decode(RFC_2183.ContentDisposition.self, from: encoded)
                == disposition
        )
    }

    @Test
    func `a disposition type that is not a token fails to decode`() {
        #expect(throws: RFC_2183.DispositionType.Error.self) {
            try JSONDecoder().decode(RFC_2183.DispositionType.self, from: Data(#""in line""#.utf8))
        }
    }

    @Test
    func `an invalid filename fails to decode`() {
        #expect(throws: RFC_2183.Filename.Error.self) {
            try JSONDecoder().decode(RFC_2183.Filename.self, from: Data(#""../x""#.utf8))
        }
    }
}
