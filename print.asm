[bits 16]

; Prints a character
; inputs (al | char)
printChar:
    mov ah, 0x0e
    int 0x10
    ret

; Prints a string terminated with a null byte
; inputs (ax | string pointer)
printString:
    push ax
    mov bx, ax
    xor ax, ax
    .loop:
        mov al, [bx]
        cmp al, 0
        je .ret
        call printChar
        inc bx
        jmp .loop
    .ret:
        pop ax
        ret
