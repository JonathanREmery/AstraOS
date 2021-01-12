;[org 0x7c00]

KERNEL_OFFSET equ 0x5000

start:
    mov [BOOT_DRIVE], dl
    mov bp, 0x9000
    mov sp, bp

    call loadKernel
    call realModeInit
    jmp $
    
[bits 16]

realModeInit:
    mov ah, 0
    mov al, 3
    int 0x10
    cli
    lgdt [GDT_DESCRIPTOR]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEGMENT:protectedModeInit

loadKernel:
    mov ah, 0x2
    mov al, 0x2
    mov ch, 0x0
    mov cl, 0x2
    mov dh, 0x0
    mov dl, [BOOT_DRIVE]
    mov bx, KERNEL_OFFSET
    int 0x13
    ret

[bits 32]

protectedModeInit:
    mov ax, DATA_SEGMENT
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    mov eax, 0
    mov edi, 0x1000
    mov ecx, edi
    mov cr3, edi
    rep stosd

    mov edi, 0x1000
    mov dword [edi], 0x2003
    add edi, 0x1000
    mov dword [edi], 0x3003
    add edi, 0x1000
    mov dword [edi], 0x4003
    add edi, 0x1000
    
    mov dword ebx, 0x3
    mov ecx, 0x200
    setEntryLoop:
        mov dword [edi], ebx
        add ebx, 0x1000
        add edi, 8
        loop setEntryLoop

    mov eax, cr4

    mov eax, 0xc0000080
    rdmsr
    or eax, 1<<8
    wrmsr

    jmp longModeInit

[bits 64]

longModeInit:
    jmp KERNEL_OFFSET
    jmp $

[bits 32]

GDT_START:
    GDT_NULL:
        dd 0x0
        dd 0x0
    GDT_CODE:
        dw 0xffff
        dw 0x0
        db 0x0
        db 10011010b
        db 11001111b
        db 0x0
    GDT_DATA:
        dw 0xffff
        dw 0x0
        db 0x0
        db 10010010b
        db 11001111b
        db 0x0
GDT_END:

GDT_DESCRIPTOR:
    dw GDT_END - GDT_START
    dd GDT_START

CODE_SEGMENT equ GDT_CODE - GDT_START
DATA_SEGMENT equ GDT_DATA - GDT_START

BOOT_DRIVE db 0

times (510-($-$$)) db 0x0
dw 0xaa55
