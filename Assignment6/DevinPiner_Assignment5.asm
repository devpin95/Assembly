TITLE template.asm
; Description: 
; Author: Devin Piner 107543409
; Date Created:

INCLUDE Irvine32.inc

.data
	;{your variables are to be defined here}
	MAX_STRING_LENGTH = 51				;Maximum number of characters (50), including null terminator (51)
	user_string_length DWORD 0
	user_string BYTE 51 DUP(0)			;String of 51 chars, with an extra byte for null terminator
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
	JE Option4

	; Check if the user entered 5
	; If user_selection == 5
	CMP EAX, 5
	JE Option5

	Option1:
		MOV EDX, OFFSET user_string
		MOV ECX, MAX_STRING_LENGTH
		call Clrscr
		call EnterAString
		MOV user_string_length, EAX
		JMP Beginning
	Option2:
		MOV ESI, OFFSET user_string
		MOV ECX, user_string_length
		call Clrscr
		call ToLower
		JMP Beginning
	Option3:
		MOV ESI, OFFSET user_string
		MOV ECX, user_string_length
		call Clrscr
		call CleanStr
		MOV user_string_length, EDX
		JMP Beginning
	Option4:
		call Clrscr
		MOV ESI, OFFSET user_string
		MOV EDX, user_string_length
		call IsPalindrome
		JMP Beginning
	Option5:
		MOV EDX, OFFSET user_string
		MOV EAX, user_string_length
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
		'4. Palindrome Test', 0Ah, 0Dh,
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
; Gets a string from the user
; Receives: string address in edx, string length in EAX (null terminator included in cound)
; Returns: the string entered by the user, string length in EAX
; Expects: 
	.data
		ttl BYTE "Enter A String (50 Characters or fewer): ", 0

	.code
	PUSH EDX
	MOV EDX, OFFSET ttl
	call WriteString

	POP EDX
	call ReadString

	ret
EnterAString ENDP

ToLower PROC
; Receives: address of a string in ESI, string length in ECX
; Returns: the string with all alpha characters in lowercase
; Requires: 

	CMP ECX, 0
	JBE DontDo
	
	PUSH EDX
	PUSH EAX

	MOV EDX, 0

	ToLower_L1:
		MOV AL, BYTE PTR [ESI+EDX]			;Mov the first char of the string into EAX
		PUSH EAX
		call IsAlpha

		CMP AH, 1
		POP EAX
		JNE ToLower_L1_Continue

		ADD EAX, 32
		MOV [ESI+EDX], AL

		ToLower_L1_Continue:
		INC EDX
	LOOP ToLower_L1

	POP EAX
	POP EDX

	DontDo:
	ret
ToLower ENDP

CleanStr PROC
; Removes all non-letter characters from a string
; Receives: address of the string in ESI, length of the string in ECX
; Returns: the cleaned string at the address passed in through ESI, length of the new string in EDX
	.data
		temp_string BYTE 51 DUP(0)			; A string to hold the string without special chars

	.code

	CMP ECX, 0
	JBE DontDo

	PUSH EBX

	MOV EDX, 0
	MOV EBX, 0

	CleanStr_L1:
		
		MOV AL, [ESI+EBX]
		PUSH EAX
		call IsAlpha

		CMP AL, 1
		JE CleanStr_L1_AddChar
		CMP AH, 1
		JE CleanStr_L1_AddChar
		

		COMMENT ?
			; B Check if the char is less than A (041h)
			CMP AL, 041h
			JB CleanStr_L1_Skip
			; A Check if the char is more than z (07Ah)
			CMP AL, 07Ah
			JA CleanStr_L1_Skip

			; C Check if the char is less than Z (05Ah)
			CMP AL, 05Ah
			JBE ClearStr_L1_AddChar
			; D Check if the char is more than a (061h)
			CMP AL, 061h
			JAE ClearStr_L1_AddChar
		?

		POP EAX
		JMP CleanStr_L1_Skip

		CleanStr_L1_AddChar:
		POP EAX
		MOV [temp_string+EDX], AL
		INC EDX

		CleanStr_L1_Skip:
		INC EBX

	LOOP CleanStr_L1

	MOV ECX, EDX
	MOV EBX, 0

	CleanStr_L2:
		MOV AL, [temp_string + EBX]
		MOV [ESI + EBX], AL
		INC EBX
		MOV AL, 0
		MOV [ESI + EBX], AL
	LOOP CleanStr_L2

	POP EBX

	DontDo:
	MOV EBX, 0
	ret
