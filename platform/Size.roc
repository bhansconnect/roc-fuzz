interface Size
    exposes [
        Hint,
        and,
        andAll,
        or,
        orAll,
        fromBytes,
    ]
    imports [
    ]

# Unlike the rust version of arbitrary, our size hint only tracks the minimum size.
# Looking over their code, the max size is not really used much in practicea and this simplifies the api.

## A rough estimate of the minimum number of bytes required to generate a type.
Hint := U64

fromBytes = @Hint

and : Hint, Hint -> Hint
and = \@Hint lhs, @Hint rhs ->
    @Hint (lhs + rhs)

andAll : List Hint -> Hint
andAll = \list ->
    List.walk list (@Hint 0) and

or : Hint, Hint -> Hint
or = \@Hint lhs, @Hint rhs ->
    @Hint (Num.min lhs rhs)

orAll : List Hint -> Hint
orAll = \list ->
    when list is
        [head, .. as rest] ->
            List.walk list head or

        [] ->
            @Hint 0
