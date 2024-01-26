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
        Generate,
    ]
    provides [mainForHost]

Command : [
    Fuzz,
    Name,
    Show,
]

mainForHost : List U8, Command -> (Str, I8)
mainForHost = \bytes, cmd ->
    res = Generate.apply bytes Arbitrary.arbitrary
    when cmd is
        Fuzz ->
            when res is
                Ok data ->
                    when target.test data is
                        Success ->
                            ("", 0)

                        Ignore ->
                            ("", -1)

                Err _ ->
                    ("", -1)

        Name ->
            (target.name, 0)

        Show ->
            when res is
                Ok data ->
                    str = Inspect.toStr data
                    (str, 0)

                Err _ ->
                    crash "Failed to generate data from test case"

