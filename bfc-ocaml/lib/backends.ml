open Common

let get_compiler Common.X86_64 = Intel_64_linux.get_generator

let rec get_asm level generator code =
  let {
    in_fn;
    out_fn;
    action_group_fn;
    clone_block_fn;
    comment_fn;
    loop_start_fn;
    loop_end_fn;
    _;
  } =
    generator
  in

  match code with
  | inner :: rest -> (
      comment_fn (op_to_string inner)
      ^
      match inner with
      | In -> in_fn ^ get_asm level generator rest
      | Out -> out_fn ^ get_asm level generator rest
      | ActionGroup ag -> action_group_fn ag ^ get_asm level generator rest
      | CloneBlock cb -> clone_block_fn cb ^ get_asm level generator rest
      | LoopStart n -> loop_start_fn n ^ get_asm level generator rest
      | LoopEnd n -> loop_end_fn n ^ get_asm level generator rest
      | Noop -> get_asm level generator rest)
  | [] -> ""

let compile platform process_mode code =
  let generator = get_compiler platform process_mode in
  generator.header ^ get_asm 0 generator code ^ generator.footer
  |> generator.finalize
