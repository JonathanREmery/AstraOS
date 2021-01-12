[bits 32]

pageTableEntry equ 0x1000

setupIdentityPaging:
    mov edi, pageTableEntry
    mov cr3, edi

    mov dword [edi], 0x2003
    add edi, 0x1000

    mov word [edi], 0x3003
    add edi, 0x1000

    mov word [edi], 0x4003
    add edi, 0x1000

    mov ebx, 3
    mov ecx, 512

    .setEntry:
        mov dword [edi], ebx
        add ebx, 0x1000
        add edi, 8
        loop .setEntry

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xc0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret   
