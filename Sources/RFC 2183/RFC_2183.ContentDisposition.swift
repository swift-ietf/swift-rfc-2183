//
//  RFC_2183.ContentDisposition.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

public import ASCII_Serializer_Primitives
public import Binary_Serializable_Primitives
public import Parseable_ASCII_Primitives
public import INCITS_4_1986
import RFC_2045
public import RFC_5322

// `Code` aliases ASCII.Code at file scope — avoids the INCITS `[ASCII.Code].ASCII`
// shadow inside the `extension [Byte]` serialize/parse helpers below.
private typealias Code = ASCII.Code

extension RFC_2183 {
    /// Content-Disposition header field
    ///
    /// Communicates presentation information in Internet messages,
    /// indicating whether content should be displayed inline or treated
    /// as an attachment.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Inline content
    /// let inline = RFC_2183.ContentDisposition(type: .inline)
    ///
    /// // Attachment with filename
    /// let attachment = RFC_2183.ContentDisposition(
    ///     type: .attachment,
    ///     parameters: Parameters(filename: try Filename("document.pdf"))
    /// )
    ///
    /// // Form data with field name and filename
    /// let formData = RFC_2183.ContentDisposition(
    ///     type: .formData,
    ///     parameters: Parameters(
    ///         name: "avatar",
    ///         filename: try Filename("photo.jpg")
    ///     )
    /// )
    /// ```
    ///
    /// ## RFC Reference
    ///
    /// From RFC 2183 Section 2:
    ///
    /// > The Content-Disposition header field is used to convey presentational
    /// > information for a message or body part. The disposition-type indicates
    /// > how the part should be handled.
    public struct ContentDisposition: Hashable, Sendable, Codable {
        /// The disposition type (inline, attachment, etc.)
        public let type: DispositionType

        /// Typed parameters (filename, size, dates, etc.)
        public let parameters: Parameters

        /// Creates a new Content-Disposition header
        ///
        /// - Parameters:
        ///   - type: Disposition type
        ///   - parameters: Typed parameters
        public init(
            type: DispositionType,
            parameters: Parameters = Parameters()
        ) {
            self.type = type
            self.parameters = parameters
        }
    }
}

extension [Byte] {
    public init(
        _ contentDisposition: RFC_2183.ContentDisposition.Type
    ) {
        self = Array<Byte>("Content-Disposition".utf8)
    }
}

// MARK: - ASCII.Serializable / Binary.Serializable ([FAM-012] format siblings)

extension RFC_2183.ContentDisposition: ASCII.Serializable, Binary.Serializable {
    /// [FAM-012] text sibling — composes the `DispositionType` + `Parameters`
    /// ASCII verbs directly (clause-9: ASCII verb → sub-part ASCII verbs), never
    /// reaching into a sub-part's `rawValue`/property.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ disposition: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        RFC_2183.DispositionType.serialize(disposition.type, into: &buffer)
        RFC_2183.Parameters.serialize(disposition.parameters, into: &buffer)
    }

    /// [FAM-012] binary sibling. Clause-9: composes the `DispositionType` +
    /// `Parameters` Byte verbs directly (Byte verb → sub-part Byte verbs) —
    /// never a byte-detour through the ASCII verb. Byte-equivalent to the text
    /// form (Content-Disposition is ASCII).
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ disposition: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_2183.DispositionType.serialize(disposition.type, into: &buffer)
        RFC_2183.Parameters.serialize(disposition.parameters, into: &buffer)
    }
}

// MARK: - ASCII.Parseable ([FAM-012] parse — free-standing init)

