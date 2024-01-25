interface Fuzz
    exposes [Status, Target]
    imports [
        Arbitrary.{ Generator },
    ]

Status : [Success, Ignore]

Target a : {
    name : Str,
    generator : Generator a,
    test : a -> Status,
}
