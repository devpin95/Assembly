;//Fall 2017 In class Homework 5

INCLUDE Irvine32.inc

maxStringLength = 51d

clearEAX TEXTEQU <mov eax, 0>
clearEBX TEXTEQU <mov ebx, 0>
clearECX TEXTEQU <mov ecx, 0>
clearEDX TEXTEQU <mov edx, 0>
clearESI TEXTEQU <mov esi, 0>
clearEDI TEXTEQU <mov edi, 0>

.data

UserOption BYTE 0h
theString BYTE maxStringLength DUP (0)
theStringLength BYTE ?  ;// user entered string length NOT the max length
  
.code
main PROC
 
;//clear registers

clearEAX
clearEBX
clearECX
clearEDX
clearESI
clearEDi
 
startHere:
call DisplayMenu
call ReadHex
mov UserOption, al

;// Procedure selection process
;// setting up for future procedure calls.
mov edx, OFFSET theString
mov ecx, lengthof theString

opt1:
cmp UserOption, 1
jne Opt2
call clrscr
mov ecx, maxstringlength
call option1
mov theStringLength, al 
jmp startHere

opt2:
cmp UserOption, 2
jne Opt3
movzx ecx, theStringLength
call option2
jmp startHere

opt3:
cmp UserOption, 3
jne Opt4
movzx ecx, theStringLength
call clrscr
call option3
jmp startHere

opt4:
cmp UserOption, 4
jne Opt4
movzx ecx, theStringLength
call option4
jmp startHere

opt5:
cmp UserOption, 5
jne Opt6
movzx ecx, theStringLength
call option5
jmp startHere

opt6:
cmp UserOption, 6
je quitit
call oops
jmp startHere


quitit:
exit
main ENDP

displayMenu PROC uses EDX
;Description:  Displays menu
;Receives: Nothing
;Returns: Nothing
;
 
.data
Menuprompt1 BYTE 'MAIN MENU', 0Ah, 0Dh,
'=========', 0Ah, 0Dh,
'1. Enter a string', 0Ah, 0Dh,
'2. Convert the string to lower case', 0Ah, 0Dh,
'3. Remove all non-letter elements', 0Ah, 0Dh,
'4. Is the string a palindrome?', 0Ah, 0Dh,
'5. Print the string', 0Ah, 0Dh,
'6. Quit', 0Ah, 0Dh, 0h
.code
call clrscr
mov edx, Offset Menuprompt1
call WriteString
ret
displayMenu ENDP

option1 Proc uses ecx
;//description : get string from user
;//receives: offset of string in edx, maxlength in ecx
;//returns: user entered string Offset not changed
;//         length of string returned in eax
.data

userPrompt1 byte "enter your string --> ", 0

.code
push edx             ;//save offset of string to stack
mov edx, Offset userPrompt1
call writeString
pop edx              ;//restore offset of string
call ReadString      ;//get user input

ret
option1 ENDP

option2 Proc uses edx ecx edi
;//Description : Converts all Capital Letters to lowercase
;//Receives:     Offset of the string in edx
;//              string length in ecx
;//Returns:      Original string with all capital letters 
;//              converted to lower case


loop2:
mov al, byte ptr [edx+edi] ;//grab element of string
cmp al, 41h
jb keepgoing
cmp al, 5Ah
ja keepgoing
add al, 20h
mov byte ptr [edx+edi], al 
keepgoing:
inc edi
loop loop2

ret
option2 ENDP

option3 Proc

ret
option3 ENDP

option4 Proc

ret
option4 ENDP


option5 Proc

ret
option5 ENDP



oops Proc USES EDX
;Description: Prints error message
;Receives nothing
;returns nothing
.data
Caption BYTE "*** Error ***",0
OopsMsg BYTE "You have chosen an invalid option!", 0ah, 0dh, 0

.code
mov edx, Offset Caption
mov edx, offset OopsMsg
call msgBox
ret
Oops ENDP




 
 END main