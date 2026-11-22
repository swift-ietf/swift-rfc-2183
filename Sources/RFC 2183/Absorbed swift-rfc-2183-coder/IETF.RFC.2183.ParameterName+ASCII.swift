#if Coder
    public import ASCII
    public import Binary

    extension IETF.RFC.`2183`.ParameterName: ASCII.Parseable {}

    extension IETF.RFC.`2183`.ParameterName: ASCII.Serializable,
        Binary.Serializable
    {}
#endif
