%macro print 2
    mov     rsi, %1 ; Buffer that we want to write
    mov     rdx, %2 ; Length of the buffer

    mov     rax, 1  ; SYS_WRITE
    mov     rdi, 1  ; STDOUT
    syscall
%endmacro


global _start

SECTION .data
    invalid_digit       db "The digit "
    invalid_digit_pos   db 0, " is invalid", 10
    invalid_digit_len   equ $ - invalid_digit

    output_buffer_end   equ output_buffer + 1024

    ascii_mode          db 0xa
    
SECTION .bss
    input_buffer        resb 1024
    output_buffer       resb 1025
    file_path           resb 8


SECTION .text

_start:
    pop r10
    inc r10

parse_args_loop:
    dec     r10

    cmp     r10, 0
    je      parse_args_done

    pop     rax
    mov     r11, rax

    call    cstr_len
    print   r11, rax
    print   ascii_mode, 1

    cmp     r10, 0
    je      parse_args_done

    cmp     rax, 0
    jmp     parse_args_loop
    
parse_args_done:
    mov     rax, 60
    mov     rdi, 0
    syscall

; Find the length of a c string
; Input:
;   rax -> Pointer to start of string
; Outpu:
;   rax -> resulting length
cstr_len:
    xor     rcx, rcx

cstr_len_loop:
    mov     bl, [rax + rcx]
    cmp     bl, 0
    je      cstr_len_done
    inc     rcx
    jmp     cstr_len_loop

cstr_len_done:
    mov     rax, rcx
    ret

; Print number will print a decimal number to the given file
;   Input:
;       rax - The numebr to print
;       rdi - The file to write it too
;   Output:
;
print_number:
    ; qword [rsp + 2] -> number to print
    ; qword [rsp + 10] -> file we want to print to
    ; qword rdi -> Count
    sub     rsp, 16
    mov     [rsp], rdi
    xor     rdi, rdi

print_loop_start:
    xor     rdx, rdx
    mov     rcx, 10
    div     rcx
    
    ; RAX -> Rest of number
    ; RDX -> Digit we want to add
    ; output_buffer[rdi] = RDX + 0x30

    mov     rcx, output_buffer_end
    sub     rcx, rdi

    mov     [rcx], dl 
    add     [rcx], byte 0x30

    inc     rdi

    cmp     rax, 0
    je      print_number_done
    jmp     print_loop_start


print_number_done:
    ; Add newline character
    mov     [output_buffer_end + 1], byte 10

    ; Set our length
    mov     rdx, rdi
    inc     rdx

    ; Set the pointer to the start of the input buffer
    mov     r8, output_buffer_end
    sub     r8, rdi
    inc     r8
    mov     rsi, r8

    ; Setup the syscall
    mov     rax, 1
    mov     rdi, [rsp]
    
    syscall

    add     rsp, 16
    ret

; Read number will read a decimal number for the specified file
;   Input:
;       rax - the file that you want to read from
;   Output:
;       rax - The read number
read_number:
    ; rbx -> output
    ; cl  -> Temporary storage of the current character
    ; rdx -> The digit multiplier
    ; r8  -> The offset from input_buffer
    
    ; Read the bytes into a buffer
    mov     rdi, rax ; Move the file pointer to the RSI register
    mov     rax, 0
    mov     rsi, input_buffer
    mov     rdx, 1024

    syscall

    xor     rdx, rdx
    xor     rcx, rcx
    xor     rbx, rbx

    ; Get pointer to end of input
    lea     r8, [input_buffer + rax]
    dec     r8

    ; Check for and skip new line
    mov     cl, [r8]
    cmp     cl, byte 10
    jne     first_digit
    dec     r8

first_digit:
    ; Return zero if the user did not input any value
    cmp     r8, input_buffer
    jl      read_num_done

    ; Get the digit
    mov     cl, [r8] 
    dec     r8

    ; Check for valid digit
    cmp     cl, 0x30
    jl      read_num_invalid_digit
    cmp     cl, 0x39
    jg      read_num_invalid_digit

    ; Convert ASCII to digit
    sub     cl, 0x30
    mov     rbx, rcx
    mov     rdx, 10

read_num_loop:
    ; Check to see if we have finished processing the buffer
    cmp     r8, input_buffer
    jl      read_num_done

    ; Get the digit
    mov     cl, [r8] 
    dec     r8

    ; Check for valid digit
    cmp     cl, 0x30
    jl      read_num_invalid_digit
    cmp     cl, 0x39
    jg      read_num_invalid_digit

    ; Convert ASCII to digit
    sub     cl, 0x30

    mov     r9, rdx
    ; Multiply by 10
    mov     rax, rcx
    mul     rdx

    ; Store result
    add     rbx, rax

    ; Multiply the power by ten
    mov     rax, r9 
    mov     rdx, 10
    mul     rdx
    mov     rdx, rax

    jmp     read_num_loop

read_num_invalid_digit:
    mov     [invalid_digit_pos], cl
    print   invalid_digit, invalid_digit_len

    jmp     read_number

read_num_done:
    mov     rax, rbx
    ret

