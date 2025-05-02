%macro print 2
    mov     rsi, %1 ; Buffer that we want to write
    mov     rdx, %2 ; Length of the buffer

    mov     rax, 1  ; SYS_WRITE
    mov     rdi, 1  ; STDOUT
    syscall
%endmacro

%macro here 0
    push rax
    print msg_here, msg_here_len
    pop rax
%endmacro

global _start

SECTION .data
    msg_no_input            db "Please supply a source file", 10
    msg_no_input_len        equ $ - msg_no_input

    msg_couldnt_open        db "Could not open the requested file", 10
    msg_couldnt_open_len    equ $ - msg_couldnt_open

    msg_here                db "Here", 10
    msg_here_len            equ $ - msg_here

    msg_no_read             db "Could not read the file into memory", 10
    msg_no_read_len         equ $ - msg_no_read

SECTION .bss
    outbuf  resb 1
    mem     resb 30_000

SECTION .text


_start:
    pop     r9
    cmp     r9, 2
    jl      no_input
    pop     r9 ; Pop off executable name
    pop     r9 ; Pop off source file name 
    
    mov     r15, mem ; So I can find mem in the debugger

    ; Open the file 
    mov     rax, 2
    mov     rdi, r9
    xor     rsi, rsi
    syscall

    cmp     rax, -1
    ; Couldn't open the file
    je      opennt
    
    mov     rdi, rax
    call    main

    mov     rdi, rax
    mov     rax, 60
    syscall

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    mov     [rbp - 8], rdi

    call    get_size
    mov     [rbp - 16], rax

    ; mmap(NULL, file_size, PROT_READ, MAP_PRIVATE, fd, 0);
    mov     rdi, 0
    mov     rsi, rax
    mov     rdx, 0x1
    mov     r10, 0x2
    mov     r8, [rbp - 8]
    mov     r9, 0

    mov     rax, 9
    syscall

    mov     [rbp - 24], rax

    cmp     rax, -1
    je      no_read

    mov     rax, 3
    mov     rsi, [rbp - 8]

    mov     rdi, [rbp - 16]
    mov     rsi, [rbp - 24]
    call    exec

    mov     rax, 0
    leave
    ret

no_read:
    print msg_no_read, msg_no_read_len
    mov     rax, 3
    mov     rsi, [rbp - 8]

    mov     rax, 1
    leave
    ret

get_size:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 144

    mov     rax, 5
    lea     rsi, [rbp - 144]
    syscall

    ; Get the file size
    mov     rax, [rbp - 96]

    leave
    ret
    
no_input:
    print   msg_no_input, msg_no_input_len

    mov     rax, 60
    mov     rdi, 1
    syscall

opennt:
    print   msg_couldnt_open, msg_couldnt_open_len

    mov     rax, 60
    mov     rdi, 1
    syscall


; void exec(int len, char* ptr);
exec:
    push    rbp
    mov     rbp, rsp

    mov     r8, rdi ; len
    mov     r9, rsi ; ptr
    xor     r10, r10 ; code pointer
    xor     r12, r12 ; cell pointer

loop:
    cmp     r10, r8
    jge     done

    mov     al, [r9 + r10] 
    cmp     al, "."
    je      print_mem

    cmp     al, ","
    je      input

    cmp     al, ">"
    je      right
    
    cmp     al, "<"
    je      left

    cmp     al, "["
    je      open_brace

    cmp     al, "]"
    je      close_brace

    cmp     al, "+"
    je      plus

    cmp     al, "-"
    je      minus

    jmp     next

input:
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, outbuf
    mov     rdx, 1
    syscall

    mov     al, [outbuf]
    mov     [mem + r12], al

    jmp     next

print_mem:
    mov     al, [mem + r12]
    mov     [outbuf], al

    mov     rax, 1
    mov     rdi, 1
    mov     rsi, outbuf
    mov     rdx, 1
    syscall

    jmp     next

left:
    sub     r12, 1
    jc      reset_under
    jmp     next

reset_under:
    mov     r12, 29_999
    jmp     next

right:
    inc     r12
    cmp     r12, 30_000
    jge     reset_over
    jmp     next

reset_over:
    xor     r12, r12
    jmp     next

open_brace:
    push    r10
    jmp     next

close_brace:
    mov     al, [mem + r12]
    test    al, al
    jz      cont
    pop     r10
    push    r10
    jmp     next

cont:
    pop     rax
    jmp     next

plus:
    add     byte [mem + r12], 1
    jmp     next

minus:
    sub     byte [mem + r12], 1
    jmp     next

next:
    inc     r10
    jmp     loop

done:
    leave
    ret
