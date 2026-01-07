module Frontend = Bfc_ocaml.Frontend

let () =
  Bfc_ocaml.Common.test_script |> Bfc_ocaml.Frontend.get_operations
  |> Bfc_ocaml.Backends.compile Bfc_ocaml.Common.X86_64 Bfc_ocaml.Common.Ascii
  |> print_string
