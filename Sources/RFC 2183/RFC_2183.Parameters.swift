//
//  RFC_2183.Parameters.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

public import ASCII_Serializer_Primitives
public import Binary_Serializable_Primitives
public import RFC_2045
public import RFC_5322

// `Code` aliases ASCII.Code at file scope for the serialize verbs below.
private typealias Code = ASCII.Code

extension RFC_2183 {
    /// Structured parameters for Content-Disposition headers.
    ///
    /// Provides type-safe access to standard Content-Disposition parameters
    /// with proper validation and parsing.
    ///
    /// ## Standard Parameters (RFC 2183)
    ///
    /// - `filename`: Suggested filename for saving
    /// - `creationDate`: When the file was created
    /// - `modificationDate`: When the file was last modified
    /// - `readDate`: When the file was last read
    /// - `size`: Approximate file size in bytes
    ///
    /// ## Extension Parameters (RFC 7578)
    ///
    /// - `name`: Field name for multipart/form-data
    ///
    /// ## Example
    ///
    /// ```swift
    /// var params = RFC_2183.Parameters()
    /// params.filename = try Filename("document.pdf")
    /// params.size = try Size(bytes: 1024)
    /// params.creationDate = try RFC_5322.DateTime("Mon, 01 Jan 2024 12:00:00 +0000")
    /// ```
    public struct Parameters: Hashable, Sendable, Codable {
        // MARK: - RFC 2183 Standard Parameters

        /// The filename parameter (RFC 2183 Section 2.3).
        ///
        /// Suggests a default filename for saving the file.
        public var filename: Filename?

        /// The creation-date parameter (RFC 2183 Section 2.4).
        ///
        /// Date-time when the file was created (RFC 5322 format).
        public var creationDate: RFC_5322.DateTime?

        /// The modification-date parameter (RFC 2183 Section 2.5).
        ///
        /// Date-time when the file was last modified (RFC 5322 format).
        public var modificationDate: RFC_5322.DateTime?

        /// The read-date parameter (RFC 2183 Section 2.6).
        ///
        /// Date-time when the file was last read (RFC 5322 format).
        public var readDate: RFC_5322.DateTime?

        /// The size parameter (RFC 2183 Section 2.7).
        ///
        /// Approximate size of the file in octets.
        public var size: Size?

        // MARK: - RFC 7578 Extension

        /// The name parameter (RFC 7578 Section 4.2).
        ///
        /// Field name for multipart/form-data submissions.
        public var name: String?

        // MARK: - Extension Parameters

        /// Additional extension parameters not defined in standards.
        ///
        /// Stores arbitrary parameter name-value pairs for future extensions
        /// or vendor-specific parameters.
        public var extensionParameters: [ParameterName: String]

        // MARK: - Initialization

        /// Creates a parameter set with the specified values.
        public init(
            filename: Filename? = nil,
            creationDate: RFC_5322.DateTime? = nil,
            modificationDate: RFC_5322.DateTime? = nil,
            readDate: RFC_5322.DateTime? = nil,
            size: Size? = nil,
            name: String? = nil,
            extensionParameters: [ParameterName: String] = [:]
        ) {
            self.filename = filename
            self.creationDate = creationDate
            self.modificationDate = modificationDate
            self.readDate = readDate
            self.size = size
            self.name = name
            self.extensionParameters = extensionParameters
        }
    }
}

// MARK: - ASCII.Serializable / Binary.Serializable ([FAM-012] format siblings)

