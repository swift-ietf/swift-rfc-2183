#if Coder
    public import ASCII
    public import Binary

    extension RFC_2183.DispositionType: @retroactive ASCII.Parseable {}

    extension RFC_2183.DispositionType: @retroactive ASCII.Serializable,
        @retroactive Binary.Serializable
    {}
#endif
