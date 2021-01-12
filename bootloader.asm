[org 0x7c00] ; Where our bootloader code is loaded by BIOS
[bits 16]

; Start of bootloader code
bootloaderStart:
    ; Save the boot drive
    mov [BOOT_DRIVE], dl

    ; Set up stack
    mov bp, 0x7c00
    mov sp, bp

    ; Print helloWorld
    mov ax, helloWorld
    call printString

    ; Read the extended bootloader code from disk
    call readDisk

    ; Jump to extended bootloader code
    jmp EXTENDED_BOOTLOADER_LOCATION

    ; Infinite loop
    jmp $

; Includes
%include "print.asm"
%include "disk.asm"

; Strings
helloWorld: db "Hello World!", 0

; Pad the bootloader with 0s until it is 512 bytes
times 510-($-$$) db 0
; Magic number to tell BIOS this is bootable code
dw 0xaa55
