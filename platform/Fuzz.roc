interface Fuzz
    exposes [Status, Target]
    imports [
        Arbitrary.{ Arbitrary },
    ]

Status : [Success, Ignore]

Target a : {
    name : Str,
    test : a -> Status,
} where a implements Arbitrary
