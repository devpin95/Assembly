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

	clearESI TEXTEQU <MOV ESI, 0>
	clearEDI TEXTEQU <MOV EDI, 0>


.data?
	;{used as necessary}

.code

main PROC	
	;{executable code here}

	Error:
		call Clrscr
	Beginning:

	MOV EDX, OFFSET user_key
	MOV EBX, OFFSET user_string
	MOVZX ECX, user_string_length
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

		; Receives: string address in edx, 
		; string length in CL (null terminator included in count), 
		; mode in CH (1 for phrase, 0 for key)
		; offset of global string length variable in EAX
		MOV EDX, OFFSET user_key
		MOV CL, MAX_STRING_LENGTH
		MOV CH, 0
		MOV EAX, OFFSET user_key_length
		call EnterAString

		call Clrscr
		JMP Beginning
	Option2:
		; Read String (phrase)
		call Clrscr

		; Receives: string address in edx, 
		; string length in CL (null terminator included in count), 
		; mode in CH (1 for phrase, 0 for key)
		; offset of global string length variable in EAX
		MOV EDX, OFFSET user_string
		MOV CL, MAX_STRING_LENGTH
		MOV CH, 1
		MOV EAX, OFFSET user_string_length
		call EnterAString

		call Clrscr
		JMP Beginning
	Option3:
		; Encrypt
		call Clrscr

		; Recieves: Phrase offset in EDX
		; Key offset in ESI
		; Phrase length in AL
		; Key length in AH
		MOV EDX, OFFSET user_string
		MOV ESI, OFFSET user_key
		MOV AH, user_string_length
		MOV AL, user_key_length
		call Encrypt
		JMP Beginning
	Option4:
		; Decrypt
		call Clrscr

		; Recieves: Phrase offset in EDX
		; Key offset in ESI
		; Phrase length in AL
		; Key length in AH
		MOV EDX, OFFSET user_string
		MOV ESI, OFFSET user_key
		MOV AH, user_string_length
		MOV AL, user_key_length
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
;MOV EDX, OFFSET user_string
;MOV EBX, OFFSET user_key
; Recieves: offset of phrase in EDX, offset of key in EBX, length of phrase in ECX
	.data
		top BYTE	"=========================================", 0Ah, 0Dh,
					"   Key: ", 0
		phrase BYTE "   Phrase: ", 0
		menu BYTE	"=========================================", 0Ah, 0Dh,
					"1. Enter a Key" , 0Ah, 0Dh,
					"2. Enter a Phrase", 0Ah, 0Dh,
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
	call PrintPhrase
	call Crlf

	MOV EDX, OFFSET menu
	call WriteString

	ret
PrintMenu ENDP

PrintPhrase PROC
; Print the phrase
; Recieves: OFFSET of phrase in EDX, length of phrase in ECX

	CMP ECX, 0
	JE skip

	MOV EBX, 0
	MOV AH, 0
	L1:
		CMP AH, 5
		JNE continue

		MOV AL, 20h
		call WriteChar
		MOV AH, 0

		continue:
		MOV AL, [EDX+EBX]
		call WriteChar
		INC EBX
		INC AH
	LOOP L1

	skip:
	ret
PrintPhrase ENDP

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
; Receives: string address in edx, 
;			string length in CL (null terminator included in count), 
;			mode in CH (1 for phrase, 0 for key)
;			offset of global string length variable in EAX
; Returns: the string entered by the user
; Expects: 
	.data
		ttl BYTE "Enter A String (50 Characters or fewer): ", 0
		data_length BYTE 0

	.code

	PUSH EAX
	PUSH ECX
	; save the user string and print out the prompt
	PUSH EDX
	MOV EDX, OFFSET ttl
	call WriteString

	; get back the user string and get it from the user
	POP EDX
	MOVZX ECX, CL
	call ReadString
	MOV data_length, AL
	POP ECX
	POP EAX

	PUSH EDX
	MOV DL, data_length
	MOV [EAX], DL
	POP EDX

	CMP CH, 1
	JNE Return

	PUSH ECX
	; Receives: address of a string in ESI, string length in ECX
	MOV ESI, EDX
	MOVZX ECX, data_length
	call ToUpper
	POP ECX

	PUSH EAX
	; Receives: address of the string in ESI, 
	; length of the string in ECX
	; Returns: length of the new string in EDX
	MOVZX ECX, data_length
	MOV EBX, OFFSET user_string_length
	call CleanStr
	POP EAX
	MOV [EAX], DL

	Return:
	ret
EnterAString ENDP

Encrypt PROC
; Encrypts the string based on the key passed in
; Recieves: Phrase offset in EDX
;			Key offset in ESI
;			Phrase length in AL
;			Key length in AH
	.data
		keylen BYTE 0
		phraselen BYTE 0
		key_char BYTE 0
	.code
		
		MOV keylen, AL
		DEC keylen
		MOV phraselen, AH
		DEC phraselen
		MOV BL, 0			; index to key
		MOV BH, 0			; index to phrase

		MOVZX ECX, phraselen
		INC ECX

		L1:

			CMP BH, keylen
			JBE continue

			MOV BH, 0			; reset the index of the key string

			continue:
			PUSH EBX
			MOVZX EBX, BH
			MOV AL, [ESI+EBX]
			POP EBX

			MOV key_char, AL

			PUSH EBX
			MOV BL, 26d
			MOVZX AX, AL
			DIV BL
			POP EBX

			PUSH EBX
			MOVZX EBX, BL
			MOV AL, [EDX+EBX]
			POP EBX

			PUSH ECX
			MOVZX ECX, AH
			CMP ECX, 0
			JE no_offset
			L2:
				INC AL
				CMP AL, 'Z'
				JBE keepgoing

				loop_back:
				MOV AL, 'A'
				keepgoing:
			LOOP L2
			no_offset:
			POP ECX

			PUSH EAX
			PUSH EBX
			;MOV AL, key_char
			MOVZX EBX, BL
			MOV [EDX+EBX], AL
			POP EBX
			POP EAX

			INC BL
			INC BH

		LOOP L1
	ret
