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

val get_operations : string -> operation list
