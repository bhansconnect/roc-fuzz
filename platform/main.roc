platform "roc-fuzz"
    requires {} { target : Fuzz.Target a }
    exposes [
        Fuzz,
        Arbitrary,
    ]
    packages {}
    imports [
        Arbitrary,
        Fuzz,
    ]
    provides [mainForHost]

mainForHost : List U8 -> I8
mainForHost = \bytes ->
    data = Arbitrary.generate bytes target.generator
    when target.test data is
        Success -> 0
        Ignore -> -1
