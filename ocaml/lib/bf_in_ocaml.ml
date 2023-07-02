let replace list index replace =
  List.mapi (fun i elm -> if i = index then replace elm else elm) list

let rec run code memory pointer inc dec i o =
  match code with
  | [] -> ([], memory, pointer)
  | '>' :: code ->
      let pointer = if pointer = 29_000 then 0 else pointer + 1 in
      run code memory pointer inc dec i o
  | '<' :: code ->
      let pointer = if pointer = 0 then 29_999 else pointer - 1 in
      run code memory pointer inc dec i o
  | '.' :: code ->
      o (List.nth memory pointer);
      run code memory pointer inc dec i o
  | ',' :: code ->
      run code (replace memory pointer (fun _ -> i ())) pointer inc dec i o
  | '+' :: code -> run code (replace memory pointer inc) pointer inc dec i o
  | '-' :: code ->
      run code
        (List.mapi
           (fun index elm -> if index = pointer then dec elm else elm)
           memory)
        pointer inc dec i o
  | _ :: code -> run code memory pointer inc dec i o
