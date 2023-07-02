type mode = Ascii | Int

let run mode source =
  let ic = open_in source in
  try
    let source = really_input_string ic (in_channel_length ic) in
    close_in ic;
    match mode with
    | Ascii -> ignore (Bf_in_ocaml.run_char source)
    | Int -> ignore (Bf_in_ocaml.run_int source)
  with _ -> close_in ic

open Cmdliner

let source =
  let doc = "The brainfuck sourcu to be interperned" in
  Arg.(required & pos ~rev:true 0 (some string) None & info [] ~doc)

let mode =
  let ascii =
    let doc = "Run the interpperter in ASCII mode" in
    (Ascii, Arg.info [ "a"; "ascii" ] ~doc)
  in
  let integer =
    let doc = "Run the interpperter in ASCII mode" in
    (Int, Arg.info [ "i"; "int" ] ~doc)
  in

  Arg.(last & vflag_all [ Ascii ] [ ascii; integer ])

let cmd =
  let doc = "Pain and suffering" in
  let man = [] in
  let info = Cmd.info "bf" ~version:"%%VERSION%%" ~doc ~man in
  Cmd.v info Term.(const run $ mode $ source)

let main () = exit (Cmd.eval cmd)
let () = main ()
