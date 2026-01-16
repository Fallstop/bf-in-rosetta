open Common

let apply_2 f (a, b) = f a b

let rec get_plus code current items =
  (match current with
    | ActionGroup ag ->
        ag.values.(ag.current) <- 1 + ag.values.(ag.current);
        (ActionGroup { ag with current = ag.current }, items)
    | _ ->
        ( ActionGroup { values = [| 1 |]; current = 0; start = 0 },
          current :: items ))
  |> apply_2 (get_next code)

and get_minus code current items =
  (match current with
    | ActionGroup ag ->
        ag.values.(ag.current) <- ag.values.(ag.current) - 1;
        (ActionGroup { ag with current = ag.current }, items)
    | _ ->
        ( ActionGroup { values = [| -1 |]; current = 0; start = 0 },
          current :: items ))
  |> apply_2 (get_next code)

and get_left code current items =
  (match current with
    | ActionGroup ag when ag.current > 0 ->
        (ActionGroup { ag with current = ag.current - 1 }, items)
    | ActionGroup ag ->
        ( ActionGroup
            {
              current = 0;
              start = ag.start - 1;
              values = Array.concat [ [| 0 |]; ag.values ];
            },
          items )
    | _ ->
        ( ActionGroup { current = 0; start = -1; values = [| 0 |] },
          current :: items ))
  |> apply_2 (get_next code)

and get_right code current items =
  (match current with
    | ActionGroup ag when ag.current < Array.length ag.values - 1 ->
        (ActionGroup { ag with current = ag.current + 1 }, items)
    | ActionGroup ag ->
        ( ActionGroup
            {
              current = ag.current + 1;
              start = ag.start;
              values = Array.concat [ ag.values; [| 0 |] ];
            },
          items )
    | _ ->
        ( ActionGroup { current = 0; start = 1; values = [| 0 |] },
          current :: items ))
  |> apply_2 (get_next code)

and get_out code current items = get_next code Out (current :: items)
and get_in code current items = get_next code In (current :: items)

and get_start_loop code current items =
  get_next code (LoopStart 0) (current :: items)

and get_end_loop code current items =
  get_next code (LoopEnd 0) (current :: items)

and get_next code current items =
  match code with
  | a :: rest ->
      (match a with
      | '+' -> get_plus
      | '-' -> get_minus
      | '<' -> get_left
      | '>' -> get_right
      | '.' -> get_out
      | ',' -> get_in
      | '[' -> get_start_loop
      | ']' -> get_end_loop
      | _ -> get_next)
        rest current items
  | [] -> current :: items

let is_copy_ag (ag : action_group) =
  ag.values |> Array.to_seq |> Seq.filter (fun x -> x == -1) |> Seq.length = 1

let rec opt operations =
  match operations with
  | LoopStart _ :: ActionGroup ag :: LoopEnd _ :: rest
    when ag.current + ag.start = 0 && is_copy_ag ag ->
      let start_point = Array.find_index (Repr.equal (-1)) ag.values in
      CloneBlock
        {
          values = ag.values |> Array.map (max 0) |> Array.to_list;
          from = Option.get start_point;
          start = ag.start;
        }
      :: opt rest
  | curr :: rest -> curr :: opt rest
  | [] -> []

let rec match_braces levels max_level code =
  let next_level = max_level + 1 in
  match code with
  | LoopStart _ :: rest ->
      LoopStart next_level
      :: match_braces (next_level :: levels) next_level rest
  | LoopEnd _ :: rest -> (
      match levels with
      | current_level :: other_levels ->
          LoopEnd current_level :: match_braces other_levels max_level rest
      | [] -> assert false)
  | x :: rest -> x :: match_braces levels max_level rest
  | [] -> []

let get_operations code =
  let exploded = List.init (String.length code) (String.get code) in
  get_next exploded Noop [] |> List.rev |> opt |> match_braces [] 0
