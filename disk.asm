[bits 16]

EXTENDED_BOOTLOADER_LOCATION equ 0x7e00 ; Extended bootloader code location

; Reads the extended bootloader code from disk
readDisk:
    mov ah, 2
    mov al, 4
    mov bx, EXTENDED_BOOTLOADER_LOCATION
    xor ch, ch
    mov cl, 2
    xor dh, dh
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc diskReadError
    ret

; Called if there is an error reading the extended bootloader code
diskReadError:
    ; Print "Failed to read from disk!" message
    mov ax, diskReadErrorString
    call printString
    ; Infinite loop
    jmp $

; Strings
diskReadErrorString: db "Failed to read from disk!", 0

; Boot drive number
BOOT_DRIVE: db 0
