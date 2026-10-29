#if Coder
    public import ASCII
    public import Binary
    public import Byte

    extension RFC_2183.Parameters: @retroactive ASCII.Serializable,
        @retroactive Binary.Serializable
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
#endif
