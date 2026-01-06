open Common

let get_generator Common.Ascii =
  {
    header =
      "global _start\n\n\
       SECTION .data\n\
      \    msg_no_input            db \"Please supply a source file\", 10\n\
      \    msg_no_input_len        equ $ - msg_no_input\n\n\
      \    msg_couldnt_open        db \"Could not open the requested file\", 10\n\
      \    msg_couldnt_open_len    equ $ - msg_couldnt_open\n\n\
      \    msg_here                db \"Here\", 10\n\
      \    msg_here_len            equ $ - msg_here\n\n\
      \    msg_no_read             db \"Could not read the file into memory\", \
       10\n\
      \    msg_no_read_len         equ $ - msg_no_read\n\n\
       SECTION .bss\n\
      \    outbuf  resb 1\n\
      \    mem     resb 30_000\n\n\
       SECTION .text\n\n\n\
       _start:\n";
    in_fn = "; Input";
    out_fn =
      "; Print\n\
      \    mov     rsi, %1 ; Buffer that we want to write\n\
      \    mov     rdx, %2 ; Length of the buffer\n\n\
      \    mov     rax, 1  ; SYS_WRITE\n\
      \    mov     rdi, 1  ; STDOUT\n\
      \    syscall";
    footer = "; Exit \n    mov     rax, 60\n mov     rdi, 0\n    syscall";
  }
