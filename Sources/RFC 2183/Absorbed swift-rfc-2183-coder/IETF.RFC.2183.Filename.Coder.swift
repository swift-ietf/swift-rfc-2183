#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension IETF.RFC.`2183`.Filename {
        public struct Coder<
            Input: Cursor.`Protocol`<Byte, Never>,
            Buffer: RangeReplaceableCollection<Byte>
        >: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }

    extension IETF.RFC.`2183`.Filename.Coder {
        public typealias Output = IETF.RFC.`2183`.Filename

        public typealias Failure = IETF.RFC.`2183`.Filename.Error

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            let bytes = Scan.run(&input) { byte in
                let code = byte.bitPattern
                return code != 0x3B && code != 0x0D && code != 0x0A
            }
            do throws(Failure) {
                return try IETF.RFC.`2183`.Filename(ascii: bytes)
            } catch {
                input.seek(to: start)
                throw error
            }
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            Scan.append(output.description, into: &buffer)
        }
    }
#endif
