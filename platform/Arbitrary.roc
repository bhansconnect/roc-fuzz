interface Arbitrary
    exposes [State, Generator, u8, custom, andThen, map, generate, value]
    imports []

State := List U8

Generator a := State -> (a, State)

custom = @Generator

value : a -> Generator a
value = \val ->
    @Generator \state ->
        (val, state)

u8 : Generator U8
u8 = @Generator \@State bytes ->
    when bytes is
        [b0, .. as rest] ->
            (b0, @State rest)

        [] ->
            (0, @State [])

andThen : Generator a, (a -> Generator b) -> Generator b
andThen = \@Generator first, transform ->
    @Generator \state ->
        (val, next) = first state
        (@Generator second) = transform val
        second next

map : Generator a, (a -> b) -> Generator b
map = \@Generator first, transform ->
    @Generator \state ->
        (val, next) = first state
        (transform val, next)

generate : List U8, Generator a -> a
generate = \bytes, @Generator gen ->
    bytes
    |> @State
    |> gen
    |> .0

