open Bfc_ocaml.Common

let test_script =
  "+++++ +++++             initialize counter (cell #0) to 10\n\
   [                       use loop to set the next four cells to 70/100/30/10\n\
   > +++++ ++              add  7 to cell #1\n\
   > +++++ +++++           add 10 to cell #2\n\
   > +++                   add  3 to cell #3\n\
   > +                     add  1 to cell #4\n\
   <<<< -                  decrement counter (cell #0)\n\
   ]\n\
   > ++ .                  print 'H'\n\
   > + .                   print 'e'\n\
   +++++ ++ .              print 'l'\n\
   .                       print 'l'\n\
   +++ .                   print 'o'\n\
   > ++ .                  print ' '\n\
   << +++++ +++++ +++++ .  print 'W'\n\
   > .                     print 'o'\n\
   +++ .                   print 'r'\n\
   ----- - .               print 'l'\n\
   ----- --- .             print 'd'\n\
   > + .                   print '!'\n\
   > .                     print '\n\
   '\n\
   How to use the interpreter:\n\n"

open Bfc_ocaml.Frontend

(* Helper to compare action_group *)
let action_group_equal (a : action_group) (b : action_group) =
  a.start = b.start && a.current = b.current && a.values = b.values

(* Helper to compare clone_block *)
let clone_block_equal (a : clone_block) (b : clone_block) =
  a.start = b.start && a.from = b.from && a.values = b.values

(* Helper to compare operations *)
let operation_equal a b =
  match (a, b) with
  | Noop, Noop -> true
  | Out, Out -> true
  | In, In -> true
  | LoopStart a, LoopStart b -> a = b
  | LoopEnd a, LoopEnd b -> a = b
  | ActionGroup ag1, ActionGroup ag2 -> action_group_equal ag1 ag2
  | CloneBlock cb1, CloneBlock cb2 -> clone_block_equal cb1 cb2
  | _ -> false

let operations_equal ops1 ops2 =
  List.length ops1 = List.length ops2 && List.for_all2 operation_equal ops1 ops2

let operations_to_string ops =
  ops |> List.map op_to_string |> String.concat "; "

(* Expected operations for test_script:
   1. Noop (initial state)
   2. ActionGroup with 10 at position 0
   3. CloneBlock for the loop (optimized from [>+++++++>++++++++++>+++>+<<<<-])
   4. Sequence of ActionGroups and Outs for printing "Hello World!\n"
*)
let expected_operations =
  [
    Noop;
    (* +++++ +++++ -> 10 at cell 0 *)
    ActionGroup { start = 0; current = 0; values = [| 10 |] };
    (* The loop [>+++++++>++++++++++>+++>+<<<<-] becomes a CloneBlock *)
    CloneBlock { start = 0; from = 0; values = [ 0; 7; 10; 3; 1 ] };
    (* > ++ . -> move right, add 2, output (cell 1 now has 70+2=72='H') *)
    ActionGroup { start = 1; current = 0; values = [| 2 |] };
    Out;
    (* > + . -> move right, add 1, output (cell 2 now has 100+1=101='e') *)
    ActionGroup { start = 1; current = 0; values = [| 1 |] };
    Out;
    (* +++++ ++ . -> add 7, output (cell 2 now has 101+7=108='l') *)
    ActionGroup { start = 0; current = 0; values = [| 7 |] };
    Out;
    (* . -> output (still 'l') *)
    Out;
    (* +++ . -> add 3, output (cell 2 now has 108+3=111='o') *)
    ActionGroup { start = 0; current = 0; values = [| 3 |] };
    Out;
    (* > ++ . -> move right, add 2, output (cell 3 now has 30+2=32=' ') *)
    ActionGroup { start = 1; current = 0; values = [| 2 |] };
    Out;
    (* << +++++ +++++ +++++ . -> move left 2, add 15, output (cell 1 now has 72+15=87='W') *)
    (* Note: values=[|15; 0|] because moving left creates additional array element *)
    ActionGroup { start = -2; current = 0; values = [| 15; 0 |] };
    Out;
    (* > . -> move right, output (cell 2 has 111='o') *)
    ActionGroup { start = 1; current = 0; values = [| 0 |] };
    Out;
    (* +++ . -> add 3, output (cell 2 now has 111+3=114='r') *)
    ActionGroup { start = 0; current = 0; values = [| 3 |] };
    Out;
    (* ----- - . -> subtract 6, output (cell 2 now has 114-6=108='l') *)
    ActionGroup { start = 0; current = 0; values = [| -6 |] };
    Out;
    (* ----- --- . -> subtract 8, output (cell 2 now has 108-8=100='d') *)
    ActionGroup { start = 0; current = 0; values = [| -8 |] };
    Out;
    (* > + . -> move right, add 1, output (cell 3 now has 32+1=33='!') *)
    ActionGroup { start = 1; current = 0; values = [| 1 |] };
    Out;
    (* > . -> move right, output (cell 4 has 10='\n') *)
    ActionGroup { start = 1; current = 0; values = [| 0 |] };
    Out;
  ]

let test_get_operations_produces_correct_length () =
  let result = get_operations test_script in
  let expected_len = List.length expected_operations in
  let result_len = List.length result in
  if result_len <> expected_len then begin
    Printf.printf "FAIL: Expected %d operations, got %d\n" expected_len
      result_len;
    Printf.printf "Result: [%s]\n" (operations_to_string result);
    false
  end
  else begin
    Printf.printf "PASS: Correct number of operations (%d)\n" expected_len;
    true
  end

