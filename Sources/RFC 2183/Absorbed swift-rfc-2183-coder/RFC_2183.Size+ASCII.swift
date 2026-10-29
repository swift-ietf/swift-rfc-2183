#if Coder
    public import ASCII
    public import Binary

    extension RFC_2183.Size: @retroactive ASCII.Parseable {}

    extension RFC_2183.Size: @retroactive Swift::RawRepresentable {

        public var rawValue: String { String(bytes) }

        public init?(rawValue: String) {
            do throws(RFC_2183.Size.Error) {
                try self.init(rawValue)
            } catch {
                return nil
            }
        }
    }

    extension RFC_2183.Size: @retroactive CustomStringConvertible {

        public var description: String { rawValue }
    }

    extension RFC_2183.Size: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {}
#endif
