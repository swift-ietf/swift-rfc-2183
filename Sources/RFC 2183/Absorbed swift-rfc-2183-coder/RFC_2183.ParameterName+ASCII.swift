#if Coder
    public import ASCII
    public import Binary

    extension RFC_2183.ParameterName: @retroactive ASCII.Parseable {}

    extension RFC_2183.ParameterName: @retroactive ASCII.Serializable,
        @retroactive Binary.Serializable
    {}
#endif
