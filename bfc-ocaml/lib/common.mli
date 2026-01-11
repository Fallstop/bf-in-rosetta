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
  | LoopStart of int
  | LoopEnd of int
  | ActionGroup of action_group
  | CloneBlock of clone_block

(* Compilation options *)

type platform = X86_64
type process_mode = Ascii | U8

type generator = {
  header : string;
  in_fn : string;
  out_fn : string;
  action_group_fn : action_group -> string;
  clone_block_fn : clone_block -> string;
  loop_start_fn : int -> string;
  loop_end_fn : int -> string;
  comment_fn : string -> string;
  footer : string;
}

val op_to_string : operation -> string
