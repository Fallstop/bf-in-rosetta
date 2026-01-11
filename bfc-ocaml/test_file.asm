BITS 64

%macro print 2
    push    rax
    push    rdi
    push    rsi
    push    rdx
    push    r11

    mov     rax, 1
    mov     rdi, 1
    mov     rsi, %1
    mov     rdx, %2

    syscall

    pop     r11
    pop     rdx
    pop     rsi
    pop     rdi
    pop     rax
%endmacro

%macro here 0
    print heremsg, 5
%endmacro

global _start
SECTION .data
    msg     db "Invaid input", 10
    heremsg db "Here", 10
    buf     db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10
SECTION .bss
    mem     resb 30000

SECTION .text

_start:
    xor     r8, r8
    call    read_int

    call    print_int

    mov     rax, 60
    mov     rdi, 1
    syscall

; print_int:
;     ret

print_int:
    ; r15 -> current index into the output buffer
    ; r14 -> The current value
    ; rsi -> 10

    mov     al, mem[r8]
    mov     r15, 18
    mov     rsi, 10

print_int_sb_loop:
    xor     rdx, rdx
    div     rsi

    add     rdx, 0x30
    mov     buf[r15], dl
    dec     r15

    test    rax, rax
    jz      print_int_done
    jmp     print_int_sb_loop

print_int_done:
    mov     rdx, 19
    sub     rdx, r15

    mov     rax, 1
    mov     rdi, 1
    lea     rsi, buf[r15]

    syscall
    ret

read_int_err:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg
    mov     rdx, 13

    syscall

read_int:
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, buf
    mov     rdx, 19

    syscall

    mov     r15, rax
    sub     r15, 1
    jc      read_int_err

    ; rax -> temp     here
    ; rdi -> 10

    ; r15 -> length of characters read
    ; r14 -> current value
    ; r13 -> current byte
    ; r12 -> current multiple

    mov     rdi, 10

    xor     r14, r14
    mov     r12, 1

    mov     r13b, buf[r15]
    cmp     r13, 10
    jne     read_int_loop
    sub     r15, 1
    jc      read_int_done

read_int_loop:
    ; Check that the character is a digit
    mov     r13b, buf[r15]
    sub     r13, 0x30 ; subtract the zero character to get the integer value
    jc      read_int_err
    cmp     r13, 9
    jg      read_int_err

    ; Get value
    mov     rax, r13
    mul     r12
    add     r14, rax

    ; Increase multiple
    mov     rax, r12
    mul     rdi
    mov     r12, rax

    ; Move next
    sub     r15, 1

    jc      read_int_done
    jmp     read_int_loop
read_int_done:
    mov mem[r8], r13b
    ret