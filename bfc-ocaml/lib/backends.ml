open Common

let get_compiler Common.X86_64 = Intel_64_linux.get_generator

let rec get_asm level generator code =
  let { in_fn; out_fn; action_group_fn; clone_block_fn; _ } = generator in
  match code with
  | In :: rest -> in_fn ^ "\n" ^ get_asm level generator rest
  | Out :: rest -> out_fn ^ "\n" ^ get_asm level generator rest
  | ActionGroup ag :: rest -> action_group_fn ag ^ get_asm level generator rest
  | CloneBlock cb :: rest -> clone_block_fn cb ^ get_asm level generator rest
  | LoopStart :: rest -> "; LoopStart \n" ^ get_asm level generator rest
  | LoopEnd :: rest -> "; LoopEnd \n" ^ get_asm level generator rest
  | Noop :: rest -> get_asm level generator rest
  | [] -> ""

let compile platform process_mode code =
  let generator = get_compiler platform process_mode in
  generator.header ^ get_asm 0 generator code ^ generator.footer
