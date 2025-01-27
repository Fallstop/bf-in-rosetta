%macro print 2
    mov     rax, 1  ; SYS_WRITE
    mov     rdi, 1  ; STDOUT
    mov     rsi, %1 ; Buffer that we want to write
    mov     rdx, %2 ; Length of the buffer
    syscall
%endmacro


global _start

SECTION .text
    hello_world     db "Hello world!", 10
    hello_world_len equ $ - hello_world

SECTION .text

_start:
    print   hello_world, hello_world_len
    
    mov     rax, 60
    mov     rdi, 0
    syscall
