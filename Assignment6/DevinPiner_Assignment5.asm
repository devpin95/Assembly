TITLE template.asm
; Description: 
; Author: Devin Piner 107543409
; Date Created:

INCLUDE Irvine32.inc

.data
	;{your variables are to be defined here}
	MAX_STRING_LENGTH= 51				;Maximum number of characters (50), including null terminator (51)
	user_string BYTE "My String sucks", 0 ;51 DUP(0)			;String of 51 chars, with an extra byte for null terminator
	user_prompt BYTE "->", 0

.data?
	;{used as necessary}

.code

main PROC	
	;{executable code here}
	Beginning:
	;call Clrscr
	MOV EDX, OFFSET user_string
	call PrintMenu

	MOV EDX, OFFSET user_prompt
	call WriteString
	call ReadDec

	; Check that the user input is within the menu range
	; If user_selection > 6 || user_selection < 1
	CMP EAX, 6
	JA Beginning		;EAX > 6
	CMP EAX, 1
	JB Beginning		;EAX < 1

	; Check if the user wants to exit
	; If user_selection == 6
	CMP EAX, 6
	JE Ending

	; Check if the user entered 1
	; If user_selection == 1
	CMP EAX, 1
	JE Option1

	; Check if the user entered 2
	; If user_selection == 2
	CMP EAX, 2
	JE Option2

	; Check if the user entered 3
	; If user_selection == 3
	CMP EAX, 3
	JE Option3

	; Check if the user entered 4
	; If user_selection == 4
	CMP EAX, 4
	JE Option5

	; Check if the user entered 5
	; If user_selection == 5
	CMP EAX, 5
	JE Option5

	Option1:
		call Clrscr
		call EnterAString
		JMP Beginning
	Option2:
		call Clrscr
		call ToLower
		JMP Beginning
	Option3:
		call Clrscr
		call CleanStr
		JMP Beginning
	Option4:
		call Clrscr
		call IsPalindrome
		JMP Beginning
	Option5:
		call Clrscr
		call PrintString
		JMP Beginning

	Ending:
	exit
main ENDP	; end main procedure

PrintMenu PROC
; Prints out the main menu for the program
; Receives: address of the current string in ESI

	.data
	Menuprompt1 BYTE 'MAIN MENU', 0Ah, 0Dh,
		'===============================', 0Ah, 0Dh,
		"  ", 0
	Menuprompt2 BYTE "Current String: ", 0Dh, 0Ah, 09h, 0
	Menuprompt3 BYTE '===============================', 0Ah, 0Dh,
		'1. Enter a string', 0Ah, 0Dh,
		'2. Convert the string to lower case', 0Ah, 0Dh,
		'3. Remove all non-letter elements', 0Ah, 0Dh,
		'4. Is the string a palindrome?', 0Ah, 0Dh,
		'5. Print the string', 0Ah, 0Dh,
		'6. Quit', 0Ah, 0Dh, 0

	.code
		PUSH EDX

		MOV EDX, OFFSET MenuPrompt1
		call WriteString

		POP EDX
		call WriteString
		call Crlf

		MOV EDX, OFFSET MenuPrompt3
		call WriteString

	ret
PrintMenu ENDP

EnterAString PROC
	.data
		ttl BYTE "****Enter A String:", 0dh, 0ah, 0

	.code
	PUSH EDX
	MOV EDX, OFFSET ttl
	call WriteString

	POP EDX
	ret
EnterAString ENDP

ToLower PROC
	.data
		ttl1 BYTE "****To Lower", 0dh, 0ah, 0

	.code
	PUSH EDX
	MOV EDX, OFFSET ttl1
	call WriteString

	POP EDX
	ret
ToLower ENDP

CleanStr PROC
	.data
		ttl2 BYTE "****Clean String", 0dh, 0ah, 0

	.code
	PUSH EDX
	MOV EDX, OFFSET ttl2
	call WriteString

	POP EDX
	ret
CleanStr ENDP

IsPalindrome PROC
	.data
		ttl3 BYTE "****Is Palindrome", 0dh, 0ah, 0

	.code
	PUSH EDX
	MOV EDX, OFFSET ttl3
	call WriteString

	POP EDX
	ret
IsPalindrome ENDP

PrintString PROC
	.data
		ttl4 BYTE "****Print String", 0dh, 0ah, 0

	.code
	PUSH EDX
	MOV EDX, OFFSET ttl4
	call WriteString

	POP EDX
	ret
PrintString ENDP

END main	; end of source code