extension RFC_2183.ContentDisposition: ASCII.Parseable {
    /// Re-provides the string convenience initializer (previously inherited
    /// from the retired combined ASCII serializable protocol).
    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: [Byte](string.utf8))
    }

    /// Parses a Content-Disposition header from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 2183 headers are pure ASCII, so this parser operates on ASCII bytes.
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [Byte] (ASCII bytes)
    /// - **Codomain**: RFC_2183.ContentDisposition (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [Byte] (UTF-8 bytes) → ContentDisposition
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array<Byte>("attachment; filename=\"doc.pdf\"".utf8)
    /// let disposition = try RFC_2183.ContentDisposition(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the header value
    /// - Throws: `RFC_2183.ContentDisposition.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        // Split on first semicolon to separate type from parameters
        guard let firstSemicolon = bytes.firstIndex(where: { $0 == Code.semicolon.byte }) else {
            // No parameters, just disposition type
            let typeString = String(decoding: bytes, as: UTF8.self)
                .trimming(.ascii.whitespaces)
            guard !typeString.isEmpty else {
                throw Error.emptyDispositionType
            }

            self.type = RFC_2183.DispositionType(rawValue: typeString)
            self.parameters = .init()
            return
        }

        // Parse disposition type
        let typeString = String(decoding: bytes[..<firstSemicolon], as: UTF8.self)
            .trimming(.ascii.whitespaces)
        guard !typeString.isEmpty else {
            throw Error.emptyDispositionType
        }

        self.type = RFC_2183.DispositionType(rawValue: typeString)

        // Parse parameters – work on a slice, avoid Array copy
        let parametersStartIndex = bytes.index(after: firstSemicolon)
        let parametersSlice = bytes[parametersStartIndex...]

        var rawParams: [String: String] = [:]

        // Type-up: lift to [ASCII.Code] for grammar work (semicolon/equals scanning,
        // quotation detection); allocate Array<UInt8> for the lowercase helper at the
        // single call site below per BSLI bridge.
        let pCodes: [ASCII.Code]
        do {
            pCodes = try Array<ASCII.Code>(parametersSlice)
        } catch {
            throw Error.invalidFormat(String(decoding: bytes, as: UTF8.self))
        }
        var segStart = 0

        func processParam(_ lo: Int, _ hi: Int) {
            let segment = pCodes[lo..<hi]

            guard let equalsIndex = segment.firstIndex(of: Code.equalsSign) else {
                return
            }

            let keySlice = segment[..<equalsIndex]
            let keyString = String(decoding: keySlice, as: UTF8.self)
                .trimming(.ascii.whitespaces)
            guard !keyString.isEmpty else { return }

            let valueRawSlice = segment[(equalsIndex &+ 1)...]
            let valueString = String(decoding: valueRawSlice, as: UTF8.self)
                .trimming(.ascii.whitespaces)
            guard !valueString.isEmpty else { return }

            // Re-lift the trimmed value back to ASCII.Code bytes for quotation detection.
            // valueString is ASCII (decoded + trimmed from ASCII bytes); drop any stray non-ASCII.
            let valueCodes = valueString.utf8.compactMap { try? ASCII.Code(Byte($0)) }

            // Determine quoting with a single forward pass
            guard let firstCode = valueCodes.first else { return }
            let lastCode = valueCodes.last ?? firstCode
            let length = valueCodes.count

            // Lowercase the ASCII parameter key (RFC 2183 param keys are ASCII tokens,
            // so Unicode-default case folding is byte-identical to ASCII lowercasing).
            let key = keyString.lowercased()

            let value: String
            let isQuoted =
                firstCode == Code.quotationMark
                && lastCode == Code.quotationMark
                && length >= 2
            if isQuoted {
                let inner = valueCodes.dropFirst().dropLast()
                let unescaped = Self.unescapeQuotes(inner)
                value = String(decoding: unescaped, as: UTF8.self)
            } else {
                value = valueString
            }

            rawParams[key] = value
        }

        for idx in 0..<pCodes.count {
            if pCodes[idx] == Code.semicolon {
                processParam(segStart, idx)
                segStart = idx &+ 1
            }
        }
        processParam(segStart, pCodes.count)

        // Convert raw parameters to typed parameters
        self.parameters = Self.parseParameters(rawParams)
    }

    /// Unescapes quoted-pair sequences in parameter values
    ///
    /// RFC 2183 allows escaping quotes with backslash: \"
    ///
    /// - Parameter bytes: The bytes to unescape
    /// - Returns: Unescaped bytes
    private static func unescapeQuotes<C: Collection>(
        _ bytes: C
    ) -> [Byte] where C.Element == ASCII.Code {
        var result: [Byte] = []
        result.reserveCapacity(bytes.count)

        var i = bytes.startIndex
        let end = bytes.endIndex

        while i != end {
            let current = bytes[i]
            let nextIndex = bytes.index(after: i)

            // Check for backslash + quote
            let isEscapedQuote =
                nextIndex != end
                && current == Code.reverseSolidus  // '\'
                && bytes[nextIndex] == Code.quotationMark  // '"'
            if isEscapedQuote {
                // Include only the quote
                result.append(Code.quotationMark)

                // Skip both characters
                i = bytes.index(after: nextIndex)
            } else {
                // Not an escape sequence
                result.append(current)
                i = nextIndex
            }
        }

        return result
    }
}

