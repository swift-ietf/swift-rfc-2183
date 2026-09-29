import RFC_5322

extension RFC_2183.ContentDisposition {

    enum Fields {

        static func trimmed(_ text: some StringProtocol) -> String {
            var slice = Substring(text)
            while let first = slice.first, first == " " || first == "\t" {
                slice = slice.dropFirst()
            }
            while let last = slice.last, last == " " || last == "\t" {
                slice = slice.dropLast()
            }
            return String(slice)
        }

        static func unquoted(_ value: String) -> String {
            guard value.count >= 2, value.hasPrefix("\""), value.hasSuffix("\"") else {
                return value
            }
            var result = ""
            var escaped = false
            for character in value.dropFirst().dropLast() {
                if escaped {
                    result.append(character)
                    escaped = false
                    continue
                }
                if character == "\\" {
                    escaped = true
                    continue
                }
                result.append(character)
            }
            return result
        }

        static func segments(_ text: String) -> [String] {
            var segments: [String] = []
            var current = ""
            var quoting = false
            var escaped = false

            for character in text {
                if escaped {
                    current.append(character)
                    escaped = false
                    continue
                }
                if quoting, character == "\\" {
                    current.append(character)
                    escaped = true
                    continue
                }
                if character == "\"" {
                    quoting.toggle()
                    current.append(character)
                    continue
                }
                if character == ";", !quoting {
                    segments.append(current)
                    current = ""
                    continue
                }
                current.append(character)
            }
            segments.append(current)
            return segments
        }

        static func attributes(_ segments: some Sequence<String>) -> [String: String] {
            var raw: [String: String] = [:]
            for segment in segments {
                guard let equals = segment.firstIndex(of: "=") else { continue }
                let key = trimmed(segment[..<equals]).lowercased()
                guard !key.isEmpty else { continue }
                let value = trimmed(segment[segment.index(after: equals)...])
                guard !value.isEmpty else { continue }
                raw[key] = unquoted(value)
            }
            return raw
        }

        static func parameters(_ raw: [String: String]) -> RFC_2183.Parameters {
            var parameters = RFC_2183.Parameters()

            if let filename = raw[RFC_2183.ParameterName.filename.rawValue] {
                parameters.filename = try? RFC_2183.Filename(filename)
            }
            if let creationDate = raw[RFC_2183.ParameterName.creationDate.rawValue] {
                parameters.creationDate = try? RFC_5322.DateTime(creationDate)
            }
            if let modificationDate = raw[RFC_2183.ParameterName.modificationDate.rawValue] {
                parameters.modificationDate = try? RFC_5322.DateTime(modificationDate)
            }
            if let readDate = raw[RFC_2183.ParameterName.readDate.rawValue] {
                parameters.readDate = try? RFC_5322.DateTime(readDate)
            }
            if let size = raw[RFC_2183.ParameterName.size.rawValue] {
                parameters.size = try? RFC_2183.Size(size)
            }
            parameters.name = raw[RFC_2183.ParameterName.name.rawValue]

            for (key, value) in raw {
                guard let name = RFC_2183.ParameterName(rawValue: key) else { continue }
                guard !known.contains(name) else { continue }
                parameters.extensionParameters[name] = value
            }

            return parameters
        }

        static let known: Set<RFC_2183.ParameterName> = [
            .filename,
            .creationDate,
            .modificationDate,
            .readDate,
            .size,
            .name,
        ]
    }
}
