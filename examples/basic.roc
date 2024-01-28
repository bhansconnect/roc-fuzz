app "basic"
    packages {
        fuzz: "../platform/main.roc",
    }
    imports [
        fuzz.Fuzz.{ Status, Target },
        fuzz.Arbitrary.{ ArbitraryBytes, unwrapBytes },
        # These two imports are required to work around a roc bug.
        fuzz.Generate,
        fuzz.Size,
    ]
    provides [target] to fuzz

expect Generate.importDummy == Size.importDummy

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

