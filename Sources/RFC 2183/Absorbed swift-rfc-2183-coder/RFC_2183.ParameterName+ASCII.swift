#if Coder
    public import ASCII
    public import Binary

    extension RFC_2183.ParameterName: ASCII.Parseable {}

    extension RFC_2183.ParameterName: ASCII.Serializable,
        Binary.Serializable
    {}
#endif
