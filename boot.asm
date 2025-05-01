; boot.asm - minimal x86 BIOS bootloader with disk-loading stub
; Assemble: nasm -f bin boot.asm -o boot.bin
; Create image: dd if=boot.bin of=floppy.img bs=512 count=1

[org 0x7C00]
[BITS 16]

start:
    cli                     ; disable interrupts
    xor ax, ax
    mov ss, ax              ; setup stack at 0x0000:0x0000
    mov sp, 0x7C00
    sti                     ; enable interrupts

    mov [boot_drive], dl    ; save BIOS drive number

    ; print initial message
    mov si, msg
    call print_string

    ; load next sector (LBA 1) into 0x0000:0x8000
    mov dl, [boot_drive]
    mov ah, 0x02            ; BIOS read sectors
    mov al, 1               ; read 1 sector
    mov ch, 0               ; track 0
    mov cl, 2               ; sector 2 (LBA 1)
    mov dh, 0               ; head 0
    mov bx, 0x8000          ; ES:BX -> 0x0000:0x8000
    mov es, ax
    int 0x13                ; BIOS Disk IO
    jc disk_error

    ; jump to loaded code
    jmp 0x0000:0x8000

disk_error:
    mov si, err_msg
    call print_string
    hlt                     ; halt on error

;----------------------------------------------------
; BIOS teletype print routine (AH=0x0E)
print_string:
    mov ah, 0x0E
.next_char:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next_char
.done:
    ret

; Data
boot_drive db 0
msg        db 'Bootloader: stage 1 loaded.',0x0D,0x0A,0
err_msg    db 'Error: disk read failed!',0x0D,0x0A,0

; pad to 510 bytes
times 510 - ($ - $$) db 0
; boot signature
dw 0xAA55
