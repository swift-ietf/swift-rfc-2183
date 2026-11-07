#if Coder
    import RFC_5322

    enum Text {

        static func quoted(_ value: String) -> String {
            var result = "\""
            for character in value {
                if character == "\"" || character == "\\" { result.append("\\") }
                result.append(character)
            }
            result.append("\"")
            return result
        }

        static func render(_ disposition: RFC_2183.ContentDisposition) -> String {
            disposition.type.rawValue + render(disposition.parameters)
        }

        static func render(_ parameters: RFC_2183.Parameters) -> String {
            var result = ""

            if let filename = parameters.filename {
                result += "; filename=" + quoted(filename.value)
            }
            if let creationDate = parameters.creationDate {
                result += "; creation-date=" + quoted(creationDate.description)
            }
            if let modificationDate = parameters.modificationDate {
                result += "; modification-date=" + quoted(modificationDate.description)
            }
            if let readDate = parameters.readDate {
                result += "; read-date=" + quoted(readDate.description)
            }
            if let size = parameters.size {
                result += "; size=" + String(size.bytes)
            }
            if let name = parameters.name {
                result += "; name=" + quoted(name.value)
            }
            for (key, value) in parameters.extensionParameters.sorted(by: {
                $0.key.rawValue < $1.key.rawValue
            }) {
                result += "; " + key.rawValue + "=" + quoted(value.value)
            }

            return result
        }
    }
#endif
