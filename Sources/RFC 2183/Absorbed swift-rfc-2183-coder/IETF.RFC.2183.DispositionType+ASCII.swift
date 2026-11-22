#if Coder
    public import ASCII
    public import Binary

    extension IETF.RFC.`2183`.DispositionType: ASCII.Parseable {}

    extension IETF.RFC.`2183`.DispositionType: ASCII.Serializable,
        Binary.Serializable
    {}
#endif
