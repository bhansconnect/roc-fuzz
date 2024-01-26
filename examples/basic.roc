app "basic"
    packages {
        fuzz: "../platform/main.roc",
    }
    imports [
        fuzz.Fuzz.{ Status, Target },
        fuzz.Arbitrary.{ ArbitraryStr, unwrapStr },
    ]
    provides [target] to fuzz

target : Target ArbitraryStr
target = {
    name: "basic",
    test,
}

test : ArbitraryStr -> Status
test = \data ->
    str = unwrapStr data
    if Str.startsWith str "FUZZ" then
        crash "this should be impossible"
    else
        Success
