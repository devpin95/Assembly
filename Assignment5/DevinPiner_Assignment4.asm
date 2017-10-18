TITLE DevinPiner_reorder.asm
; Description: Reorder the elements of an array using XCHG
; Author: Devin Piner 107543409
; Date Created: Sept. 22, 2017

INCLUDE Irvine32.inc

.data
maxStringLenth = 51d

UserOption BYTE 0h
theString BYTE maxStringLength DUP (0)
theStringLength BYTE ?

.data?

.code
main PROC
	;clear registers
	MOV EAX, 0
	MOV EBX, 0
	MOV ECX, 0
	MOV EDX, 0
	MOV ESI, 0
	MOV EDI, 0

	startHere:
		call DisplayMenu
		call ReadHex
		mov UserOption, al

	;Procedure selection process
	;setting up for future procedure calls
	mov EDX, OFFSET theString
	mov ECX, lengthof theString

	Opt1:
		cmp UserOption, 1
		jne Opt2
		call clrscr
		call option1
		mov theStringLength, al
		jmp startHere

	Opt2:
		

	call DumpRegs

exit
main ENDP	;end main procedure







	displayMenu PROC uses EDX
	;Displays menu
	;Revieves: nothing

		.data
		MenuPrompt1 BYTE 'MAIN MENU', 0AH, 0DH,
						 '1. Enter a String',
						 '2. Convert the string to lowercase', 0AH, 0DH,
						 '3. Remove all non-letter elements', 0AH, 0DH,
						 '4. Is the string a palindrome?', 0AH, 0DH,
						 '5. Print the String', 0AH, 0DH,
						 '6. Quit', 0AH, 0DH, 0h

		.code
			call clrscr
			mov EDX, OFFSET MenuPrompt1
			call WriteString
			ret
	displayMenu ENDP

	option1 PROC uses ECX
	;Description: Get string from user
	;Receives: offset of string in edx
	;Returns: user entered string offset not changed
	;	length of string returned in eax

		.data
		userPrompt BYTE 'Enter your string:', 0

		.code
			push EDX
			mov EDX, OFFSET userPrompt
			call WriteString
			pop EDX
			call ReadString

			ret
	option1 ENDP


	option2 PROC
	;

		ret
	option2 ENDP



END main	;end of source code