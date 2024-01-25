interface Fuzz
    exposes [Status, Target]
    imports [
        Arbitrary.{ Generator },
    ]

Status : [Success, Ignore]

Target a : {
    generator : Generator a,
    test : a -> Status,
}
