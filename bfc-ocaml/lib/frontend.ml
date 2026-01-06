type action_group = {
  (* Where should the memory pointer be positioned relative to the current *)
  start : int;
  (* What element are we currently pointing to. *)
  current : int;
  (* The list of opperations that should be applied. *)
  values : int array;
}

type clone_block = {
  (* The start of the interest *)
  start : int;
  (* The position that acts as the counter *)
  from : int;
  (* The multiples that have the values *)
  values : int list;
}

type operation =
  | Noop
  | Out
  | In
  | LoopStart
  | LoopEnd
  | ActionGroup of action_group
  | CloneBlock of clone_block

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

let is_copy_ag (ag : action_group) =
  ag.values |> Array.to_seq |> Seq.filter (fun x -> x == -1) |> Seq.length = 1

let rec opt operations =
  match operations with
  | LoopStart :: ActionGroup ag :: LoopEnd :: rest
    when ag.current + ag.start = 0 && is_copy_ag ag ->
      let start_point = Array.find_index (Repr.equal (-1)) ag.values in
      CloneBlock
        {
          values = ag.values |> Array.map (max 0) |> Array.to_list;
          from = Option.get start_point;
          start = ag.current;
        }
      :: opt rest
  | curr :: rest -> curr :: opt rest
  | [] -> []

let get_operations code =
  let exploded = List.init (String.length code) (String.get code) in
  get_next exploded Noop [] |> List.rev |> opt

let file = "../helloWorld.bf"

let source =
  let ic = open_in file in
  try
    let s = really_input_string ic (in_channel_length ic) in
    close_in ic;
    s
  with _ ->
    close_in ic;
    print_string "Oh fuck";
    ""
