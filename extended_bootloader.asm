[org 0x7e00]
[bits 16]

extendedBootloaderStart:
    call enableProtectedMode
    jmp $

; Switches from Real Mode (16 bit) to Protected Mode (32 bit)
enableProtectedMode:
    ; Disable interrupts
    cli

    ; Check if A20 is enabled
    call checkA20
    cmp ax, 0
    ; If A20 is enabled we are done
    jne enableA20Done

    ; If A20 is disabled try to enable via BIOS interrupt 0x15
    call enableA20BIOS

    ; Check if A20 is enabled
    call checkA20
    cmp ax, 0
    ; If A20 is enabled we are done
    jne enableA20Done

    ; If A20 is disabled try to enable via the Keyboard Controller chip
    call enableA20Keyboard

    ; Check if A20 is enabled
    call checkA20
    cmp ax, 0
    ; If A20 is enabled we are done
    jne enableA20Done

    ; If A20 is disabled try to enable via FAST A20
    call enableA20Fast

    ; Check if A20 is enabled
    call checkA20
    cmp ax, 0
    ; If A20 is enabled we are done
    jne enableA20Done

    ; Failed to enable A20
    enableA20Failed:
        ; Print "Failed to enable A20!" message
        mov ax, enablingA20Failed
        call printString
        ret       

    ; A20 is enabled
    enableA20Done:
        ; Print "A20 gate enabled!" message
        mov ax, enabledA20
        call printString
    
    ; Load our GDT
    lgdt [GDTDescriptor]
   
    ; Set Protected Mode bit in cr0 register 
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp codeSegment:protectedModeStart

    ret

; Check if A20 is enabled
checkA20:
    ; Preserve flag, segment, and index registers
    pushf
    push ds
    push es
    push di
    push si

    ; [es:di] = [0000:0500] | [ds:si] = [ffff:0510]
    xor ax, ax
    mov es, ax
    not ax
    mov ds, ax ; NO WORK
    mov di, 0x0500
    mov si, 0x0510
    mov al, byte [es:di]
    push ax
    mov al, byte [ds:si]
    push ax

    ; Set [es:di] = 0 and [ds:si] = 0xff
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xff

    ; Check for wrap around of 0xff to [es:di]
    cmp byte [es:di], 0xff

    ; Restore [es:di] and [ds:si]
    pop ax
    mov byte [ds:si], al
    pop ax
    mov byte [es:di], al

    ; If 0xff did wrap around A20 is disabled return 0 else return 1
    mov ax, 0
    je .ret
    mov ax, 1
    .ret:   
        ; Restore flag, segment, and index registers
        pop si
        pop di
        pop es
        pop ds
        popf

        ret

; Enable A20 gate using BIOS interrupt 0x15 function 0x2401
enableA20BIOS:
    mov ax, 0x2401
    int 0x15
    ret

; Enable A20 gate using the Keyboard Controller chip
enableA20Keyboard:
    ; Disable keyboard
    call wait8042Command
    mov al, 0xad
    out 0x64, al

    ; Read from input
    call wait8042Command
    mov al, 0xd0
    out 0x64, al
    call wait8042Data
    in al, 0x60
    push eax

    ; Write to output
    call wait8042Command
    mov al, 0xd1
    out 0x64, al
    call wait8042Command
    pop eax
    or al, 2
    out 0x60, al

    ; Enable keyboard
    call wait8042Command
    mov al, 0xae
    out 0x64, al
    call wait8042Command
    ret

; Enable A20 gate using FAST A20 option
enableA20Fast:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

; Wait for Keyboard Controller chip to be ready for a command
wait8042Command:
    .loop:
        in al, 0x64
        test al, 2
        jnz .loop
    ret

; Wait for Keyboard Controller chip to be ready to send data
wait8042Data:
    .loop:
        in al, 0x64
        test al, 1
        jz .loop
    ret

[bits 32]

; Start Protected Mode code
protectedModeStart:
    ; Reset segment registers to our new Data Segment
    mov ax, dataSegment
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Move stack to higher memory to give us more space
    mov ebp, 0x90000
    mov esp, ebp

    call enableLongMode

    jmp $

; Checks if CPUID is supported
checkCPUID:
    ; Preserve flags
    pushfd
    ; Store flags
    pushfd
    ; Invert ID bit in stored flags
    xor dword [esp], 0x200000
    ; Load stored flags
    popfd
    ; Store flags again
    pushfd
    ; Load stored flags into eax
    pop eax
    ; Store the changed bits into eax
    xor eax, [esp]
    ; Restore original flags
    popfd
    ; Check if ID bit can be changed
    and eax, 0x200000
    ret

; Checks if Long Mode (64 bit) is supported
checkLongMode:
    ; Set the A-register to 0x80000000
    mov eax, 0x80000000
    ; CPUID
    cpuid
    ; Check if A-register is now 0x80000001
    cmp eax, 0x80000001
    ; If it is less LongMode is not supported
    jb .longModeNotSupported
    ; Set the A-register to 0x80000000
    mov eax, 0x80000001
    ; CPUID
    cpuid
    ; Test if the LM-bit (Long Mode bit) in the D-register is set
    test edx, 1 << 29
    ; If the LM-bit is 0 Long Mode is not supported
    jz .longModeNotSupported
    ; Long mode is supported
    .longModeSupported:
        mov eax, 1
        ret
    ; Lone mode is not supported
    .longModeNotSupported:
        mov eax, 0
        ret

enableLongMode:
    ; Check if CPUID is supported
    call checkCPUID
    cmp eax, 1
    ; If not halt
    jne .halt
    ; Check if Long Mode is supported
    call checkLongMode
    cmp eax, 1
    ; If not halt
    jne .halt

    ; Setup Identity Paging
    call setupIdentityPaging

    ; Enable Long Mode for the GDT
    call enableLongModeGDT

    jmp codeSegment:longModeStart    
 
    .halt:
        hlt

[bits 64]

longModeStart:
    mov byte [0xb8000], 'H'
    jmp $

; Includes
%include "print.asm"
%include "GDT.asm"
%include "paging.asm"

; Strings
enablingA20Failed: db "Failed to enable A20!", 0
enabledA20: db "A20 gate enabled!", 0

; Pad with 0s until it is 2kb
times 2048-($-$$) db 0
