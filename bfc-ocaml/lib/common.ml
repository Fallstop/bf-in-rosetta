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

(* Compilation options *)

type platform = X86_64
type process_mode = Ascii

type generator = {
  header : string;
  in_fn : string;
  out_fn : string;
  action_group_fn : action_group -> string;
  clone_block_fn : clone_block -> string;
  footer : string;
}

let test_script =
  "+++++ +++++             initialize counter (cell #0) to 10\n\
   [                       use loop to set the next four cells to 70/100/30/10\n\
   > +++++ ++              add  7 to cell #1\n\
   > +++++ +++++           add 10 to cell #2\n\
   > +++                   add  3 to cell #3\n\
   > +                     add  1 to cell #4\n\
   <<<< -                  decrement counter (cell #0)\n\
   ]\n\
   > ++ .                  print 'H'\n\
   > + .                   print 'e'\n\
   +++++ ++ .              print 'l'\n\
   .                       print 'l'\n\
   +++ .                   print 'o'\n\
   > ++ .                  print ' '\n\
   << +++++ +++++ +++++ .  print 'W'\n\
   > .                     print 'o'\n\
   +++ .                   print 'r'\n\
   ----- - .               print 'l'\n\
   ----- --- .             print 'd'\n\
   > + .                   print '!'\n\
   > .                     print '\n\
   '\n\
   How to use the interpreter:\n\n"
