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

val get_operations : string -> operation list
