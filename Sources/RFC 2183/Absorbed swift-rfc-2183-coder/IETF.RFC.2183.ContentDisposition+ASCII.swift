#if Coder
    public import ASCII
    public import Binary
    public import Byte

    extension IETF.RFC.`2183`.ContentDisposition: ASCII.Parseable {}

    extension IETF.RFC.`2183`.ContentDisposition: ASCII.Serializable,
        Binary.Serializable
    {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ value: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == ASCII.Code {
            Scan.append(Text.render(value), into: &buffer)
        }

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ value: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            Scan.append(Text.render(value), into: &buffer)
        }
    }

    extension IETF.RFC.`2183`.ContentDisposition: CustomStringConvertible {

        public var description: String { Text.render(self) }
    }
#endif
