app "basic"
    packages {
        fuzz: "../platform/main.roc",
    }
    imports [
        fuzz.Fuzz.{ Status, Target },
        fuzz.Arbitrary.{ ArbitraryU8, unwrapU8 },
    ]
    provides [target] to fuzz

target : Target ArbitraryU8
target = {
    name: "basic",
    test,
}

test : ArbitraryU8 -> Status
test = \byte ->
    if unwrapU8 byte == 'Q' then
        crash "this should be impossible"
    else
        Success
# if Str.startsWith str "Hi" then
#     crash "this should be impossible"
# else
#     Success
