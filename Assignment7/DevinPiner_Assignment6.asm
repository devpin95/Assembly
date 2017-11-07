TITLE template.asm
; Description: 
; Author: Devin Piner 107543409
; Date Created:

INCLUDE Irvine32.inc

.data
	;{your variables are to be defined here}
	MAX_STRING_LENGTH = 50d
	user_string BYTE 51 DUP(0)
	user_string_length BYTE 0
	user_key BYTE 51 DUP(0)
	user_key_length BYTE 0


.data?
	;{used as necessary}

.code

main PROC	
	;{executable code here}

	Error:
		call Clrscr
	Beginning:

	MOV EDX, OFFSET user_string
	MOV EBX, OFFSET user_key
	call PrintMenu

	call ReadDec

	; Check that the user input is within the menu range
	; If user_selection > 6 || user_selection < 1
	CMP EAX, 6
	JA Error		;EAX > 6
	CMP EAX, 1
	JB Error		;EAX < 1

	; Check if the user wants to exit
	; If user_selection == 5
	CMP EAX, 5
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

	Option1:
		; Read String (key)
		call Clrscr
		MOV EDX, OFFSET user_string
		MOV ECX, MAX_STRING_LENGTH
		call EnterAString
		MOV user_string_length, AL
		call Clrscr
		JMP Beginning
	Option2:
		; Read String (phrase)
		call Clrscr
		MOV EDX, OFFSET user_key
		MOV ECX, MAX_STRING_LENGTH
		call EnterAString
		MOV user_key_length, AL
		call Clrscr
		JMP Beginning
	Option3:
		; Encrypt
		call Clrscr
		call Encrypt
		JMP Beginning
	Option4:
		; Decrypt
		call Clrscr
		call Decrypt
		JMP Beginning
	Option5:
		; print string
		call Clrscr
		JMP Beginning

	Ending:
	call WaitMsg

exit
main ENDP	; end main procedure

PrintMenu PROC
	.data
		top BYTE	"=========================================", 0Ah, 0Dh,
					"   Key: ", 0
		phrase BYTE "   Phrase: ", 0
		menu BYTE	"=========================================", 0Ah, 0Dh,
					"1. Enter a Key" , 0Ah, 0Dh,
					"2. Enter a String", 0Ah, 0Dh,
					"3. Encrypt", 0Ah, 0Dh,
					"4. Decrypt", 0Ah, 0Dh,
					"5. Quit", 0Ah, 0Dh,
					"->", 0
	.code

	PUSH EDX

	MOV EDX, OFFSET top
	call WriteString

	POP EDX
	call WriteString
	call Crlf

	MOV EDX, OFFSET phrase
	call WriteString

	MOV EDX, EBX
	call WriteString
	call Crlf

	MOV EDX, OFFSET menu
	call WriteString

	ret
PrintMenu ENDP

ToUpper PROC
; Receives: address of a string in ESI, string length in ECX
; Returns: the string with all alpha characters in lowercase
; Requires: 

	; Before continuing, make sure the string is not empty
	CMP ECX, 0
	JBE DontDo
	
	; To convert a string to lowercase, loop through the string and check what range
	; the character lands in. More the current character into AL and call IsAlpha.
	; IsAlpha will return 1 in AH if the character is lower case, 1 in AL if it is
	; uppercase, or 0 in both if it is not a letter. If the character is a alpha letter
	; check if it is an uppercase letter. If so, add 32 to the uppercase letter to 
	; convert it to lowercase. Move that new letter into the current spot to "remove"
	; the uppercase letter. For each non-letter character, skip to the next letter

	; save EDX and EAX
	PUSH EDX
	PUSH EAX

	; Move 0 into EDX. We will use EDX as an index into the string
	MOV EDX, 0

	; loop through the string
	ToUpper_L1:
		MOV AL, BYTE PTR [ESI+EDX]			; Mov the first char of the string into EAX
		PUSH EAX							; Save the letter because IsAlpha will erase it
		call IsAlpha						; check if the character is a letter

		CMP AL, 1							; If AH is 1, it is a lowercase letter
		POP EAX								; POP the letter out so that if it is uppercase we can use it
		JNE ToUpper_L1_Continue				; If AH != 1 go to the next loop iteration

		SUB EAX, 32d						; If we're here, the letter is lowercase. subtract 32 to make it lowercase
		MOV [ESI+EDX], AL					; No put the new uppercase letter into the string

		ToUpper_L1_Continue:
		INC EDX								; Increment the index
	LOOP ToUpper_L1

	; Restore the registers
	POP EAX
	POP EDX

	DontDo:									; Go here if we want to skip the whole proc
	ret
ToUpper ENDP

IsAlpha PROC
; Returns true if a character is a letter A-Z or a-z
; Recieves: The character in AL
; Returns: 1 in AL if lowercase, 1 in AH if uppercase, 0 in both in non-alpha character
; Requires: 

	; To check if a character is a letter, we must check that it falls into the ranges
	; 041h-05Ah (A-Z) or 061h-07Ah (a-z). To do this, if the value is less than 'A', 
	; or greater than 'z', we know that it is not a letter. If we don't fall out of the
	; proc after checking those, we check if the character is less than 'Z'. If it is
	; the letter is uppercase. If not, we check that it is greater than 'a'. If it is
	; the letter is lower case. If neither of those conditions hold, we know that it is
	; is a special character between 'Z' and 'a'

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

	IsAlpha_Return_Lower:							; If we get here, the letter is lowercase
		MOV EAX, 0									; Clear EAX
		MOV AL, 1									; Move 1 into AL to flag lowercase
		JMP IsAlpha_Exit
	IsAlpha_Return_Upper:							; If we get here, the letter is uppercase
		MOV EAX, 0									; Clear EAX
		MOV AH, 1									; Move 1 into AH to flag uppercase
		JMP IsAlpha_Exit
	IsAlpha_Return_0:								; If we get here, the char is a special character
		MOV EAX, 0									; Move 0 into EAX to flag a special char

	IsAlpha_Exit:
	ret

IsAlpha ENDP

EnterAString PROC
; Gets a string from the user
; Receives: string address in edx, string length in ECX (null terminator included in count)
; Returns: the string entered by the user, string length in EAX
; Expects: 
	.data
		ttl BYTE "Enter A String (50 Characters or fewer): ", 0

	.code

	; save the user string and print out the prompt
	PUSH EDX
	MOV EDX, OFFSET ttl
	call WriteString

	; get back the user string and get it from the user
	POP EDX
	call ReadString

	; Receives: address of a string in ESI, string length in ECX
	MOV ESI, EDX
	MOV ECX, EAX
	call ToUpper

	ret
EnterAString ENDP

Encrypt PROC
	.data
		stump BYTE "ENCRYPT!!!", 0Ah, 0Dh, 0
	.code
		MOV EDX, OFFSET stump
		call WriteString
	ret
Encrypt ENDP

Decrypt PROC
	.data
		stump1 BYTE "Decryptomaniac", 0Ah, 0Dh, 0
	.code
		MOV EDX, OFFSET stump1
		call WriteString
	ret
Decrypt ENDP

END main	; end of source code