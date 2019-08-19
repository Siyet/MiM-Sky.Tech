use16 ; 16bit

%define BIOS_RESET_CODE_1 0xf000 ; BIOS_RESET
%define BIOS_RESET_CODE_2 0xfff0 ; BIOS_RESET
%define MBR_CODE 0x7c00 ; MBR

org MBR_CODE

mov ax, cx

cli

mov ss, ax
mov es, ax
mov ds, ax

sti

xor al, al
xor dx,dx

int 0x13

jc kill_service

call boot

kill_service:
xor ax,ax
int 0x16
int 0x19

push BIOS_RESET_CODE_1
push BIOS_RESET_CODE_2

boot:
pop bp

int 0x10

jmp $

times 510-($-$$) db 0
