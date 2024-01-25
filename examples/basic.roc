app "basic"
    packages {
        fuzz: "../platform/main.roc",
    }
    imports [
        fuzz.Fuzz.{ Status, Target },
        fuzz.Arbitrary.{ Generator },
    ]
    provides [target] to fuzz

target : Target Str
target = {
    name: "basic",
    generator,
    test,
}

generator : Generator Str
generator = Arbitrary.string

test : Str -> Status
test = \str ->
    if Str.startsWith str "Hi" then
        crash "this should be impossible"
    else
        Success
