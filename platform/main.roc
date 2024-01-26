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

MagicType a : {
    target : Fuzz.Target a,
    phantom : Arbitrary.Phantom a,
    gen : Generate.Generator a,
}

mainForHost : List U8, Command -> (Str, I8)
mainForHost = \bytes, cmd ->
    m : MagicType a
    m = {
        target,
        phantom: Arbitrary.phantom,
        gen: Arbitrary.arbitrary,
    }
    when cmd is
        Fuzz ->
            # Early exit if we don't have enough bytes for the `Arbitrary`
            # implementation. This helps the fuzzer avoid exploring all the
            # different not-enough-input-bytes paths inside the `Arbitrary`
            # implementation. Additionally, it exits faster, letting the fuzzer
            # get to longer inputs that actually lead to interesting executions
            # quicker.
            minSize = Arbitrary.sizeHint m.phantom 0
            if Num.intCast (List.len bytes) < minSize then
                ("", -1)
            else
                res = Generate.apply bytes m.gen
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
            res = Generate.apply bytes m.gen
            when res is
                Ok data ->
                    str = Inspect.toStr data
                    (str, 0)

                Err _ ->
                    crash "Failed to generate data from test case"

