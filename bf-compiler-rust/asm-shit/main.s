%macro print 2
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, %1
    mov rdx, %2

    syscall
%endmacro


%macro valid_digit 0
    cmp al, 0x30
    jl input_bad_digit
    cmp al, 0x79
    jg input_bad_digit
%endmacro

global _start

;
; CONSTANTS
;
SYS_READ    equ 0
SYS_WRITE   equ 1
SYS_EXIT    equ 60

STDIN       equ 0
STDOUT      equ 1

;
; Initialised data goes here
;
SECTION .data
    hello               db  "Hello World!", 10      ; char *
    hello_len           equ $-hello                 ; size_t

    bad_digit           db "Invalid digit "
    bad_digit_digit     db 0, 10
    bad_digit_len       equ  $-bad_digit

    digits3             db "3 digits", 10
    digits3_len         equ $-digits3

    digits2             db "2 digits", 10
    digits2_len         equ $-digits2

    digits1             db "1 digits", 10
    digits1_len         equ $-digits1

    input_too_large     db "The number "
    input_too_large_ph  db 0, 0, 0, " that you inputted was too large", 10
    input_too_large_len equ $ - input_too_large

    fuck                db "fuck", 10
    fuck_len            equ $-fuck

    int_input           db 0, 0, 0, 10

;
; Code goes here
;
SECTION .text

_start:
    sub     rsp, 2
    call    get_number

    push rax

    mov     [rsp], al
    print   rsp, 1

    pop rax

    call print_number

    print   hello, hello_len

    mov     rax, 0
    call    vaish

; Gets a u8 from the user
; INPUTS:
;
; OUTPUTS
;   al -> A u8 entered by the user
get_number:
    sub rsp, 2
; point to return to if user enters bad input
get_number_start:
    ; clear int_input
    mov [int_input], dword 0xa0000000
    mov [rsp], word 0
    
    ; read three bytes
    xor     rax, rax
    xor     rdi, rdi
    mov     rsi, int_input
    mov     rdx, 4
    syscall

    print   int_input, 4

parse_inputs:
    cmp     [int_input + 1], byte 10
    je      one_digit
    cmp     [int_input + 1], byte 0
    je      one_digit

    cmp     [int_input + 2], byte 10
    je      two_digits
    cmp     [int_input + 2], byte 0
    je      two_digits

three_digits:
    ; Get ones digit and set to [rsp]
    print   digits3, digits3_len
    mov     al, [int_input + 2]
    valid_digit
    sub     al, 0x30
    mov     [rsp], al

    ; Get tens digit, multiply by ten and add to [rsp]
    mov     al, [int_input + 1]
    valid_digit
    sub     al, 0x30
    mov     bl, 10
    mul     bl
    add     [rsp], al

    ; Get hundreds digit, multiply by 100 and store in rx
    mov     al, [int_input]
    valid_digit
    sub     al, 0x30
    mov     bx, 100
    mul     bx
    
    ; Use bx to store the addition of all parts of number, and check to make sure its <=255
    mov     bl, [rsp]
    add     bx, ax
    cmp     bx, 0xFF
    jg      big_number
    
    ; Store the value in rsp
    mov [rsp], bl

    jmp get_number_done

two_digits:
    print   digits2, digits2_len
    mov     al, [int_input + 1]
    valid_digit
    sub     al, 0x30
    mov     [rsp], al

    mov     al, [int_input]
    valid_digit
    sub     al, 0x30
    mov     bl, 10
    mul     bl
    add     [rsp], al

    jmp    get_number_done

one_digit:
    print   digits1, digits1_len
    mov     al, [int_input]
    valid_digit

    sub     al, 0x30
    mov     [rsp], al

    jmp     get_number_done

input_bad_digit:
    mov     [bad_digit_digit], byte al

    print   bad_digit, bad_digit_len

    jmp     get_number_start

big_number:
    mov     ax, [int_input]
    mov     bl, [int_input + 2]

    mov     [input_too_large_ph], ax
    mov     [input_too_large_ph + 2], bl

    print   input_too_large, input_too_large_len

    jmp    get_number_start

get_number_done:
    mov     al, [rsp] 
    add     rsp, 2
    ret

; Prints a number to the console in decimal
; INPUT:
;   al -> number to print
; OUTPUT:
;   
print_number:
    sub     rsp, 4
    mov     [rsp], dword 0

    cmp     al, 10
    jl      print_one
    cmp     al, 100
    jl      print_two
    
print_three:
    push rax
    print digits3, digits3_len 
    pop rax

    xor     ah, ah
    mov     bl, 10
    div     bl
    ; Ones
    mov     [rsp  + 2], ah

    xor     ah, ah
    div     bl
    ; Hundreds
    mov     [rsp], al
    ; Tens
    mov     [rsp + 1], ah
    add     [rsp], dword 0x0a_30_30_30

    print   rsp, 4

    jmp     print_number_done

print_one:
    push rax
    print digits1, digits1_len 
    pop rax

    mov     [rsp], al
    add     [rsp], word 0x0a_30
    print   rsp, 2

    jmp     print_number_done 

print_two:
    push rax
    print digits2, digits2_len 
    pop rax

    xor     ah, ah
    mov     bl, 10
    div     bl

    mov     [rsp], al
    mov     [rsp + 1], ah
    add     [rsp], dword 0x00_0a_30_30

    print   rsp, 3

    jmp     print_number_done 

print_number_done:
    add     rsp, 4
    ret

; Exit the application with the given syscall
; INPUT:
;   rax -> Exit code 
vaish:
    mov     rdi, rax
    mov     rax, SYS_EXIT
    syscall

