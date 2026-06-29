//
//  RFC_2183.Size.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

public import ASCII_Serializer_Primitives
public import Binary_Serializable_Primitives
public import Parseable_ASCII_Primitives

extension RFC_2183 {
    /// File size in bytes for Content-Disposition size parameter.
    ///
    /// RFC 2183 Section 2.7 specifies that the size parameter indicates
    /// the approximate size of the file in octets.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let size = try RFC_2183.Size(bytes: 1024)
    /// print(size.bytes) // 1024
    /// ```
    public struct Size: Hashable, Sendable, Codable, Comparable {
        /// The size in bytes.
        public let bytes: Int

        /// Creates a size value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation.
        /// Only use with compile-time constants or pre-validated values.
        ///
        /// - Parameter bytes: The number of bytes (unchecked)
        init(__unchecked bytes: Int) {
            self.bytes = bytes
        }

        /// Creates a size value from a byte count.
        ///
        /// - Parameter bytes: The number of bytes. Must be non-negative.
        /// - Throws: `RFC_2183.Size.Error.negative` if bytes is negative.
        public init(bytes: Int) throws(Error) {
            guard bytes >= 0 else {
                throw Error.negative(bytes)
            }
            self.init(__unchecked: bytes)
        }

        // MARK: - Comparable

        public static func < (lhs: Size, rhs: Size) -> Bool {
            lhs.bytes < rhs.bytes
        }
    }
}

// MARK: - Parsing

extension RFC_2183.Size: ASCII.Parseable {
    /// Parses a size from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 2183 size values are ASCII digits only.
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [Byte] (ASCII bytes)
    /// - **Codomain**: RFC_2183.Size (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [Byte] (UTF-8 bytes) → Size
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array<Byte>("1024".utf8)
    /// let size = try RFC_2183.Size(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the size
    /// - Throws: `RFC_2183.Size.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        let string = String(decoding: bytes, as: UTF8.self)
        guard let value = Int(string) else {
            throw Error.invalidFormat(string)
        }
        guard value >= 0 else {
            throw Error.negative(value)
        }
        self.init(__unchecked: value)
    }
}

// MARK: - Byte Serialization

extension [Byte] {
    /// Creates ASCII byte representation of an RFC 2183 size
    ///
    /// This is the canonical serialization of sizes to bytes.
    /// RFC 2183 sizes are ASCII digits only by definition.
    ///
    /// ## Category Theory
    ///
    /// This is the most universal serialization (natural transformation):
    /// - **Domain**: RFC_2183.Size (structured data)
    /// - **Codomain**: [Byte] (ASCII bytes)
    ///
    /// String representation is derived as composition:
    /// ```
    /// Size → [Byte] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let size = try RFC_2183.Size(bytes: 1024)
    /// let bytes = [Byte](size)
    /// ```
    ///
    /// - Parameter size: The size to serialize
    public init(_ size: RFC_2183.Size) {
        self = Array<Byte>(String(size.bytes).utf8)
    }
}

// MARK: - Serialization (family-Codable twins)

extension RFC_2183.Size: Swift.RawRepresentable, Serializable, ASCII.Serializable, Binary.Serializable {
    public var rawValue: String { String(bytes) }

    public init?(rawValue: String) {
        guard let value = Int(rawValue), value >= 0 else {
            return nil
        }
        self.init(__unchecked: value)
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

extension RFC_2183.Size: CustomStringConvertible {
    public var description: String { String(decoding: serialized, as: UTF8.self) }
}

extension RFC_2183.Size: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let bytes = Int(description), bytes >= 0 else {
            return nil
        }
        self.init(__unchecked: bytes)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension RFC_2183.Size: ExpressibleByIntegerLiteral {
    /// Creates a size from an integer literal
    ///
    /// **Note**: Bypasses validation via `init(__unchecked:)`.
    /// Only use with compile-time constants.
    ///
    /// ```swift
    /// let size: RFC_2183.Size = 1024
    /// ```
    public init(integerLiteral value: Int) {
        self.init(__unchecked: value)
    }
}
