#if Coder
    public import ASCII
    public import Binary

    extension RFC_2183.DispositionType: ASCII.Parseable {}

    extension RFC_2183.DispositionType: ASCII.Serializable,
        Binary.Serializable
    {}
#endif
