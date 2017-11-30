TITLE template.asm
; Description: Create an encryption/decryption system using a Caesar Cipher
; Author: Devin Piner 107543409
; Date Created: November 8, 2017

INCLUDE Irvine32.inc

.data
	;{your variables are to be defined here}
	MAX_STRING_LENGTH = 50d
	user_string BYTE 51 DUP(0)					; An array of bytes to hold the user's string
	user_string_length BYTE 0					; the length of the user's string
	user_key BYTE 51 DUP(0)						; An array of bytes to hold the user's key
	user_key_length BYTE 0						; the length of the users key

	clearESI TEXTEQU <MOV ESI, 0>				; moves 0 into ESI
	clearEDI TEXTEQU <MOV EDI, 0>				; moves 0 into EDI


.data?
	;{used as necessary}

.code

main PROC	
	;{executable code here}

	Error:										; If there was an error, come here
		call Clrscr								; clear the screen
	Beginning:									; come here to go back to the main menu

	; get the regiseters ready to print the menu
	MOV EDX, OFFSET user_key					; move the key's address into EDX
	MOV EBX, OFFSET user_string					; move the string's address into EBX
	MOVZX ECX, user_string_length				; Move the length of the string into ECX
	call PrintMenu								; print the main menu

	call ReadDec								; get the menu option from the user

	; Check that the user input is within the menu range
	; If user_selection > 6 || user_selection < 1
	CMP EAX, 5
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

	Option1:										; Read String (key)
		call Clrscr									; clear the screen

		; get the registers ready to enter a string
		; EnterAString Receives: string address in edx, 
		; string length in CL (null terminator included in count), 
		; mode in CH (1 for phrase, 0 for key)
		; offset of global string length variable in EAX
		MOV EDX, OFFSET user_key					; Move the key address into EDX
		MOV CL, MAX_STRING_LENGTH					; move the max key length into CL
		MOV CH, 0									; move 0 into CH (the mode for EnterAString)
		MOV EAX, OFFSET user_key_length				; move the address of the key length into EAX
		call EnterAString							; get a string from the user

		call Clrscr									; clear the screen
		JMP Beginning								; go back to the main menu

	Option2:										; Read String (phrase)
		call Clrscr									; clear the screen

		; get the registers ready to read a string
		; EnterAString Receives: string address in edx, 
		; string length in CL (null terminator included in count), 
		; mode in CH (1 for phrase, 0 for key)
		; offset of global string length variable in EAX
		MOV EDX, OFFSET user_string					; move the address of the string into EDX
		MOV CL, MAX_STRING_LENGTH					; move the max string length into CL
		MOV CH, 1									; move 1 in CH (the mode for EnterAString)
		MOV EAX, OFFSET user_string_length			; move the address of the string length into EAX
		call EnterAString							; get a string from the user

		call Clrscr									; clear the screen
		JMP Beginning								; go back to the main menu

	Option3:										; Encrypt
		call Clrscr									; clear the screen

		; get the register ready to encrypt the string using the key
		; Encrypt Recieves: Phrase offset in EDX
		; Key offset in ESI
		; Phrase length in AL
		; Key length in AH
		MOV EDX, OFFSET user_string					; move the address of the string into EDX		
		MOV ESI, OFFSET user_key					; move the address of the key into ESI
		MOV AH, user_string_length					; move the string length into AH
		MOV AL, user_key_length						; move the key length into AL
		call Encrypt								; encrypt the string
		JMP Beginning								; go back to the main menu

	Option4:										; Decrypt
		call Clrscr									; clear the screen

		; get the registers ready to decrypt the string using the key
		; Decrypt Recieves: Phrase offset in EDX
		; Key offset in ESI
		; Phrase length in AL
		; Key length in AH
		MOV EDX, OFFSET user_string					; move the address of the string into EDX
		MOV ESI, OFFSET user_key					; move the address of the key into ESI
		MOV AH, user_string_length					; move the string length into AH
		MOV AL, user_key_length						; move the key length into AL
		call Decrypt								; decrypt the string
		JMP Beginning								; go back to the main menu

	Ending:											; if we get here, we want to print the wait message and exit the program
	call WaitMsg

exit
main ENDP	; end main procedure

PrintMenu PROC
; Prints the main menu along with the current string and key 
; Recieves: offset of phrase in EDX, offset of key in EBX, length of phrase in ECX
; Returns:
; Requires:
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

	PUSH EDX									; save edx because we will overwrite it to print out the menu

	MOV EDX, OFFSET top							; print out the top line
	call WriteString

	POP EDX										; restore EDX so that we can print it
	call WriteString							; print the key
	call Crlf

	MOV EDX, OFFSET phrase						; Print out the phrase label
	call WriteString

	MOV EDX, EBX								; move the string address into EDX from EBX
	call PrintPhrase							; call print phrase, which will print out the string by 5 chars
	call Crlf

	MOV EDX, OFFSET menu						; print out the menu options
	call WriteString

	ret