CleanStr ENDP

IsPalindrome PROC
; Returns true if the given string is a palindrome
; Receives: address of the string in ESI, length of the string in EDX
; Returns: 1 in AL if true, or 0 in AL if false
; Requires: 

	.data
	spaceless_temp_string BYTE 51 DUP(0)
	is_true BYTE "The string is a palindrome", 0
	is_false BYTE "The string is not a palindrome", 0

	.code

	CMP EDX, 0
	JE IsAPalindrome

	;PUSH EDX

	MOV ECX, EDX
	SUB ECX, 1
	MOV EDX, 0

	IsPalindrome_RemoveSpace:
		MOV AL, [ESI+ECX]
		CMP AL, 020h
		JE skip_space

		MOV [spaceless_temp_string+EDX], AL
		INC EDX

		skip_space:
	LOOP IsPalindrome_RemoveSpace

	PUSH EDX
	MOV AL, [ESI]
	CMP AL, 020h
	JE skip_space_last

	MOV [spaceless_temp_string+EDX], AL
	INC EDX
	skip_space_last:

	MOV [spaceless_temp_string+EDX], 0

	MOV EDX, OFFSET spaceless_temp_string
	call WriteString
	call Crlf

	POP EDX
	MOV EBX, 0
	;SUB EDX, 1

	IsPalindrome_L1:
		MOV AL, [spaceless_temp_string+EDX]
		MOV AH, [spaceless_temp_string+EBX]
		CMP AL, AH
		JNE NotAPalindrome

		INC EBX
		DEC EDX

		CMP EBX, EDX
		JA IsAPalindrome

	LOOP IsPalindrome_L1
	JMP IsAPalindrome

	NotAPalindrome:
		MOV EAX, 0
		MOV EDX, OFFSET is_false
		call WriteString
		call Crlf
		call Crlf
		JMP get_out
	IsAPalindrome:
		MOV EAX, 1
		MOV EDX, OFFSET is_true
		call WriteString
		call Crlf
		call Crlf
	
	get_out:
	;POP EDX
	ret
IsPalindrome ENDP

PrintString PROC
; Prints the string along with it's length
; Receives: address of string in EDX, string length in EAX
	.data
		ttl4 BYTE "Length: ", 0

	.code

	call WriteString
	call Crlf

	PUSH EDX
	PUSH EAX

	MOV EDX, OFFSET ttl4
	call WriteString
	call WriteDec
	call Crlf
	call Crlf

	POP EAX
	POP EDX
	ret
PrintString ENDP

IsAlpha PROC
; Returns true if a character is a letter A-Z or a-z
; Recieves: The character in AL
; Returns: 1 in AL if lowercase, 1 in AH if uppercase, 0 in both in non-alpha character
; Requires: 

	; B Check if the char is less than A (041h)
	CMP AL, 'A'
	JB IsAlpha_Return_0								; Jump if al < 'A'
	; A Check if the char is more than z (07Ah)
	CMP AL, 'z'
	JA IsAlpha_Return_0								; Jump if al > 'z'

	; C Check if the char is less than Z (05Ah)
	CMP AL, 'Z'
	JBE IsAlpha_Return_Upper						; Jump if al <= 'Z'
	; D Check if the char is more than a (061h)
	CMP AL, 'a'
	JAE IsAlpha_Return_Lower						; Jump if AL >= 'a'

	JMP IsAlpha_Return_0

	IsAlpha_Return_Lower:
		MOV EAX, 0
		MOV AL, 1
		JMP IsAlpha_Exit
	IsAlpha_Return_Upper:
		MOV EAX, 0
		MOV AH, 1
		JMP IsAlpha_Exit
	IsAlpha_Return_0:
		MOV EAX, 0

	IsAlpha_Exit:
	ret

IsAlpha ENDP

END main	; end of source code