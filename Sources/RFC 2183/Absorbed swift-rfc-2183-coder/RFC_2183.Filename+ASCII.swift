#if Coder
    public import ASCII
    public import Binary

    extension RFC_2183.Filename: @retroactive ASCII.Parseable {}

    extension RFC_2183.Filename: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {}
#endif