PrintMenu ENDP

PrintPhrase PROC
; Prints the phrase out 5 characters at a time
; Recieves: OFFSET of phrase in EDX, length of phrase in ECX
; Returns:
; Requires:

	; To print out the phrase, we need to print out the string in groups of 5. We just need
	; to step through the string and keep track of how many characters have been printed in
	; the current group. Once 5 characters in a group have been printed, we print out a space
	; and start the next group of 5

	CMP ECX, 0						; if the string length is 0, just skip the function
	JE skip

	MOV EBX, 0						; move 0 into EBX to use it as an index
	MOV AH, 0						; move 0 in AH to use as a counter for the 5 chars
	L1:
		CMP AH, 5					; If AH is 5, there we need to make a new group of 5 chars
		JNE continue

									; if we get here, we need to print out a space
		MOV AL, 20h					; put 20h (space) into AH
		call WriteChar				; print it out
		MOV AH, 0					; make AH 0 to start a new group of 5

		continue:
		MOV AL, [EDX+EBX]			; move the char from the string into EDX
		call WriteChar				; print the char
		INC EBX						; increment the index to the string
		INC AH						; increment the number of chars in the current group of 5
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

	; To enter a string, we use the Irvine ReadStrin function to get a string from the use
	; along with its length. If the user is entering a phrase, we need to remove all special
	; characters and convert all letter to uppercase. If the user is entering a key, we dont
	; need to change the string at all. If the mode passed in in CH=1, the string will be 
	; cleaned. If CH=0, the string will not be altered

	PUSH EAX										; save EAX
	PUSH ECX										; save ECX
	PUSH EDX										; save EDX
	MOV EDX, OFFSET ttl								; save the user string and print out the prompt
	call WriteString

	POP EDX											; restore the user string address and get it from the user
	MOVZX ECX, CL									; move the string length into CL
	call ReadString									; Get the string from the user
	MOV data_length, AL								; store the length of the new string
	POP ECX											; Restore ECX
	POP EAX											; Restore EAX

	PUSH EDX										; Save the address of the new string
	MOV DL, data_length								; put the length of the new string into DL
	MOV [EAX], DL									; save the data length in the global variable
	POP EDX											; restore the address of the new string

	CMP CH, 1										; check the mode of the function
	JNE Return										; (0=key, 1=phrase)

	PUSH ECX										; save ECX

	; ToUpper Receives: address of a string in ESI, string length in ECX
	MOV ESI, EDX									; mov the address of the string into ESI
	MOVZX ECX, data_length							; move the length of the string into ECX
	call ToUpper									; convert the string to uppercase
	POP ECX											; restore the length of the string

	PUSH EAX										; save the address of the string length
	; CleanStr Receives: address of the string in ESI, 
	; length of the string in ECX
	; Returns: length of the new string in EDX
	MOVZX ECX, data_length							; move the length of the data into ECX
	MOV EBX, OFFSET user_string_length				; move the offset of the string length into EBX
	call CleanStr									; remove the special chars from the string
	POP EAX											; restore the old string length
	MOV [EAX], DL									; move the new string length into the variable from main

	Return:											; get out of the function
	ret
EnterAString ENDP

