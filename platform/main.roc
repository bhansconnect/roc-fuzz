platform "roc-fuzz"
    requires {} { main : List U8 -> Status }
    exposes [
        Fuzz,
    ]
    packages {}
    imports [Fuzz.{ Status }]
    provides [mainForHost]



mainForHost : List U8 -> I8
mainForHost = \x ->
    when main x is
        Success -> 0
        Failure -> 1
        Ignore -> -1
