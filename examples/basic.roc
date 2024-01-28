app "basic"
    packages {
        fuzz: "../platform/main.roc",
    }
    imports [
        fuzz.Fuzz.{ Status, Target },
        fuzz.Arbitrary.{ ArbitraryBytes, unwrapBytes },
    ]
    provides [target] to fuzz

target : Target ArbitraryBytes
target = {
    name: "basic",
    test,
}

test : ArbitraryBytes -> Status
test = \data ->
    bytes = unwrapBytes data
    when bytes is
        ['F', 'U', 'Z', 'Z', ..] ->
            crash "this should be impossible"
        _ ->
            Success
