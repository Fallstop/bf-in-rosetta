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
    let doc = "Run the compiler in ASCII mode" in
    (Ascii, Arg.info [ "a"; "ascii" ] ~doc)
  in
  let bits8 =
    let doc = "Run the compiler in 8-bit mode" in
    (Bits8, Arg.info [ "b8"; "bits8" ] ~doc)
  in
  let bits32 =
    let doc = "Run the compiler in 32-bit mode" in
    (Bits32, Arg.info [ "b32"; "bits32" ] ~doc)
  in
  let bits64 =
    let doc = "Run the compiler in 64-bit mode" in
    (Bits64, Arg.info [ "b64"; "bits64" ] ~doc)
  in
  Arg.(last & vflag_all [ Ascii ] [ ascii; bits8; bits32; bits64 ])

let cmd =
  let doc = "Pain and suffering" in
  let man = [] in
  let info = Cmd.info "bf" ~version:"%%VERSION%%" ~doc ~man in
  Cmd.v info Term.(const run $ mode $ source)

let main () = exit (Cmd.eval cmd)
let () = main ()
