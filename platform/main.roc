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

Command : [
    Fuzz,
    Show,
]

mainForHost : List U8, Command -> (List U8, I8)
mainForHost = \bytes, cmd ->
    when cmd is
        Fuzz ->
            data = Arbitrary.generate bytes target.generator
            when target.test data is
                Success ->
                    ([], 0)

                Ignore ->
                    ([], -1)

        Show ->
            data = Arbitrary.generate bytes target.generator
            str = Inspect.toStr data
            (Str.toUtf8 str, 0)

