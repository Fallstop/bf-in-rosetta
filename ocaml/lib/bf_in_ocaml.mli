val run :
  string ->
  ('a -> 'a) ->
  ('a -> 'a) ->
  (unit -> 'a) ->
  ('a -> unit) ->
  'a ->
  'a ->
  char list * 'a list * int

val run_char : string -> char list * char list * int
val run_int : string -> char list * int list * int
