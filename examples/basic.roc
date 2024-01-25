app "basic"
    packages {
        fuzz: "../platform/main.roc",
    }
    imports [
        fuzz.Fuzz.{ Status },
    ]
    provides [main] to fuzz

main : List U8 -> Status
main = \data ->
    when List.get data 0 is
        Ok 'F' ->
            when List.get data 1 is
                Ok 'U' ->
                    when List.get data 2 is
                        Ok 'Z' ->
                            when List.get data 3 is
                                Ok 'Z' ->
                                    crash "This should be impossible"
                                _ ->
                                    Success
                        _ ->
                            Success
                _ ->
                    Success
        Ok 'Q' ->
            # We don't want any inputs starting with 'Q'
            Ignore
        _ ->
            Success
