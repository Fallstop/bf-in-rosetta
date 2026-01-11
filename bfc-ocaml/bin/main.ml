open Bfc_ocaml
open Bfc_ocaml.Common

let run mode source =
  let ic = open_in source in
  try
    let source = really_input_string ic (in_channel_length ic) in
    close_in ic;
    let output =
      source |> Frontend.get_operations |> Backends.compile X86_64 mode
    in
    let oc = open_out "main.asm" in
    try output_string oc output with _ -> close_out oc
  with _ -> close_in ic

open Cmdliner

let source =
  let doc = "The brainfuck source to be interperned" in
  Arg.(required & pos ~rev:true 0 (some string) None & info [] ~doc)

let mode =
  let ascii =
    let doc = "Run the interpperter in ASCII mode" in
    (Ascii, Arg.info [ "a"; "ascii" ] ~doc)
  in
  let u8 =
    let doc = "Run the interpperter in U8 mode" in
    (U8, Arg.info [ "u"; "u8" ] ~doc)
  in
  Arg.(last & vflag_all [ Ascii ] [ ascii; u8 ])

let cmd =
  let doc = "Pain and suffering" in
  let man = [] in
  let info = Cmd.info "bf" ~version:"%%VERSION%%" ~doc ~man in
  Cmd.v info Term.(const run $ mode $ source)

let main () = exit (Cmd.eval cmd)
let () = main ()