// MARK: - Parameter Parsing

extension RFC_2183.ContentDisposition {
    /// Parse raw string parameters into typed Parameters struct.
    package static func parseParameters(_ raw: [String: String]) -> RFC_2183.Parameters {
        var params = RFC_2183.Parameters()

        // Parse standard parameters with validation (silently ignore invalid values)
        if let filenameStr = raw["filename"] {
            params.filename = try? RFC_2183.Filename(filenameStr)
        }

        if let creationDateStr = raw["creation-date"] {
            params.creationDate = try? RFC_5322.DateTime(ascii: Array<Byte>(creationDateStr.utf8))
        }

        if let modDateStr = raw["modification-date"] {
            params.modificationDate = try? RFC_5322.DateTime(ascii: Array<Byte>(modDateStr.utf8))
        }

        if let readDateStr = raw["read-date"] {
            params.readDate = try? RFC_5322.DateTime(ascii: Array<Byte>(readDateStr.utf8))
        }

        if let sizeStr = raw["size"] {
            params.size = try? RFC_2183.Size(bytes: Int(sizeStr) ?? -1)
        }

        // RFC 7578 extension
        params.name = raw["name"]

        // Store unknown parameters in extensionParameters
        let knownKeys: Set<String> = [
            "filename",
            "creation-date",
            "modification-date",
            "read-date",
            "size",
            "name",
        ]

        for (key, value) in raw where !knownKeys.contains(key) {
            params.extensionParameters[RFC_2045.Parameter.Name(rawValue: key)] = value
        }

        return params
    }
}

// MARK: - Convenience Accessors

extension RFC_2183.ContentDisposition {
    /// The filename parameter (RFC 2183 Section 2.3)
    ///
    /// Convenience accessor that delegates to `parameters.filename`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let disposition = try RFC_2183.ContentDisposition(
    ///     "attachment; filename=\"document.pdf\""
    /// )
    /// print(disposition.filename?.value) // "document.pdf"
    /// ```
    public var filename: RFC_2183.Filename? {
        parameters.filename
    }

    /// The creation-date parameter (RFC 2183 Section 2.4)
    ///
    /// Convenience accessor that delegates to `parameters.creationDate`.
    ///
    /// Date-time when the file was created (RFC 5322 format).
    public var creationDate: RFC_5322.DateTime? {
        parameters.creationDate
    }

    /// The modification-date parameter (RFC 2183 Section 2.5)
    ///
    /// Convenience accessor that delegates to `parameters.modificationDate`.
    ///
    /// Date-time when the file was last modified (RFC 5322 format).
    public var modificationDate: RFC_5322.DateTime? {
        parameters.modificationDate
    }

