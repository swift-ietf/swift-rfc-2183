//
//  RFC_2183.Filename.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

public import ASCII_Serializer_Primitives
public import Binary_Serializable_Primitives
public import Parseable_ASCII_Primitives
public import INCITS_4_1986

// `Code` aliases ASCII.Code at file scope — avoids the INCITS `[ASCII.Code].ASCII`
// shadow inside the `extension [Byte]` below.
private typealias Code = ASCII.Code

extension RFC_2183 {
    /// Validated filename for Content-Disposition filename parameter.
    ///
    /// RFC 2183 Section 2.3 specifies that the filename parameter suggests
    /// a default filename. This type validates filenames to prevent security
    /// issues like path traversal and control character injection.
    ///
    /// ## Validation Rules
    ///
    /// - Must be valid ASCII (uses INCITS 4-1986 validation)
    /// - No control characters (0x00-0x1F, 0x7F)
    /// - No path separators (/, \)
    /// - No parent directory references (..)
    /// - No absolute path indicators
    ///
    /// ## Example
    ///
    /// ```swift
    /// let filename = try RFC_2183.Filename("document.pdf")
    /// print(filename.value) // "document.pdf"
    ///
    /// // Invalid: contains path traversal
    /// try RFC_2183.Filename("../etc/passwd") // throws
    /// ```
    public struct Filename: Hashable, Sendable, Codable {
        /// The validated filename string.
        public let value: String

        /// Creates a filename WITHOUT validation
        ///
        /// **Warning**: Bypasses all RFC validation.
        /// Only use with compile-time constants or pre-validated values.
        ///
        /// - Parameter value: The raw value (unchecked)
        init(__unchecked value: String) {
            self.value = value
        }

        /// The base filename without any path components.
        ///
        /// This is equivalent to the validated value since path components
        /// are already rejected during validation.
        public var baseName: String {
            value
        }
    }
}

// MARK: - Serialization (family-Codable twins)

extension RFC_2183.Filename: Swift.RawRepresentable, Serializable, ASCII.Serializable, Binary.Serializable {
    public var rawValue: String { value }

    public init?(rawValue: String) {
        try? self.init(rawValue)
    }

    /// Explicit witness disambiguating the two constraint-incomparable
    /// `serialize(_:into:)` defaults. The bytes derive from the free
    /// `[ASCII.Code]` serializer supplied by the `String`-RawRepresentable
    /// default (`.serialized`).
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.serialized)
    }
}

// MARK: - CustomStringConvertible

extension RFC_2183.Filename: CustomStringConvertible {
    public var description: String { String(decoding: serialized, as: UTF8.self) }
}

// MARK: - Parsing

extension RFC_2183.Filename: ASCII.Parseable {
    /// Re-provides the string convenience initializer (previously inherited from
    /// the retired combined ASCII serializable protocol).
    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: [Byte](string.utf8))
    }

    /// Parses a filename from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 2183 filenames are ASCII-only.
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [Byte] (ASCII bytes)
    /// - **Codomain**: RFC_2183.Filename (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [Byte] (UTF-8 bytes) → Filename
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array<Byte>("document.pdf".utf8)
    /// let filename = try RFC_2183.Filename(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the filename
    /// - Throws: `RFC_2183.Filename.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        // Empty check
        guard !bytes.isEmpty else {
            throw Error.empty
        }

        // Check for control characters and non-ASCII
        for byte in bytes {
            // ASCII.Code(_:) now throws on non-ASCII bytes — that throw IS the notASCII case.
            let code: ASCII.Code
            do {
                code = try ASCII.Code(byte)
            } catch {
                throw Error.notASCII(String(decoding: bytes, as: UTF8.self))
            }
            guard code.isVisible || code == Code.space else {
                // Construction succeeded, so the byte is ASCII: a control character.
                throw Error.containsControlCharacters(
                    String(decoding: bytes, as: UTF8.self),
                    byte: code
                )
            }
        }

        let value = String(decoding: bytes, as: UTF8.self)

        // Check for path traversal
        guard !value.contains("..") else {
            throw Error.containsPathTraversal(value)
        }

        // Check for path separators
        guard !value.contains("/"), !value.contains("\\") else {
            throw Error.containsPathSeparator(value)
        }

        // Check for absolute path indicators
        guard !value.hasPrefix("/"), !value.hasPrefix("\\") else {
            throw Error.isAbsolutePath(value)
        }

        self.init(__unchecked: value)
    }
}

// MARK: - Byte Serialization

extension [Byte] {
    /// Creates ASCII byte representation of an RFC 2183 filename
    ///
    /// This is the canonical serialization of filenames to bytes.
    /// RFC 2183 filenames are ASCII-only by definition.
    ///
    /// ## Category Theory
    ///
    /// This is the most universal serialization (natural transformation):
    /// - **Domain**: RFC_2183.Filename (structured data)
    /// - **Codomain**: [Byte] (ASCII bytes)
    ///
    /// String representation is derived as composition:
    /// ```
    /// Filename → [Byte] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let filename = try RFC_2183.Filename("document.pdf")
    /// let bytes = [Byte](filename)
    /// ```
    ///
    /// - Parameter filename: The filename to serialize
    public init(_ filename: RFC_2183.Filename) {
        self = Array<Byte>(filename.value.utf8)
    }
}

