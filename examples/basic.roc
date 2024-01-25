app "basic"
    packages {
        fuzz: "../platform/main.roc",
    }
    imports [
        fuzz.Fuzz.{ Status, Target },
        fuzz.Arbitrary.{ Generator, andThen },
    ]
    provides [target] to fuzz

target : Target (Str, U8)
target = {
    generator,
    test,
}

generator : Generator (Str, U8)
generator =
    str <- Arbitrary.string |> andThen
    n <- Arbitrary.u8 |> andThen
    Arbitrary.value (str, n)

test : (Str, U8) -> Status
test = \(str, n) ->
    if Str.startsWith str "FUZZ" && n == 42 then
        crash "this should be impossible"
    else if Str.startsWith str "Q" then
        # All cases that start with 'Q' are invalid. Ignore them.
        Ignore
    else
        Success
