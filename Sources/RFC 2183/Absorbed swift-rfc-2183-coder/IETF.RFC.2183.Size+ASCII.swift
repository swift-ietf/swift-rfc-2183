#if Coder
    public import ASCII
    public import Binary

    extension IETF.RFC.`2183`.Size: ASCII.Parseable {}

    extension IETF.RFC.`2183`.Size: Swift::RawRepresentable {

        public var rawValue: String { String(bytes) }

        public init?(rawValue: String) {
            do throws(IETF.RFC.`2183`.Size.Error) {
                try self.init(rawValue)
            } catch {
                return nil
            }
        }
    }

    extension IETF.RFC.`2183`.Size: CustomStringConvertible {

        public var description: String { rawValue }
    }

    extension IETF.RFC.`2183`.Size: ASCII.Serializable, Binary.Serializable {}
#endif
