app "basic"
    packages {
        fuzz: "../platform/main.roc",
    }
    imports [
        fuzz.Fuzz.{ Status, Target },
        fuzz.Arbitrary.{ Generator, andThen },
    ]
    provides [target] to fuzz

target : Target (U8, U8, U8, U8)
target = {
    generator,
    test,
}

generator : Generator (U8, U8, U8, U8)
generator =
    a <- Arbitrary.u8 |> andThen
    b <- Arbitrary.u8 |> andThen
    c <- Arbitrary.u8 |> andThen
    d <- Arbitrary.u8 |> andThen
    Arbitrary.value (a, b, c, d)

test = \data ->
    when data is
        ('F', 'U', 'Z', 'Z') ->
            crash "this should be impossible"

        ('Q', _, _, _) ->
            Ignore

        _ ->
            Success
