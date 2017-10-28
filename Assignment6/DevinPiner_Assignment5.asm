TITLE DevinPiner_Assignment5.asm
; Description: Prompt a user to enter a string an perform functions on that string
; Author: Devin Piner 107543409
; Date Created: Oct. 24, 2017

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
	; Print out the menu
	Beginning:
	MOV EDX, OFFSET user_string
	call PrintMenu

	; print out the prompt and read in the user selection
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
		; Read String
		MOV EDX, OFFSET user_string
		MOV ECX, MAX_STRING_LENGTH
		call Clrscr
		call EnterAString
		MOV user_string_length, EAX
		JMP Beginning
	Option2:
		; To lower
		MOV ESI, OFFSET user_string
		MOV ECX, user_string_length
		call Clrscr
		call ToLower
		JMP Beginning
	Option3:
		; Remove special characters
		MOV ESI, OFFSET user_string
		MOV ECX, user_string_length
		call Clrscr
		call CleanStr
		MOV user_string_length, EDX
		JMP Beginning
	Option4:
		; palindrome
		call Clrscr
		MOV ESI, OFFSET user_string
		MOV EDX, user_string_length
		call IsPalindrome
		JMP Beginning
	Option5:
		; print string
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
; Returns:
; Requires:

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
		; save the user strings
		PUSH EDX
		
		; print out the first part of the string
		MOV EDX, OFFSET MenuPrompt1
		call WriteString

		; get the user strings, then print out the third part of the menu
		POP EDX
		call WriteString
		call Crlf

		; print out the last part of the menu
		MOV EDX, OFFSET MenuPrompt3
		call WriteString

	ret
PrintMenu ENDP

EnterAString PROC
; Gets a string from the user
; Receives: string address in edx, string length in EAX (null terminator included in count)
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

	ret
EnterAString ENDP

ToLower PROC
; Receives: address of a string in ESI, string length in ECX
; Returns: the string with all alpha characters in lowercase
; Requires: 

	; Before coninuting, make sure the string is not empty
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
	ToLower_L1:
		MOV AL, BYTE PTR [ESI+EDX]			; Mov the first char of the string into EAX
		PUSH EAX							; Save the letter because IsAlpha will erase it
		call IsAlpha						; check if the character is a letter

		CMP AH, 1							; If AH is 1, it is a lowercase letter
		POP EAX								; POP the letter out so that if it is uppercase we can use it
		JNE ToLower_L1_Continue				; If AH != 1 go to the next loop iteration

		ADD EAX, 32d						; If we're here, the letter is uppercase. Add 32 to make it lowercase
		MOV [ESI+EDX], AL					; No put the new lowercase letter into the stri ng

		ToLower_L1_Continue:
		INC EDX								; Increment the index
	LOOP ToLower_L1

	; Restore the registers
	POP EAX
	POP EDX

	DontDo:									; Go here if we want to skip the whole proc
	ret
ToLower ENDP

CleanStr PROC
; Removes all non-letter characters from a string
; Receives: address of the string in ESI, length of the string in ECX
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

		; If the string is empty, dont look at the characters and just say that it is a palindrome
		CMP EDX, 0
		JE IsAPalindrome

		; To check if the string is a palindrome, first go through the string an remove all spaces.
		; This will make it easier to step through using a temp string to compare each letter. 
		; Once all spaces have been removed, use indexes at the beginning and end of the string to
		; check each letter with the one at the other end of the string. To do this, EBX starts at
		; the beginning of the string (0) and EDX starts at the end. At each step, mov the letters
		; into AH and AL and compare them for equality. Don't do anything unless the characters are 
		; different. If the are different, immediately jump to NotAPalindrome and print that the 
		; string is not a palindrome. If they are the same, continue to the next letter. If the 
		; indexes pass each other (EBX>EDX), then we have compared every letter in the string and
		; we know that is is a palindrome.

		MOV ECX, EDX								; Move the string length into ECX for the loop
		SUB ECX, 1									; subtract 1 from the length because the string is 0 based
		MOV EDX, 0									; Move 0 into EDX to keep track of the temp string size

		IsPalindrome_RemoveSpace:
			MOV AL, [ESI+ECX]						; move the current letter into AL
			CMP AL, 020h							; Compare it to a space
			JE skip_space							; If it is a space, skip to the next loop ("remove the space")

			MOV [spaceless_temp_string+EDX], AL		; If we get here, the character is not a space, so add it to the temp string
			INC EDX									; increment the size of the temp string

			skip_space:
		LOOP IsPalindrome_RemoveSpace

		PUSH EDX									; Save edx, the size of the new string
		MOV AL, [ESI]								; Move the first letter into AL because it didnt get checked in the loop
		CMP AL, 020h								; Compare it to a space
		JE skip_space_last							; if it is a space, skip it

		MOV [spaceless_temp_string+EDX], AL			; If we get here the letter is not a space, so add it to the temp string
		INC EDX										; increment the size of the temp string
		skip_space_last:

		MOV [spaceless_temp_string+EDX], 0			; add a null terminator to the end of the temp string

		MOV EDX, OFFSET spaceless_temp_string		; Move the offset of the temp string into EDX
		call WriteString							; Print out the string
		call Crlf

		POP EDX										; Restore EDX after it was overwritten to print out the string
		MOV EBX, 0									; move 0 into the EBX to use it in the next loop

		IsPalindrome_L1:
			MOV AL, [spaceless_temp_string+EDX]		; Move the characters at the end of the string into AL
			MOV AH, [spaceless_temp_string+EBX]		; Move the characters at the front of the string into AH
			CMP AL, AH								; Compare the characters
			JNE NotAPalindrome						; Only jump if they are not the same

			INC EBX									; Increment the front index
			DEC EDX									; Increment the back index

			CMP EBX, EDX							; Compare the values of the indexes
			JA IsAPalindrome						; If EBX is greater than EDX, we have checked all the letters and
													; there were no conflicts (the string is a palindrome)

		LOOP IsPalindrome_L1
		JMP IsAPalindrome							; If we get here for some reason, the string must be a palindrome
													; because there were no conflicts and the indexes passed each other

		NotAPalindrome:								; If we get here, the string is not a palindrome
			MOV EAX, 0								; Move 0 into EAX for false
			MOV EDX, OFFSET is_false				; Print out a message that it is not a palindrome
			call WriteString
			call Crlf
			call Crlf
			JMP get_out								; Get out of the proc
		IsAPalindrome:								; If we get here, the string is a palindrome
			MOV EAX, 1								; Move 1 into EAX for true
			MOV EDX, OFFSET is_true					; Print out a message that it is a palindrome
			call WriteString
			call Crlf
			call Crlf
	
		get_out:									; If we get here, we want to exit the proc
		ret
IsPalindrome ENDP

PrintString PROC
; Prints the string along with it's length
; Receives: address of string in EDX, string length in EAX
; Returns: Prints the string and it's length
; Requires:
	.data
		ttl4 BYTE "Length: ", 0

	.code

	call WriteString						; Print out the string who's address was passed in EDX
	call Crlf

	; save the registers because they will get overwritten next
	PUSH EDX
	PUSH EAX

	MOV EDX, OFFSET ttl4					; Print out the text "Length:"
	call WriteString
	call WriteDec							; Print out the value passed in EAX
	call Crlf
	call Crlf

	; restore the registers
	POP EAX
	POP EDX
	ret
PrintString ENDP

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

END main	; end of source code