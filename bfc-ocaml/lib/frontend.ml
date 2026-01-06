type operation =
  | Noop
  | Out
  | In
  | LoopStart
  | LoopEnd
  | ActionGroup of {
      (* Where should the memory pointer be positioned relative to the current *)
      start : int;
      (* Relitave to the position of the last operation, where should the memory pointer end up *)
      offset : int;
      (* What element are we currently pointing to. *)
      current : int;
      (* The list of opperations that should be applied. *)
      values : int array;
    }

let apply_2 f (a, b) = f a b

let rec get_plus code current items =
  (match current with
    | ActionGroup ag ->
        ag.values.(ag.current) <- 1 + ag.values.(ag.current);
        (ActionGroup { ag with current = ag.current }, items)
    | _ ->
        ( ActionGroup
            { values = Array.make 1 1; current = 0; offset = 0; start = 0 },
          current :: items ))
  |> apply_2 (get_next code)

and get_minus code current items =
  (match current with
    | ActionGroup ag ->
        ag.values.(ag.current) <- 1 - ag.values.(ag.current);
        (ActionGroup { ag with current = ag.current }, items)
    | _ ->
        ( ActionGroup
            { values = Array.make 1 (-1); current = 0; offset = 0; start = 0 },
          current :: items ))
  |> apply_2 (get_next code)

and get_left code current items =
  (match current with
    | ActionGroup ag when ag.current > 0 ->
        ( ActionGroup
            { ag with current = ag.current - 1; offset = ag.offset - 1 },
          items )
    | ActionGroup ag ->
        ( ActionGroup
            {
              current = 0;
              offset = ag.offset - 1;
              start = ag.start - 1;
              values = Array.concat [ Array.make 1 0; ag.values ];
            },
          items )
    | _ -> (Noop, items))
  |> apply_2 (get_next code)

and get_right code current items =
  (match current with
    | ActionGroup ag when ag.current < Array.length ag.values - 1 ->
        ( ActionGroup
            { ag with current = ag.current + 1; offset = ag.offset + 1 },
          items )
    | ActionGroup ag ->
        ( ActionGroup
            {
              current = ag.current + 1;
              offset = ag.offset + 1;
              start = ag.start + 1;
              values = Array.concat [ ag.values; Array.make 1 0 ];
            },
          items )
    | _ -> (Noop, items))
  |> apply_2 (get_next code)

and get_out code current items = get_next code Out (current :: items)
and get_in code current items = get_next code In (current :: items)

and get_start_loop code current items =
  get_next code LoopStart (current :: items)

and get_end_loop code current items = get_next code LoopEnd (current :: items)

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

let get_operations code =
  let exploded =
    let rec exp i l = if i < 0 then l else exp (i - 1) (code.[i] :: l) in
    exp (String.length code - 1) []
  in
  get_next exploded Noop [] |> List.rev
