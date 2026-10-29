#if Coder
    public import ASCII
    public import Binary

    extension RFC_2183.Filename: ASCII.Parseable {}

    extension RFC_2183.Filename: ASCII.Serializable, Binary.Serializable {}
#endif
