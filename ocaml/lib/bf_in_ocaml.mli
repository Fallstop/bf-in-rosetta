val run :
  string ->
  ('a -> 'a) ->
  ('a -> 'a) ->
  (unit -> 'a) ->
  ('a -> unit) ->
  'a ->
  'a ->
  char list * 'a array * int

val run_char : string -> char list * char array * int
val run_int : string -> char list * int array * int