Encrypt PROC
; Encrypts the string based on the key passed in
; Recieves: Phrase offset in EDX
;			Key offset in ESI
;			Phrase length in AL
;			Key length in AH

	; To encrypt the string, we step through the key string and use the ascii value of each
	; char and divide it by 26d. Then we take the remained from the division and increment
	; the current character of the phrase string that number of times. For example, if we
	; have S from the phrase and want to increment it 23 times, we should get P. When the
	; increment passes Z, it loops back to A and continues incrementing. For each letter
	; of the phrase, we use the letter of the same index in the key. If the key is shorted 
	; than the phrase, the key loops back to the beginning and starts again.

	.data
		keylen BYTE 0
		phraselen BYTE 0
		key_char BYTE 0
	.code
		
		MOV keylen, AL								; move the length of the key into AL
		DEC keylen									; decrement the key length
		MOV phraselen, AH							; move the phrase length into AH
		DEC phraselen								; decrement the phrase length
		MOV BL, 0									; move 0 into BL as an index to key
		MOV BH, 0									; move 0 into BH as an index to phrase

		MOVZX ECX, phraselen						; extend the phrase length into ECX for the outer loop
		INC ECX										; increment ECX so that we dont skip the last letter

		L1:											; outer loop, steps through the strings

			CMP BH, keylen							; first, check if the key index has gone past the end of the string
			JBE continue							; If BH is <= keylen, continue with the loop

			MOV BH, 0								; if the index of the key has gone too far, reset it to the first char

			continue:								; here, we need to get the key char and the phrase char
			PUSH EBX								; save EBX, the indexes of the strings
			MOVZX EBX, BH							; extend the phrase index into EBX
			MOV AL, [ESI+EBX]						; get the current key character
			POP EBX									; restore the string indexes

			MOV key_char, AL						; save the key character

			PUSH EBX								; save the string indexes
			MOV BL, 26d								; put 26d into BL (the number we are using for the modulo)
			MOVZX AX, AL							; extend the character into AX
			DIV BL									; divide the character by 26d
			POP EBX									; restore the string indexes

			PUSH EBX								; save the string indexes
			MOVZX EBX, BL							; extend the phrase index into EBX
			MOV AL, [EDX+EBX]						; move the phrase character into AL
			POP EBX									; restore the string indexes

			PUSH ECX								; save the outer loop counter
			MOVZX ECX, AH							; extend the remainder from the division into ECX for the loop
			CMP ECX, 0								; only continue if the remained is not 0
			JE no_offset

			L2:										; increment the phrase char remained times
				INC AL								; go to the next char
				CMP AL, 'Z'							; compare the char to Z
				JBE keepgoing						; if the char is <= Z, keep going

				loop_back:							; If we get here, the char is > Z
				MOV AL, 'A'							; We need to loop the char back to A
				keepgoing:							; go to the next loop
			LOOP L2

			no_offset:								; If we get here, we have skipped the string or already encrypted it
			POP ECX									; restore the loop counter for the outer loop

			PUSH EAX								; save EAX
			PUSH EBX								; save EBX
			MOVZX EBX, BL							; extend the key index into EBX
			MOV [EDX+EBX], AL						; move the encrypted char into the phrase
			POP EBX									; restore EBX
			POP EAX									; restore EAX

			INC BL									; Increment the key index
			INC BH									; increment the phrase index

		LOOP L1
	ret
Encrypt ENDP

Decrypt PROC
	.data
		keylen1 BYTE 0
		phraselen1 BYTE 0
		key_char1 BYTE 0
	.code
		
		; To decrypt the string, we step through the key string and use the ascii value of each
		; char and divide it by 26d. Then we take the remainer from the division and decrement
		; the current character of the phrase string that number of times. For example, if we
		; have P from the phrase and want to increment it 23 times, we should get S. When the
		; increment passes A, it loops back to Z and continues decrementing. For each letter
		; of the phrase, we use the letter of the same index in the key. If the key is shorted 
		; than the phrase, the key loops back to the beginning and starts again.

		MOV keylen1, AL								; move the length of the key into AL
		DEC keylen1									; decrement the key length
		MOV phraselen1, AH							; move the phrase length into AH
		DEC phraselen1								; decrement the phrase length
		MOV BL, 0									; index to key
		MOV BH, 0									; index to phrase

		MOVZX ECX, phraselen1						; extend the phrase length into ECX for the outer loop
		INC ECX										; increment ECX so that we dont skip the last letter

		L1:											; outer loop, steps through the strings

			CMP BH, keylen1							; first, check if the key index has gone past the end of the string
			JBE continue							; If BH is <= keylen, continue with the loop

			MOV BH, 0								; reset the index of the key string

			continue:								; here, we need to get the key char and the phrase char
			PUSH EBX								; save EBX, the indexes of the strings
			MOVZX EBX, BH							; extend the phrase index into EBX
			MOV AL, [ESI+EBX]						; get the current key character
			POP EBX									; restore the string indexes

			MOV key_char1, AL						; save the key character

			PUSH EBX								; save the string indexes
			MOV BL, 26d								; put 26d into BL (the number we are using for the modulo)
			MOVZX AX, AL							; extend the character into AX
			DIV BL									; divide the character by 26d
			POP EBX									; restore the string indexes

			PUSH EBX								; save the string indexes
			MOVZX EBX, BL							; extend the phrase index into EBX
			MOV AL, [EDX+EBX]						; move the phrase character into AL
			POP EBX									; restore the string indexes

			PUSH ECX								; save the outer loop counter
			MOVZX ECX, AH							; extend the remainder from the division into ECX for the loop
			CMP ECX, 0								; only continue if the remained is not 0
			JE no_offset

			L2:										; increment the phrase char remained times
				DEC AL								; go to the previous char
				CMP AL, 'A'							; compare the char to A
				JAE keepgoing						; if the char is >= A, keep going

				loop_back:							; If we get here, the char is < A
				MOV AL, 'Z'							; We need to loop the char back to Z
				keepgoing:							; go to the next loop
			LOOP L2

			no_offset:								; If we get here, we have skipped the string or already encrypted it
			POP ECX									; restore the loop counter for the outer loop

			PUSH EAX								; save EAX
			PUSH EBX								; save EBX
			MOVZX EBX, BL							; extend the key index into EBX
			MOV [EDX+EBX], AL						; move the encrypted char into the phrase
			POP EBX									; restore EBX
			POP EAX									; restore EAX

			INC BL									; Increment the key index
			INC BH									; increment the phrase index

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