[bits 16]

GDTNullDescriptor:
    dd 0
    dd 0

GDTCodeDescriptor:
    dw 0xffff    ; Limit          0:15
    dw 0         ; Base           0:15
    db 0         ; Base          16:23
    db 10011010b ; Access Byte
    db 11001111b ; Flags & Limit 16:19
    db 0         ; Base          24:31

GDTDataDescriptor:
    dw 0xffff    ; Limit          0:15
    dw 0         ; Base           0:15
    db 0         ; Base          16:23
    db 10010010b ; Access Byte
    db 11001111b ; Flags & Limit 16:19
    db 0         ; Base          24:31

GDTEnd:

GDTDescriptor:
    GDTSize: dw GDTEnd - GDTNullDescriptor - 1 ; Size - 1
    GDTOffset: dd GDTNullDescriptor            ; Offset

codeSegment equ GDTCodeDescriptor - GDTNullDescriptor
dataSegment equ GDTDataDescriptor - GDTNullDescriptor

[bits 32]

; Modify the GDT to work in Long Mode
enableLongModeGDT:
    ; Set the L and Sz bit to 1 and 0
    mov byte [GDTCodeDescriptor + 6], 10101111b
    mov byte [GDTDataDescriptor + 6], 10101111b

    ret
