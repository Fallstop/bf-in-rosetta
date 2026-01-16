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

let num_io_fns =
  "\n\
   print_int:\n\
  \    ; r15 -> current index into the output buffer\n\
  \    ; r14 -> The current value\n\
  \    ; rsi -> 10\n\
  \    xor     rax, rax\n\
  \    mov     al, memory[r8]\n\
  \    mov     r15, 18\n\
  \    mov     rsi, 10\n\n\
   print_int_sb_loop:\n\
  \    xor     rdx, rdx\n\
  \    div     rsi\n\n\
  \    add     rdx, 0x30\n\
  \    mov     buf[r15], dl\n\
  \    dec     r15\n\n\
  \    test    rax, rax\n\
  \    jz      print_int_done\n\
  \    jmp     print_int_sb_loop\n\n\
   print_int_done:\n\
  \    mov     rdx, 20\n\
  \    sub     rdx, r15\n\n\
  \    mov     rax, 1\n\
  \    mov     rdi, 1\n\
  \    inc     r15\n\
  \    lea     rsi, buf[r15]\n\n\
  \    syscall\n\
  \    ret\n\n\
   read_int_err:\n\
  \    mov     rax, 1\n\
  \    mov     rdi, 1\n\
  \    mov     rsi, msg\n\
  \    mov     rdx, 13\n\n\
  \    syscall\n\n\
   read_int:\n\
  \    mov     rax, 0\n\
  \    mov     rdi, 0\n\
  \    mov     rsi, buf\n\
  \    mov     rdx, 19\n\n\
  \    syscall\n\n\
  \    mov     r15, rax\n\
  \    sub     r15, 1\n\
  \    jc      read_int_err\n\n\
  \    ; rax -> temp     here\n\
  \    ; rdi -> 10\n\n\
  \    ; r15 -> length of characters read\n\
  \    ; r14 -> current value\n\
  \    ; r13 -> current byte\n\
  \    ; r12 -> current multiple\n\n\
  \    mov     rdi, 10\n\n\
  \    xor     r14, r14\n\
  \    mov     r12, 1\n\n\
  \    xor     r13, r13\n\
  \    mov     r13b, buf[r15]\n\
  \    cmp     r13, rdi\n\
  \    jne     read_int_loop\n\
  \    sub     r15, 1\n\
  \    jc      read_int_done\n\n\
   read_int_loop:\n\
  \    ; Check that the character is a digit\n\
  \    mov     r13b, buf[r15]\n\
  \    sub     r13, 0x30 ; subtract the zero character to get the integer value\n\
  \    jc      read_int_err\n\
  \    cmp     r13, 9\n\
  \    jg      read_int_err\n\n\
  \    ; Get value\n\
  \    mov     rax, r13\n\
  \    mul     r12\n\
  \    add     r14, rax\n\n\
  \    ; Increase multiple\n\
  \    mov     rax, r12\n\
  \    mul     rdi\n\
  \    mov     r12, rax\n\n\
  \    ; Move next\n\
  \    sub     r15, 1\n\n\
  \    jc      read_int_done\n\
  \    jmp     read_int_loop\n\n\
   read_int_done:\n\
  \    mov memory[r8], r14b\n\
  \    ret"

let go_next count =
  if count > 0 then
    Format.sprintf "    mov     rax, %d\n    call    right_by\n"
      (count mod 30_000)
  else if count < 0 then
    Format.sprintf "    mov     rax, %d\n    call    left_by\n"
      (count * -1 mod 30_000)
  else ""

let jump_functions =
  "; rax -> number to increment by\n\
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
  \    cmp     r8, 30_000\n\
  \    jge     reset_over\n\
  \    ret\n\
   reset_over:\n\
  \    sub     r8, 30000\n\
  \    ret\n\n"