Encrypt ENDP

Decrypt PROC
	.data
		keylen1 BYTE 0
		phraselen1 BYTE 0
		key_char1 BYTE 0
	.code
		
		MOV keylen1, AL
		DEC keylen1
		MOV phraselen1, AH
		DEC phraselen1
		MOV BL, 0			; index to key
		MOV BH, 0			; index to phrase

		MOVZX ECX, phraselen1
		INC ECX

		L1:

			CMP BH, keylen1
			JBE continue

			MOV BH, 0			; reset the index of the key string

			continue:
			PUSH EBX
			MOVZX EBX, BH
			MOV AL, [ESI+EBX]
			POP EBX

			MOV key_char1, AL

			PUSH EBX
			MOV BL, 26d
			MOVZX AX, AL
			DIV BL
			POP EBX

			PUSH EBX
			MOVZX EBX, BL
			MOV AL, [EDX+EBX]
			POP EBX

			PUSH ECX
			MOVZX ECX, AH
			CMP ECX, 0
			JE no_offset
			L2:
				DEC AL
				CMP AL, 'A'
				JAE keepgoing

				loop_back:
				MOV AL, 'Z'
				keepgoing:
			LOOP L2
			no_offset:
			POP ECX

			PUSH EAX
			PUSH EBX
			MOVZX EBX, BL
			MOV [EDX+EBX], AL
			POP EBX
			POP EAX

			INC BL
			INC BH

		LOOP L1
	ret
Decrypt ENDP

CleanStr PROC
; Removes all non-letter characters from a string
; Receives: address of the string in ESI, 
;			length of the string in ECX
; Returns: the cleaned string at the address passed in through ESI, length of the new string in EDX
	.data
		temp_string BYTE 51 DUP(0)			; A string to hold the string without special chars

	.code

	; Before coninuting, make sure the string is not empty
	CMP ECX, 0
	JBE DontDo

	; To remove the special characters from the string, loop through the string and test
	; if the current character is an alpha letter using IsAlpha. We will use EBX as an index into 
	; the user-entered string and EDX as an index into the new temporary string containing only
	; letters. Only increment EDX when we add a letter into the new string. Using IsAlpha,
	; if the proc returns 1 in AL or AH, we know that the character is a letter and we dont want
	; to get rid of it. If the register is 0, it is a special character and we want to skip adding
	; it to the new string. Once we have gone through all of the original string, we need to go back
	; and copy the new string into the same memory. To do this, we start back at the beginning of the
	; original string and move the character at the same index of the new string into the original string.
	; We also need to make sure that the new string is null terminated.

	; save the register
	PUSH EBX

	; use the registers as indecis into the strings
	MOV EDX, 0
	MOV EBX, 0

	CleanStr_L1:
		
		MOV AL, [ESI+EBX]							; Move the current letter into AL at string[EBX]
		PUSH EAX									; Save the letter so we can use it later after EAX gets overwritten
		call IsAlpha								; Check if the character is a letter

		CMP AL, 1									; Check if AL is set (the character is a lowercase letter)
		JE CleanStr_L1_AddChar						; If so, add the character to the new string
		CMP AH, 1									; Check if AH is set (the character is a uppercase letter)
		JE CleanStr_L1_AddChar						; If so, add the character to the new string

		POP EAX										; Get the current letter off the stack because we dont want to leave it there
		JMP CleanStr_L1_Skip						; then skip to the next letter

		CleanStr_L1_AddChar:
		POP EAX										; If we get here, we need to get the letter off the stack
		MOV [temp_string+EDX], AL					; and put it into the new string
		INC EDX										; and increment the count

		CleanStr_L1_Skip:							; If we get here, we want to go to the next letter
		INC EBX										; Increment the index to the original string

	LOOP CleanStr_L1

	; Move the length of the new string into ECX for the loop and 0 into EBX for the index of the original string
	MOV ECX, EDX
	MOV EBX, 0

	; Loop through the original string and replace the old characters with the new ones
	CleanStr_L2:
		MOV AL, [temp_string + EBX]					; Move the new char into AL
		MOV [ESI + EBX], AL							; then move it into the original string
		INC EBX										; Increment the index into the oringinal string
		MOV AL, 0									; put 0 into AL
		MOV [ESI + EBX], AL							; So that we can put a null terminator
	LOOP CleanStr_L2

	; Restore the register
	POP EBX	

	DontDo:
	MOV EBX, 0
	ret
CleanStr ENDP

ClearString PROC USES EDX ECX ESI
;Description:  Clears a byte array given offset in edx and length in ecx
;Receives: Offset of string to be cleared in edx
;          length of string to be cleared in ecx
;Returns: nothing


;// increment through the passed array and set every element to zero
clearESI
ClearIt:
mov byte ptr [edx + esi], 0
inc esi
loop ClearIt

ret
ClearString ENDP

END main	; end of source code