extension RFC_2183.Parameters: ASCII.Serializable, Binary.Serializable {
    /// [FAM-012] text sibling — emits the `;`-separated Content-Disposition
    /// parameter list as the typed text substrate `ASCII.Code`.
    ///
    /// Clause-9 composition: the verbatim sub-parts compose their same-format
    /// verbs directly — `RFC_2183.Size.serialize` (unquoted token) and
    /// `RFC_5322.DateTime.serialize` (inside quotes). The quoted-string values
    /// (`filename` / `name` / extension) apply RFC 2045 quoted-string escaping
    /// over their content string; that escaping is a distinct value codec, not
    /// a re-serialization of a sub-part's own byte form.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ params: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        if let filename = params.filename {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "filename".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            for c in filename.value.utf8 {
                let code = ASCII.Code(c)
                if code == Code.quotationMark { buffer.append(Code.reverseSolidus) }
                buffer.append(code)
            }
            buffer.append(Code.quotationMark)
        }

        if let creationDate = params.creationDate {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "creation-date".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            RFC_5322.DateTime.serialize(creationDate, into: &buffer)
            buffer.append(Code.quotationMark)
        }

        if let modificationDate = params.modificationDate {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "modification-date".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            RFC_5322.DateTime.serialize(modificationDate, into: &buffer)
            buffer.append(Code.quotationMark)
        }

        if let readDate = params.readDate {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "read-date".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            RFC_5322.DateTime.serialize(readDate, into: &buffer)
            buffer.append(Code.quotationMark)
        }

        if let size = params.size {
            // Size is unquoted per RFC 2183.
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "size".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            RFC_2183.Size.serialize(size, into: &buffer)
        }

        // RFC 7578 extension — name parameter.
        if let name = params.name {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "name".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            for c in name.utf8 {
                let code = ASCII.Code(c)
                if code == Code.quotationMark { buffer.append(Code.reverseSolidus) }
                buffer.append(code)
            }
            buffer.append(Code.quotationMark)
        }

        // Extension parameters in sorted order for stability.
        for (key, value) in params.extensionParameters.sorted(by: {
            $0.key.rawValue < $1.key.rawValue
        }) {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            // Clause-9: the key token is a drained sub-part — compose its verb.
            RFC_2045.Parameter.Name.serialize(key, into: &buffer)
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            for c in value.utf8 {
                let code = ASCII.Code(c)
                if code == Code.quotationMark { buffer.append(Code.reverseSolidus) }
                buffer.append(code)
            }
            buffer.append(Code.quotationMark)
        }
    }

    /// [FAM-012] binary sibling. Clause-9: an independent body composing the
    /// sub-parts' `Byte` verbs (`Size` / `RFC_5322.DateTime`) directly and
    /// re-emitting the quoted-string framing in the `Byte` domain — an
    /// independent body, not a byte-detour through the ASCII verb.
    /// Byte-equivalent to the text form (Content-Disposition is ASCII); the
    /// ASCII==Binary equivalence test guards the two bodies against drift.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ params: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        if let filename = params.filename {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "filename".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            for c in filename.value.utf8 {
                if ASCII.Code(c) == Code.quotationMark { buffer.append(Code.reverseSolidus.byte) }
                buffer.append(Byte(c))
            }
            buffer.append(Code.quotationMark.byte)
        }

        if let creationDate = params.creationDate {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "creation-date".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            RFC_5322.DateTime.serialize(creationDate, into: &buffer)
            buffer.append(Code.quotationMark.byte)
        }

        if let modificationDate = params.modificationDate {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "modification-date".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            RFC_5322.DateTime.serialize(modificationDate, into: &buffer)
            buffer.append(Code.quotationMark.byte)
        }

        if let readDate = params.readDate {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "read-date".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            RFC_5322.DateTime.serialize(readDate, into: &buffer)
            buffer.append(Code.quotationMark.byte)
        }

        if let size = params.size {
            // Size is unquoted per RFC 2183.
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "size".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            RFC_2183.Size.serialize(size, into: &buffer)
        }

        // RFC 7578 extension — name parameter.
        if let name = params.name {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "name".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            for c in name.utf8 {
                if ASCII.Code(c) == Code.quotationMark { buffer.append(Code.reverseSolidus.byte) }
                buffer.append(Byte(c))
            }
            buffer.append(Code.quotationMark.byte)
        }

        // Extension parameters in sorted order for stability.
        for (key, value) in params.extensionParameters.sorted(by: {
            $0.key.rawValue < $1.key.rawValue
        }) {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            // Clause-9: the key token is a drained sub-part — compose its verb.
            RFC_2045.Parameter.Name.serialize(key, into: &buffer)
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            for c in value.utf8 {
                if ASCII.Code(c) == Code.quotationMark { buffer.append(Code.reverseSolidus.byte) }
                buffer.append(Byte(c))
            }
            buffer.append(Code.quotationMark.byte)
        }
    }
}
