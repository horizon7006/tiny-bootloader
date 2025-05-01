[org 0x7C00]
[BITS 16]

start:
    ; print message
    mov si, msg
    call print_string

    ; hang forever
hang:
    jmp hang

; BIOS teletype print
print_string:
    mov ah, 0x0E    ; teletype service
.next:
    lodsb           ; load next character into AL
    cmp al, 0
    je .done
    int 0x10        ; BIOS video interrupt
    jmp .next
.done:
    ret

msg db 'Hello from bootloader!', 0

; fill up to 510 bytes
times 510 - ($ - $$) db 0
; boot signature
dw 0xAA55