    /// The read-date parameter (RFC 2183 Section 2.6)
    ///
    /// Convenience accessor that delegates to `parameters.readDate`.
    ///
    /// Date-time when the file was last read (RFC 5322 format).
    public var readDate: RFC_5322.DateTime? {
        parameters.readDate
    }

    /// The size parameter (RFC 2183 Section 2.7)
    ///
    /// Convenience accessor that delegates to `parameters.size`.
    ///
    /// Approximate size of the file in octets.
    public var size: RFC_2183.Size? {
        parameters.size
    }

    /// The name parameter (RFC 7578 Section 4.2)
    ///
    /// Convenience accessor that delegates to `parameters.name`.
    ///
    /// Field name for multipart/form-data submissions.
    public var name: String? {
        parameters.name
    }
}

// MARK: - Convenience Constructors

extension RFC_2183.ContentDisposition {
    /// Creates an inline Content-Disposition
    ///
    /// - Returns: Content-Disposition with type inline
    ///
    /// ## Example
    ///
    /// ```swift
    /// let inline = RFC_2183.ContentDisposition.inline()
    /// // Content-Disposition: inline
    /// ```
    public static func inline() -> Self {
        Self(type: .inline)
    }

    /// Creates an attachment Content-Disposition
    ///
    /// - Parameters:
    ///   - filename: Optional filename parameter
    ///   - size: Optional size parameter
    ///   - creationDate: Optional creation date
    ///   - modificationDate: Optional modification date
    ///   - readDate: Optional read date
    /// - Returns: Content-Disposition with type attachment
    ///
    /// ## Example
    ///
    /// ```swift
    /// let attachment = RFC_2183.ContentDisposition.attachment(
    ///     filename: try Filename("document.pdf"),
    ///     size: try Size(bytes: 1024)
    /// )
    /// // Content-Disposition: attachment; filename="document.pdf"; size=1024
    /// ```
    public static func attachment(
        filename: RFC_2183.Filename? = nil,
        size: RFC_2183.Size? = nil,
        creationDate: RFC_5322.DateTime? = nil,
        modificationDate: RFC_5322.DateTime? = nil,
        readDate: RFC_5322.DateTime? = nil
    ) -> Self {
        Self(
            type: .attachment,
            parameters: .init(
                filename: filename,
                creationDate: creationDate,
                modificationDate: modificationDate,
                readDate: readDate,
                size: size
            )
        )
    }

    /// Creates a form-data Content-Disposition
    ///
    /// - Parameters:
    ///   - name: Form field name
    ///   - filename: Optional filename for file uploads
    /// - Returns: Content-Disposition with type form-data
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Text field
    /// let field = RFC_2183.ContentDisposition.formData(name: "username")
    /// // Content-Disposition: form-data; name="username"
    ///
    /// // File upload
    /// let file = RFC_2183.ContentDisposition.formData(
    ///     name: "avatar",
    ///     filename: try Filename("photo.jpg")
    /// )
    /// // Content-Disposition: form-data; name="avatar"; filename="photo.jpg"
    /// ```
    public static func formData(name: String, filename: RFC_2183.Filename? = nil) -> Self {
        Self(
            type: .formData,
            parameters: .init(
                filename: filename,
                name: name
            )
        )
    }
}

// MARK: - Protocol Conformances

extension RFC_2183.ContentDisposition: CustomStringConvertible {
    /// The `disposition-type *(";" parameter)` form — the same grammar the
    /// `ASCII.Serializable` / `Binary.Serializable` verbs emit. Re-provided
    /// directly; the retired combined ASCII serializable protocol no longer
    /// synthesizes it. Derived from the ASCII verb ([FAM-004] additive accessor).
    public var description: String {
        var codes: [ASCII.Code] = []
        Self.serialize(self, into: &codes)
        return String(decoding: codes.map(\.byte), as: UTF8.self)
    }
}

extension RFC_2183.DispositionType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RFC_2183.DispositionType: CustomStringConvertible {
    public var description: String { rawValue }
}
