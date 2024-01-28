interface Generate
    exposes [
        Generator,
        State,
        Error,
        apply,
        andThen,
        map,
        custom,
        bytes,
        string,
        u8Between,
        i8Between,
        u16Between,
        i16Between,
        u32Between,
        i32Between,
        u64Between,
        i64Between,
        u128Between,
        i128Between,
    ]
    imports [
    ]

State := List U8

Error : [EmptyChoose, NotEnoughData, IncorrectFormat]

Generator a := State -> Result (a, State) Error

custom = @Generator

apply : List U8, Generator a -> Result a Error
apply = \data, @Generator gen ->
    data
    |> @State
    |> gen
    |> Result.map .0

andThen : Generator a, (a -> Generator b) -> Generator b
andThen = \@Generator first, transform ->
    @Generator \state ->
        (val, next) <- first state |> Result.try
        (@Generator second) = transform val
        second next

map : Generator a, (a -> b) -> Generator b
map = \@Generator first, transform ->
    @Generator \state ->
        (val, next) <- first state |> Result.map
        (transform val, next)

bytes : Generator (List U8)
bytes = @Generator \state ->
    (size, @State data) = byteSize state
    { before, others: rest } = List.split data (Num.toNat size)
    Ok (before, @State rest)

expect
    res =
        [2, 4, 5, 6, 9, 27]
        |> apply bytes
    res == Ok [2, 4, 5]

string : Generator Str
string = @Generator \state ->
    (size, @State data) = byteSize state
    { before: fullBytes, others: fullRest } = List.split data (Num.toNat size)
    when Str.fromUtf8 fullBytes is
        Ok str ->
            Ok (str, @State fullRest)

        Err (BadUtf8 _ goodSize) ->
            # Even though this failed, we can still parse the utf8 up to this size.
            # we didn't use all bytes, so reclaim some of them.
            { before: retryBytes, others: retryRest } = List.split data goodSize
            when Str.fromUtf8 retryBytes is
                Ok str ->
                    Ok (str, @State retryRest)

                Err _ -> crash "This subset of the string should be valid for conversion to utf8"

expect
    res =
        ['a', 'b', 'c', 6, 9, 27]
        |> apply string
    res == Ok "abc"

expect
    res =
        ['a', 'b', 255, 6, 9, 27]
        |> apply string
    res == Ok "ab"

# Technically, it would be best to make generators for full range integers that just grab all of the bytes.

u8Between : { startAt : U8, endAt : U8 } -> Generator U8
u8Between = \{ startAt, endAt } ->
    @Generator \state ->
        unsignedBetween state startAt endAt
        |> Ok

i8Between : { startAt : I8, endAt : I8 } -> Generator I8
i8Between = \{ startAt, endAt } ->
    u8Between { startAt: Num.intCast startAt, endAt: Num.intCast endAt }
    |> map Num.intCast

u16Between : { startAt : U16, endAt : U16 } -> Generator U16
u16Between = \{ startAt, endAt } ->
    @Generator \state ->
        unsignedBetween state startAt endAt
        |> Ok

i16Between : { startAt : I16, endAt : I16 } -> Generator I16
i16Between = \{ startAt, endAt } ->
    u16Between { startAt: Num.intCast startAt, endAt: Num.intCast endAt }
    |> map Num.intCast

u32Between : { startAt : U32, endAt : U32 } -> Generator U32
u32Between = \{ startAt, endAt } ->
    @Generator \state ->
        unsignedBetween state startAt endAt
        |> Ok

i32Between : { startAt : I32, endAt : I32 } -> Generator I32
i32Between = \{ startAt, endAt } ->
    u32Between { startAt: Num.intCast startAt, endAt: Num.intCast endAt }
    |> map Num.intCast

u64Between : { startAt : U64, endAt : U64 } -> Generator U64
u64Between = \{ startAt, endAt } ->
    @Generator \state ->
        unsignedBetween state startAt endAt
        |> Ok

i64Between : { startAt : I64, endAt : I64 } -> Generator I64
i64Between = \{ startAt, endAt } ->
    u64Between { startAt: Num.intCast startAt, endAt: Num.intCast endAt }
    |> map Num.intCast

u128Between : { startAt : U128, endAt : U128 } -> Generator U128
u128Between = \{ startAt, endAt } ->
    @Generator \state ->
        unsignedBetween state startAt endAt
        |> Ok

