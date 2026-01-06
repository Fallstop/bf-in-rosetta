open Common

let get_compiler Common.X86_64 = Intel_64_linux.get_generator

let rec get_asm level generator code =
  let { in_fn; out_fn; _ } = generator in
  match code with
  | In :: rest -> in_fn ^ "\n" ^ get_asm level generator rest
  | Out :: rest -> out_fn ^ "\n" ^ get_asm level generator rest
  | ActionGroup _ :: rest -> "; ActionGroup \n" ^ get_asm level generator rest
  | CloneBlock _ :: rest -> "; CloneBlock \n" ^ get_asm level generator rest
  | LoopStart :: rest -> "; CloneBlock \n" ^ get_asm level generator rest
  | LoopEnd :: rest -> "; CloneBlock \n" ^ get_asm level generator rest
  | Noop :: rest -> get_asm level generator rest
  | [] -> ""

let compile platform process_mode code =
  let generator = get_compiler platform process_mode in
  generator.header ^ get_asm 0 generator code ^ generator.footer
