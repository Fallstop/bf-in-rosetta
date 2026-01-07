open Common

(*
  ! CAN NUKE
  rax -> syscall number
  rdi -> syscall arg1
  rsi -> syscall arg2
  rdx -> syscall arg3

  ! DON'T NUKE
  r8  -> Memory pointer
  r9  -> 
  r10 ->
  r12 ->
  r13 ->
  r14 ->
  r15 -> Temporary
*)

let get_generator Common.Ascii =
  let go_next count =
    if count > 0 then
      Format.sprintf "    mov     rax, %d\n    call    right_by"
        (count mod 30_000)
    else if count < 0 then
      Format.sprintf "    mov     rax, %d\n    call    left_by"
        (count * -1 mod 30_000)
    else ""
  in
  let header =
    "global _start\n\n\
     SECTION .data\n\
     SECTION .bss\n\
    \    outbuf  resb 1\n\
    \    mem     resb 30_000\n\n\
     SECTION .text\n\n\
     ; rax -> number to increment by\n\
     left_by:\n\
    \    sub     r8, rax\n\
    \    jc      reset_under\n\
    \    ret\n\
     reset_under:\n\
    \    add     r8, 30000\n\
    \    ret\n\n\
     ; rax -> number to decrement by\n\
     right_by:\n\
    \    add     r8, rax\n\
    \    test    r8, 30_000\n\
    \    jge     reset_over\n\
    \    ret\n\
     reset_over:\n\
    \    sub     r8, 30000\n\
    \    ret\n\n\
     _start:\n"
  in
  let footer =
    "; Exit \n    mov     rax, 60\n    mov     rdi, 0\n    syscall"
  in
  let in_fn = "" in
  let out_fn =
    "    mov     rax, 1  ; SYS_WRITE\n\
    \    mov     rdi, 1  ; STDOUT\n\
    \    lea     rsi, memory[r8] ; Buffer that we want to write\n\
    \    mov     rdx, 1 ; Length of the buffer\n\n\
    \    syscall"
  in
  let action_group_fn (ag : action_group) =
    let rec do_action items count =
      match items with
      | curr :: rest ->
          if curr == 0 then do_action rest (count + 1)
          else
            go_next count
            ^ Format.sprintf
                "\n\
                \    mov     r15b, memory[r8]\n\
                \    add     r15b, %d\n\
                \    mov     memory[r8], r15b\n"
                curr
            ^ do_action rest 1
      | [] -> go_next (ag.start - (Array.length ag.values - count)) ^ "\n"
    in
    go_next ag.start ^ do_action (Array.to_list ag.values) 0 ^ "\n"
  in
  let clone_block_fn (cb : clone_block) = go_next cb.start ^ "\n" in
  let comment_fn str =
    (str |> String.split_on_char '\n'
    |> List.map (fun x -> "; " ^ x)
    |> String.concat "\n")
    ^ "\n"
  in
  { header; action_group_fn; clone_block_fn; in_fn; out_fn; footer; comment_fn }
