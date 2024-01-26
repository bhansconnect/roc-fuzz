interface Arbitrary
    exposes [
        Arbitrary,
        arbitrary,
        sizeHint,
        Phantom,
        phantom,
        generate,
        ArbitraryU8,
        unwrapU8,
        ArbitraryStr,
        unwrapStr,
        ArbitraryBytes,
        unwrapBytes,
    ]
    imports [
        Size,
        Generate.{ Generator },
    ]

Phantom a := {}

phantom : Phantom *
phantom = @Phantom {}

Arbitrary implements
    arbitrary : Generator a where a implements Arbitrary
    sizeHint : Phantom a, U64 -> Size.Hint where a implements Arbitrary

generate : (a -> Generator b) -> Generator b where a implements Arbitrary
generate = \transform ->
    Generate.andThen arbitrary transform

# ===== Primitive Implementations =============================================

ArbitraryU8 := U8 implements [
        Arbitrary {
            arbitrary: arbitraryU8,
            sizeHint: sizeHintU8,
        },
        Inspect,
    ]

unwrapU8 : ArbitraryU8 -> U8
unwrapU8 = \@ArbitraryU8 x -> x

arbitraryU8 : Generator ArbitraryU8
arbitraryU8 =
    Generate.u8Between { startAt: Num.minU8, endAt: Num.maxU8 }
    |> Generate.map @ArbitraryU8

sizeHintU8 : Phantom ArbitraryU8, U64 -> Size.Hint
sizeHintU8 = \_, _ -> 1

ArbitraryStr := Str implements [
        Arbitrary {
            arbitrary: arbitraryStr,
            sizeHint: sizeHintStr,
        },
        Inspect,
    ]

unwrapStr : ArbitraryStr -> Str
unwrapStr = \@ArbitraryStr x -> x

arbitraryStr : Generator ArbitraryStr
arbitraryStr =
    Generate.string
    |> Generate.map @ArbitraryStr

sizeHintStr : Phantom ArbitraryStr, U64 -> Size.Hint
sizeHintStr = \_, _ -> 0

ArbitraryBytes := List U8 implements [
        Arbitrary {
            arbitrary: arbitraryBytes,
            sizeHint: sizeHintBytes,
        },
        Inspect,
    ]

unwrapBytes : ArbitraryBytes -> List U8
unwrapBytes = \@ArbitraryBytes x -> x

arbitraryBytes : Generator ArbitraryBytes
arbitraryBytes =
    Generate.bytes
    |> Generate.map @ArbitraryBytes

sizeHintBytes : Phantom ArbitraryBytes, U64 -> Size.Hint
sizeHintBytes = \_, _ -> 0

