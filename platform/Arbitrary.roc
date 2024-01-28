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
        ArbitraryI8,
        unwrapI8,
        ArbitraryU16,
        unwrapU16,
        ArbitraryI16,
        unwrapI16,
        ArbitraryU32,
        unwrapU32,
        ArbitraryI32,
        unwrapI32,
        ArbitraryU64,
        unwrapU64,
        ArbitraryI64,
        unwrapI64,
        ArbitraryU128,
        unwrapU128,
        ArbitraryI128,
        unwrapI128,
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

ArbitraryI8 := I8 implements [
        Arbitrary {
            arbitrary: arbitraryI8,
            sizeHint: sizeHintI8,
        },
        Inspect,
    ]

unwrapI8 : ArbitraryI8 -> I8
unwrapI8 = \@ArbitraryI8 x -> x

arbitraryI8 : Generator ArbitraryI8
arbitraryI8 =
    Generate.i8Between { startAt: Num.minI8, endAt: Num.maxI8 }
    |> Generate.map @ArbitraryI8

sizeHintI8 : Phantom ArbitraryI8, U64 -> Size.Hint
sizeHintI8 = \_, _ -> 1

ArbitraryU16 := U16 implements [
        Arbitrary {
            arbitrary: arbitraryU16,
            sizeHint: sizeHintU16,
        },
        Inspect,
    ]

unwrapU16 : ArbitraryU16 -> U16
unwrapU16 = \@ArbitraryU16 x -> x

arbitraryU16 : Generator ArbitraryU16
arbitraryU16 =
    Generate.u16Between { startAt: Num.minU16, endAt: Num.maxU16 }
    |> Generate.map @ArbitraryU16

sizeHintU16 : Phantom ArbitraryU16, U64 -> Size.Hint
sizeHintU16 = \_, _ -> 1

ArbitraryI16 := I16 implements [
        Arbitrary {
            arbitrary: arbitraryI16,
            sizeHint: sizeHintI16,
        },
        Inspect,
    ]

unwrapI16 : ArbitraryI16 -> I16
unwrapI16 = \@ArbitraryI16 x -> x

arbitraryI16 : Generator ArbitraryI16
arbitraryI16 =
    Generate.i16Between { startAt: Num.minI16, endAt: Num.maxI16 }
    |> Generate.map @ArbitraryI16

sizeHintI16 : Phantom ArbitraryI16, U64 -> Size.Hint
sizeHintI16 = \_, _ -> 1

ArbitraryU32 := U32 implements [
        Arbitrary {
            arbitrary: arbitraryU32,
            sizeHint: sizeHintU32,
        },
        Inspect,
    ]

unwrapU32 : ArbitraryU32 -> U32
unwrapU32 = \@ArbitraryU32 x -> x

arbitraryU32 : Generator ArbitraryU32
arbitraryU32 =
    Generate.u32Between { startAt: Num.minU32, endAt: Num.maxU32 }
    |> Generate.map @ArbitraryU32

sizeHintU32 : Phantom ArbitraryU32, U64 -> Size.Hint
sizeHintU32 = \_, _ -> 1

ArbitraryI32 := I32 implements [
        Arbitrary {
            arbitrary: arbitraryI32,
            sizeHint: sizeHintI32,
        },
        Inspect,
    ]

unwrapI32 : ArbitraryI32 -> I32
unwrapI32 = \@ArbitraryI32 x -> x

arbitraryI32 : Generator ArbitraryI32
arbitraryI32 =
    Generate.i32Between { startAt: Num.minI32, endAt: Num.maxI32 }
    |> Generate.map @ArbitraryI32

sizeHintI32 : Phantom ArbitraryI32, U64 -> Size.Hint
sizeHintI32 = \_, _ -> 1

ArbitraryU64 := U64 implements [
        Arbitrary {
            arbitrary: arbitraryU64,
            sizeHint: sizeHintU64,
        },
        Inspect,
    ]

unwrapU64 : ArbitraryU64 -> U64
unwrapU64 = \@ArbitraryU64 x -> x

arbitraryU64 : Generator ArbitraryU64
arbitraryU64 =
    Generate.u64Between { startAt: Num.minU64, endAt: Num.maxU64 }
    |> Generate.map @ArbitraryU64

sizeHintU64 : Phantom ArbitraryU64, U64 -> Size.Hint
sizeHintU64 = \_, _ -> 1

ArbitraryI64 := I64 implements [
        Arbitrary {
            arbitrary: arbitraryI64,
            sizeHint: sizeHintI64,
        },
        Inspect,
    ]

unwrapI64 : ArbitraryI64 -> I64
unwrapI64 = \@ArbitraryI64 x -> x

arbitraryI64 : Generator ArbitraryI64
arbitraryI64 =
    Generate.i64Between { startAt: Num.minI64, endAt: Num.maxI64 }
    |> Generate.map @ArbitraryI64

sizeHintI64 : Phantom ArbitraryI64, U64 -> Size.Hint
sizeHintI64 = \_, _ -> 1

ArbitraryU128 := U128 implements [
        Arbitrary {
            arbitrary: arbitraryU128,
            sizeHint: sizeHintU128,
        },
        Inspect,
    ]

unwrapU128 : ArbitraryU128 -> U128
unwrapU128 = \@ArbitraryU128 x -> x

arbitraryU128 : Generator ArbitraryU128
arbitraryU128 =
    Generate.u128Between { startAt: Num.minU128, endAt: Num.maxU128 }
    |> Generate.map @ArbitraryU128

sizeHintU128 : Phantom ArbitraryU128, U64 -> Size.Hint
sizeHintU128 = \_, _ -> 1

ArbitraryI128 := I128 implements [
        Arbitrary {
            arbitrary: arbitraryI128,
            sizeHint: sizeHintI128,
        },
        Inspect,
    ]

unwrapI128 : ArbitraryI128 -> I128
unwrapI128 = \@ArbitraryI128 x -> x

arbitraryI128 : Generator ArbitraryI128
arbitraryI128 =
    Generate.i128Between { startAt: Num.minI128, endAt: Num.maxI128 }
    |> Generate.map @ArbitraryI128

sizeHintI128 : Phantom ArbitraryI128, U64 -> Size.Hint
sizeHintI128 = \_, _ -> 1

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

