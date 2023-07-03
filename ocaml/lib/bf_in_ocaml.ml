let expload_string str = List.init (String.length str) (String.get str)

let run code inc dec i o zero init =
  let rec run2 (code, memory, pointer) =
    match code with
    | [] -> ([], memory, pointer)
    | '+' :: code ->
        memory.(pointer) <- inc memory.(pointer);
        run2 (code, memory, pointer)
    | '-' :: code ->
        memory.(pointer) <- dec memory.(pointer);
        run2 (code, memory, pointer)
    | ',' :: code ->
        memory.(pointer) <- i ();
        run2 (code, memory, pointer)
    | '.' :: code ->
        o memory.(pointer);
        run2 (code, memory, pointer)
    | '>' :: code ->
        let pointer = if pointer = 29_000 then 0 else pointer + 1 in
        run2 (code, memory, pointer)
    | '<' :: code ->
        let pointer = if pointer = 0 then 29_999 else pointer - 1 in
        run2 (code, memory, pointer)
    | ']' :: code -> (code, memory, pointer)
    | '[' :: code ->
        let rec loop code (_, memory, pointer) =
          if memory.(pointer) = zero then
            let rec skip code =
              match code with
              | [] -> code
              | '[' :: tail -> skip (skip tail)
              | ']' :: tail -> tail
              | _ :: tail -> skip tail
            in
            run2 (skip code, memory, pointer)
          else loop code (run2 (code, memory, pointer))
        in
        loop code ([], memory, pointer)
    | _ :: code -> run2 (code, memory, pointer)
  in
  run2 (expload_string code, Array.init 300000 (fun _ -> init), 0)

let run_char code =
  let inc a = char_of_int (match int_of_char a + 1 with 0xff -> 0 | a -> a) in
  let dec a =
    char_of_int (match int_of_char a - 1 with -1 -> 0xff | a -> a)
  in
  let i () =
    try
      print_newline ();
      print_string "? ";
      flush stdout;
      String.get (read_line ()) 0
    with _ -> char_of_int 0
  in
  let o a =
    print_char a;
    flush stdout
  in
  let zero = char_of_int 0 in
  run code inc dec i o zero (char_of_int 0)

let run_int code =
  let inc a = a + 1 in
  let dec a = a - 1 in
  let i () =
    try
      print_newline ();
      print_string "? ";
      flush stdout;
      read_int ()
    with _ -> 0
  in
  let o a =
    print_int a;
    print_newline ();
    flush stdout
  in
  let zero = 0 in
  run code inc dec i o zero 0