let action_group_fn (ag : action_group) =
  let rec do_action items count =
    match items with
    | curr :: rest ->
        if curr == 0 then do_action rest (count + 1)
        else
          go_next count
          ^ Format.sprintf
              "    mov     r15b, memory[r8]\n\
              \    add     r15b, %d\n\
              \    mov     memory[r8], r15b\n"
              curr
          ^ do_action rest 1
    | [] -> go_next (ag.current - (Array.length ag.values - count))
  in
  do_action (Array.to_list ag.values) ag.start

let clone_block_fn (cb : clone_block) =
  let len = List.length cb.values in
  let { from; start; values } = cb in
  let rec do_action items count =
    match items with
    | curr :: rest ->
        if curr == 0 then do_action rest (count + 1)
        else
          go_next count
          ^ Format.sprintf
              "    mov     al, %d\n\
              \    mul     r15b\n\
              \    mov     r14b, memory[r8]\n\
              \    add     r14b, al\n\
              \    mov     memory[r8], r14b\n"
              curr
          ^ do_action rest 1
    | [] ->
        let v = len - count - start in
        Format.sprintf
          "; start = %d, count = %d, len = %d, len - count - start= %d\n" start
          count len v
        ^ go_next v
  in
  go_next (start + from)
  ^ "    mov     r15b, memory[r8]\n    mov     byte memory[r8], 0\n"
  ^ go_next (from * -1)
  ^ do_action values 0

let loop_start_fn n = Format.sprintf "L%d:\n" n

let loop_end_fn n =
  Format.sprintf
    "    mov     al, memory[r8]\n    test    al, al\n    jnz     L%d\n" n

let get_generator_ascii =
  let header =
    "global _start\n\n\
     SECTION .data\n\
     SECTION .bss\n\
    \    memory  resb 30_000\n\n\
     SECTION .text\n\n" ^ jump_functions ^ "_start:\n    xor     r8, r8"
  in
  let footer =
    "; Exit \n    mov     rax, 60\n    mov     rdi, 0\n    syscall"
  in
  let in_fn =
    "    mov     rax, 0  ; SYS_WRITE\n\
    \    mov     rdi, 1  ; STDOUT\n\
    \    lea     rsi, memory[r8] ; Buffer that we want to write\n\
    \    mov     rdx, 1 ; Length of the buffer\n\n\
    \    syscall\n"
  in
  let out_fn =
    "    mov     rax, 1  ; SYS_WRITE\n\
    \    mov     rdi, 1  ; STDOUT\n\
    \    lea     rsi, memory[r8] ; Buffer that we want to write\n\
    \    mov     rdx, 1 ; Length of the buffer\n\n\
    \    syscall\n"
  in
  let comment_fn str =
    (str |> String.split_on_char '\n'
    |> List.map (fun x -> "; " ^ x)
    |> String.concat "\n")
    ^ "\n"
  in
  {
    header;
    action_group_fn;
    clone_block_fn;
    in_fn;
    out_fn;
    footer;
    comment_fn;
    loop_end_fn;
    loop_start_fn;
  }

let get_generator_u8 =
  let header =
    "global _start\n\n\
     SECTION .data\n\
    \    msg     db \"Invaid input\", 10\n\
    \    buf     db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10\n\
     SECTION .bss\n\
    \    memory  resb 30_000\n\n\
     SECTION .text\n\n" ^ num_io_fns ^ jump_functions
    ^ "_start:\n    xor     r8, r8\n"
  in
  let footer =
    "; Exit \n    mov     rax, 60\n    mov     rdi, 0\n    syscall\n"
  in
  let in_fn = "    call    read_int\n" in
  let out_fn = "    call    print_int\n" in
  let comment_fn str =
    (str |> String.split_on_char '\n'
    |> List.map (fun x -> "; " ^ x)
    |> String.concat "\n")
    ^ "\n"
  in
  {
    header;
    action_group_fn;
    clone_block_fn;
    in_fn;
    out_fn;
    footer;
    comment_fn;
    loop_end_fn;
    loop_start_fn;
  }

let get_generator pm =
  match pm with Ascii -> get_generator_ascii | U8 -> get_generator_u8
