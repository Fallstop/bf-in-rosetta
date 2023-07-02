(* open Printf *)

let expload_string str = List.init (String.length str) (String.get str)

let replace list index replace =
  List.mapi (fun i elm -> if i = index then replace elm else elm) list

let run code inc dec i o zero init =
  let rec run2 (code, memory, pointer) =
    (* print_string "Memory:";

       for i = 0 to 20 do
         printf " %i" (int_of_char (List.nth memory i))
       done;

       printf " Pointer %i Code length %i" pointer (List.length code);
       (try printf " Current instruction %c\n" (List.hd code)
        with _ -> print_endline ""); *)
    match code with
    | [] -> ([], memory, pointer)
    | '+' :: code -> run2 (code, replace memory pointer inc, pointer)
    | '-' :: code -> run2 (code, replace memory pointer dec, pointer)
    | ',' :: code -> run2 (code, replace memory pointer (fun _ -> i ()), pointer)
    | '.' :: code ->
        o (List.nth memory pointer);
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
          if List.nth memory pointer = zero then
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
  run2 (expload_string code, List.init 300000 (fun _ -> init), 0)

let run_char code =
  let inc a = char_of_int (match int_of_char a + 1 with 0xff -> 0 | a -> a) in
  let dec a =
    char_of_int (match int_of_char a - 1 with -1 -> 0xff | a -> a)
  in
  let i () = try String.get (read_line ()) 0 with _ -> char_of_int 0 in
  let o a =
    print_char a;
    flush_all ()
  in
  let zero = char_of_int 0 in
  run code inc dec i o zero (char_of_int 0)

let run_int code =
  let inc a = a + 1 in
  let dec a = a - 1 in
  let i () = try read_int () with _ -> 0 in
  let o a =
    print_int a;
    flush_all ()
  in
  let zero = 0 in
  run code inc dec i o zero 0
