#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension RFC_2183.Size {

        public struct Coder<
            Input: Cursor.`Protocol`<Byte, Never>,
            Buffer: RangeReplaceableCollection<Byte>
        >: Coding {

            public typealias Output = RFC_2183.Size

            public typealias Failure = RFC_2183.Size.Error

            public init() {}

            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let start = input.checkpoint
                let bytes = Scan.run(&input) { byte in
                    let code = byte.bitPattern
                    return code >= 0x30 && code <= 0x39
                }
                do throws(Failure) {
                    return try RFC_2183.Size(ascii: bytes)
                } catch {
                    input.seek(to: start)
                    throw error
                }
            }

            public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
                Scan.append(String(output.bytes), into: &buffer)
            }
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }
#endif