let test_get_operations_produces_correct_values () =
  let result = get_operations test_script in
  if operations_equal result expected_operations then begin
    Printf.printf "PASS: Operations match expected values\n";
    true
  end
  else begin
    Printf.printf "FAIL: Operations do not match\n";
    Printf.printf "Expected: [%s]\n" (operations_to_string expected_operations);
    Printf.printf "Got:      [%s]\n" (operations_to_string result);
    (* Print first difference *)
    let rec find_diff i exp res =
      match (exp, res) with
      | [], [] -> ()
      | e :: _, r :: _ when not (operation_equal e r) ->
          Printf.printf
            "First difference at index %d:\n  Expected: %s\n  Got: %s\n" i
            (op_to_string e) (op_to_string r)
      | _ :: exp', _ :: res' -> find_diff (i + 1) exp' res'
      | [], r :: _ ->
          Printf.printf "Extra operation at index %d: %s\n" i (op_to_string r)
      | e :: _, [] ->
          Printf.printf "Missing operation at index %d: %s\n" i (op_to_string e)
    in
    find_diff 0 expected_operations result;
    false
  end

let test_simple_plus () =
  let result = get_operations "+++" in
  let expected =
    [ Noop; ActionGroup { start = 0; current = 0; values = [| 3 |] } ]
  in
  if operations_equal result expected then begin
    Printf.printf "PASS: Simple plus test\n";
    true
  end
  else begin
    Printf.printf "FAIL: Simple plus test\n";
    Printf.printf "Expected: [%s]\n" (operations_to_string expected);
    Printf.printf "Got:      [%s]\n" (operations_to_string result);
    false
  end

let test_simple_minus () =
  let result = get_operations "---" in
  let expected =
    [ Noop; ActionGroup { start = 0; current = 0; values = [| -3 |] } ]
  in
  if operations_equal result expected then begin
    Printf.printf "PASS: Simple minus test\n";
    true
  end
  else begin
    Printf.printf "FAIL: Simple minus test\n";
    Printf.printf "Expected: [%s]\n" (operations_to_string expected);
    Printf.printf "Got:      [%s]\n" (operations_to_string result);
    false
  end

let test_move_right () =
  let result = get_operations ">+" in
  let expected =
    [ Noop; ActionGroup { start = 1; current = 0; values = [| 1 |] } ]
  in
  if operations_equal result expected then begin
    Printf.printf "PASS: Move right test\n";
    true
  end
  else begin
    Printf.printf "FAIL: Move right test\n";
    Printf.printf "Expected: [%s]\n" (operations_to_string expected);
    Printf.printf "Got:      [%s]\n" (operations_to_string result);
    false
  end

let test_move_left () =
  let result = get_operations "<+" in
  let expected =
    [ Noop; ActionGroup { start = -1; current = 0; values = [| 1 |] } ]
  in
  if operations_equal result expected then begin
    Printf.printf "PASS: Move left test\n";
    true
  end
  else begin
    Printf.printf "FAIL: Move left test\n";
    Printf.printf "Expected: [%s]\n" (operations_to_string expected);
    Printf.printf "Got:      [%s]\n" (operations_to_string result);
    false
  end

let test_output () =
  let result = get_operations ".." in
  let expected = [ Noop; Out; Out ] in
  if operations_equal result expected then begin
    Printf.printf "PASS: Output test\n";
    true
  end
  else begin
    Printf.printf "FAIL: Output test\n";
    Printf.printf "Expected: [%s]\n" (operations_to_string expected);
    Printf.printf "Got:      [%s]\n" (operations_to_string result);
    false
  end

let test_input () =
  let result = get_operations ",," in
  let expected = [ Noop; In; In ] in
  if operations_equal result expected then begin
    Printf.printf "PASS: Input test\n";
    true
  end
  else begin
    Printf.printf "FAIL: Input test\n";
    Printf.printf "Expected: [%s]\n" (operations_to_string expected);
    Printf.printf "Got:      [%s]\n" (operations_to_string result);
    false
  end

let test_clone_block_optimization () =
  (* Simple copy loop: [->>+<<] should become CloneBlock *)
  let result = get_operations "[->>+<<]" in
  let has_clone_block =
    List.exists (function CloneBlock _ -> true | _ -> false) result
  in
  if has_clone_block then begin
    Printf.printf "PASS: Clone block optimization test\n";
    true
  end
  else begin
    Printf.printf "FAIL: Clone block optimization test - no CloneBlock found\n";
    Printf.printf "Got: [%s]\n" (operations_to_string result);
    false
  end

let () =
  Printf.printf "Running frontend tests...\n\n";
  let tests =
    [
      ("simple_plus", test_simple_plus);
      ("simple_minus", test_simple_minus);
      ("move_right", test_move_right);
      ("move_left", test_move_left);
      ("output", test_output);
      ("input", test_input);
      ("clone_block_optimization", test_clone_block_optimization);
      ("test_script_length", test_get_operations_produces_correct_length);
      ("test_script_values", test_get_operations_produces_correct_values);
    ]
  in
  let results =
    List.map
      (fun (name, test) ->
        Printf.printf "--- %s ---\n" name;
        let result = test () in
        Printf.printf "\n";
        (name, result))
      tests
  in
  let passed = List.filter (fun (_, r) -> r) results |> List.length in
  let total = List.length results in
  Printf.printf "=== Results: %d/%d tests passed ===\n" passed total;
  if passed <> total then exit 1
