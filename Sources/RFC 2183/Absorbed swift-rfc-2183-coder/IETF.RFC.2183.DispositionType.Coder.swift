#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension IETF.RFC.`2183`.DispositionType {
        public struct Coder<
            Input: Cursor.`Protocol`<Byte, Never>,
            Buffer: RangeReplaceableCollection<Byte>
        >: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }

    extension IETF.RFC.`2183`.DispositionType.Coder {
        public typealias Output = IETF.RFC.`2183`.DispositionType

        public typealias Failure = IETF.RFC.`2183`.DispositionType.Error

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            let bytes = Scan.run(&input, while: Scan.isTokenCharacter)
            do throws(Failure) {
                return try IETF.RFC.`2183`.DispositionType(ascii: bytes)
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
