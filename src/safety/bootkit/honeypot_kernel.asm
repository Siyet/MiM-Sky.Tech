org 500h

message:
mov ax, 0002h
int 10h

mov dx,0h
call SetUserPriv
mov bp, Dicr
mov cx, 20
mov bl,04h
xor bh,bh
mov ax,1301h
int 10h

add dh,2
mov ss, tu
call SetUserPriv
mov si,0

RootedCommand:
mov ah,10h
int 16h
cmp ah, 0Eh
jz SymbolSystem
cmp al, 0Dh
jz KernelDevice
mov [Interrupts+si],al
inc si
mov ah,09h
mov bx,0004h
mov cx,1
int 10h
add dl,1
call SetUserPriv
jmp RootedCommand

KernelDevice:
mov ax,cs
mov ds,ax
mov es,ax
mov di, Interrupts
push si
mov si,ShutDown
mov cx,5
rep cmpsb
je UnderBoot
pop si
jmp RootedCommand

SymbolSystem:
cmp dl,0
jz RootedCommand
sub dl,1
call SetUserPriv
mov al,20h
mov [Interrupts+si],al
mov ah,09h
mov bx,0004h
mov cx,1
int 10h
dec si
jmp RootedCommand

UnderBoot:
mov ax,0000h
mov es,ax
mov bx,700h
mov ch,0
mov cl,03h
mov dh,0
mov dl,80h
mov al,01h
mov ah,02h
int 13h
jmp 0000:0700h

SetUserPriv:
mov ah,2h
xor bh,bh
int 10h
; mov dx,ax

retf