i128Between : { startAt : I128, endAt : I128 } -> Generator I128
i128Between = \{ startAt, endAt } ->
    u128Between { startAt: Num.intCast startAt, endAt: Num.intCast endAt }
    |> map Num.intCast

# ===== Internal Helpers ======================================================

byteSize : State -> (U64, State)
byteSize = \@State data ->
    if List.len data <= 1 then
        (0, @State data)
    else
        # Take the length from the end of the data.
        # This helps fuzzers more efficiently explore the input space.
        # We only consume as many data as necessary to cover the entire range of the byte string.
        # Note: We cast to u64 so we don't overflow when checking std::u32::MAX + 4 on 32-bit archs.
        dataLen = List.len data
        if Num.toU64 dataLen <= 0xFF + 1 then
            numBytes = 1
            maxLen = dataLen - numBytes
            { before, others } = List.split data maxLen
            (size, _) = unsignedBetween (@State others) 0 (Num.toU64 maxLen)
            (size, @State before)
        else if Num.toU64 dataLen <= 0xFFFF + 1 then
            numBytes = 2
            maxLen = dataLen - numBytes
            { before, others } = List.split data maxLen
            (size, _) = unsignedBetween (@State others) 0 (Num.toU64 maxLen)
            (size, @State before)
        else if Num.toU64 dataLen <= 0xFFFF_FFFF + 1 then
            numBytes = 4
            maxLen = dataLen - numBytes
            { before, others } = List.split data maxLen
            (size, _) = unsignedBetween (@State others) 0 (Num.toU64 maxLen)
            (size, @State before)
        else
            numBytes = 8
            maxLen = dataLen - numBytes
            { before, others } = List.split data maxLen
            (size, _) = unsignedBetween (@State others) 0 (Num.toU64 maxLen)
            (size, @State before)

expect
    (size, _) =
        @State []
        |> byteSize

    size == 0

expect
    (size, _) =
        @State [2, 4, 5, 6, 9]
        |> byteSize
    size == 4

expect
    (size, _) =
        @State [2, 4, 5, 6, 9, 27]
        |> byteSize
    size == 3

expect
    (size, _) =
        List.repeat 0 300
        |> List.append 77
        |> @State
        |> byteSize
    size == 77

expect
    (size, _) =
        List.repeat 0 0x0FFF
        |> List.append 0x12
        |> List.append 0x34
        |> @State
        |> byteSize
    size == 0x0234

expect
    (size, _) =
        List.repeat 0 0x2000
        |> List.append 0x12
        |> List.append 0x34
        |> @State
        |> byteSize
    size == 0x1234

# This fill only work correctly for the unsigned Numbers
# It also is inclusive of the end.
# unsignedBetween : State, Int a, Int a -> (Int a, State)
unsignedBetween = \@State data, start, end ->
    if start > end then
        crash "intBetween requires a non-empty range"
    else if start == end then
        # Don't waste entropy when there is only one option
        (start, @State data)
    else
        delta = Num.subWrap end start
        genInt = \b, current, bytesConsumed ->
            when List.first b is
                Ok x ->
                    next = Num.bitwiseOr (Num.shiftLeftBy current 8) (Num.intCast x)
                    nextBytesConsumed = bytesConsumed + 1
                    if (Num.shiftRightZfBy delta (8 * nextBytesConsumed) > 0) then
                        # still need to consume more bytes to fill delta.
                        genInt (List.dropFirst b 1) next nextBytesConsumed
                    else
                        # consumed enough bytes to fill delta
                        (next, List.dropFirst b 1)

                Err _ ->
                    (current, b)
        (val, rest) = genInt data 0 0
        offset =
            when Num.addChecked delta 1 is
                Ok y ->
                    val % y

                Err _ ->
                    # This will only happen when delta represents the entire integers range.
                    val
        result = Num.addWrap start offset

        (result, @State rest)

expect
    (res, _) = unsignedBetween (@State [1, 2, 3, 4]) 0u8 10u8
    res == 1

expect
    (res, _) = unsignedBetween (@State [1, 2, 3, 4]) 0u8 Num.maxU8
    res == 1

expect
    (res, _) = unsignedBetween (@State [1, 2, 3, 4]) 10u8 12u8
    res == 11

expect
    (res, _) = unsignedBetween (@State [1, 2, 3, 4]) 0u16 128u16
    res == 1

expect
    (res, _) = unsignedBetween (@State [1, 2, 3, 4]) 0u32 Num.maxU32
    res == 0x01020304
