app "basic"
    packages {
        fuzz: "../platform/main.roc",
    }
    imports [
        fuzz.Fuzz.{ Status, Target },
        fuzz.Arbitrary.{ Generator, andThen },
    ]
    provides [target] to fuzz

target : Target (List U8, U8)
target = {
    generator,
    test,
}

generator : Generator (List U8, U8)
generator =
    bytes <- Arbitrary.bytes |> andThen
    n <- Arbitrary.u8 |> andThen
    Arbitrary.value (bytes, n)

test : (List U8, U8) -> Status
test = \data ->
    when data is
        (['F', 'U', 'Z', 'Z', ..], 42) ->
            crash "this should be impossible"

        (['Q', ..], _) ->
            # All cases that start with 'Q' are invalid. Ignore them.
            Ignore

        _ ->
            Success
