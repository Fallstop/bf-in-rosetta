module Frontend = Bfc_ocaml.Frontend

let file = "../helloWorld.bf"

let () =
  let ic = open_in file in
  try
    let source = really_input_string ic (in_channel_length ic) in
    print_string source;
    close_in ic
  with _ ->
    close_in ic;
    print_string "Oh fuck"
