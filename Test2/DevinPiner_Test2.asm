TITLE template.asm
; Description: 
; Author: Devin Piner 107543409
; Date Created:

INCLUDE Irvine32.inc

.data
	;{your variables are to be defined here}
	
	; Prompts
	WIN BYTE "You got the word!", 0
	LOSE BYTE "Sorry. You have no more guesses.", 0Ah, 0Dh, "The word was ", 0

	; Game variables
	LETTER_GUESS_MAX = 11						; the number of letter guesses to give the user
	WORD_GUESS_MAX = 3							; the number of word guesses to give the user
	MAX_STRING_LENGTH = 15						; the length of the longest string + 1

	; Possible game strings
	string0 BYTE "kiwi", 0
	string1 BYTE "conoe", 0
	string2 BYTE "doberman", 0
	string3 BYTE "frame", 0
	string4 BYTE "banana", 0
	string5 BYTE "orange", 0
	string6 BYTE "frigate", 0
	string7 BYTE "ketchup", 0
	string8 BYTE "postal", 0
	string9 BYTE "basket", 0
	string10 BYTE "cabinet", 0
	string11 BYTE "birch", 0
	string12 BYTE "machine", 0
	string13 BYTE "mississipian", 0
	string14 BYTE "destroyer", 0
	string15 BYTE "tank", 0
	string16 BYTE "fruit", 0
	string17 BYTE "engine", 0
	string18 BYTE "strangerthings", 0
	string19 BYTE "train", 0
	strings DWORD string0, string1, string2, string3, string4, string5, string6,
				 string7, string8, string9, string10, string11, string12, string13,
				 string14, string15, string16, string17, string18, string19
	strings_length BYTE 4, 5, 8, 5, 6, 6, 7, 7, 6, 6, 7, 5, 7, 12, 9, 4, 5, 6, 14, 5
	guessed_letters BYTE LETTER_GUESS_MAX dup(0)
	correct_guesses BYTE 0
	TOTAL_STRINGS = 20

	; Game data
	current_string DWORD 0							; The word the user has to guess
	current_string_length BYTE 0					; the words length
	current_string_guesses BYTE 14 DUP('_'), 0		; string holding the user's correctly guessed letters
	current_guess BYTE 15 DUP(0)					; string to hold the word guessed by the user
	letter_guesses BYTE LETTER_GUESS_MAX			; the total number of letter guesses remaining
	word_guesses BYTE WORD_GUESS_MAX				; the total number of word guesses remaining

	; Meta game data
	total_games BYTE 0
	total_wins BYTE 0
	total_losses BYTE 0

.data?
	;{used as necessary}

.code

main PROC	
	;{executable code here}

	MOV EBX, TOTAL_STRINGS
	call PickGameString
	MOV EDX, [strings+EAX*4]
	MOV current_string, EDX
	MOV DL, [strings_length+EAX]
	MOV current_string_length, DL

	show_game_instructions:
		call Instructions
		call WaitMsg
		call Clrscr

	start_game:

		; check if the user has guessed all the letters correctly
		MOV AL, correct_guesses
		CMP AL, current_string_length
		JE WINNER

		; check how many letter and word guesses are left
		MOV AL, letter_guesses
		CMP AL, 0
		JA StillPlaying
		MOV AL, word_guesses
		CMP AL, 0
		JE LOSER

		StillPlaying:
		MOV EDX, OFFSET current_string_guesses
		MOVZX ECX, current_string_length
		MOV CH, correct_guesses
		MOV EBX, OFFSET guessed_letters
		MOV AL, LETTER_GUESS_MAX
		
		call Clrscr

		call PrintGuesses
		call Crlf
		call Crlf
		;MOV EDX, current_string
		;call WriteString
		;MOV EAX, ECX
		;call Crlf
		;MOVZX EAX, current_string_length
		;call WriteDec
		;call Crlf

		MOV AL, letter_guesses
		MOV AH, word_guesses
		call PrintMainMenu

		call ReadDec

		; Check that the user input is within the menu range
		; If user_selection > 6 || user_selection < 1
		;CMP EAX, 6
		;JA Error		;EAX > 6
		;CMP EAX, 1
		;JB Error		;EAX < 1

		; Check if the user wants to exit
		; If user_selection == 4
		CMP EAX, 4
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

		Option1:
			; Guess a letter
			call Clrscr

			CMP letter_guesses, 0
			JE start_game

			MOV EDX, OFFSET current_string_guesses
			MOVZX ECX, current_string_length
			MOV CH, correct_guesses
			MOV EBX, OFFSET guessed_letters
			MOV AL, LETTER_GUESS_MAX
			call PrintGuesses
			call Crlf
			call Crlf

			MOV EAX, 0
			call GetUserChar
			
			; Receives: offset of array in ESI, char in AL, array length in AH
			; Returns: 1 in AH if letter is in the array, 0 if not 
			MOV ESI, OFFSET guessed_letters
			MOV AH, LETTER_GUESS_MAX
			call CheckIfLetterUsed

			MOVZX ESI, letter_guesses
			DEC ESI
			MOV [guessed_letters+ESI], AL

			CMP AH, 0
			JE NotGuessed
			jmp skip_checks

			NotGuessed:
			; Receives: String length in CL, guessed char in CH, game string in EDX, offset display string in EBX
			; Returns: number of letter matches in CL
			MOV EDX, current_string
			MOV EBX, OFFSET current_string_guesses
			MOV CL, current_string_length
			MOV CH, AL
			call GuessALetter
			ADD correct_guesses, CL

			skip_checks:
			DEC letter_guesses
			jmp start_game

		Option2:
			; Guess a word
			MOV EDX, OFFSET current_guess
			MOVZX ECX, current_string_length
			INC ECX
			call ReadString
			DEC word_guesses
			jmp start_game

		Option3:
			; Encrypt
			jmp start_game
	
	WINNER:
		call Clrscr
		MOV EDX, current_string
		call WriteString
		call Crlf
		MOV EDX, OFFSET WIN
		call WriteString
		call Crlf
		JMP Ending
	LOSER:
		call Clrscr
		MOV EDX, OFFSET LOSE
		call WriteString
		MOV EDX, current_string
		call WriteString
		call Crlf
		JMP Ending

	Ending:
	call WaitMsg
exit
main ENDP	; end main procedure

Instructions PROC
.data
	words BYTE "Hangman!", 0Ah, 0Dh, "You have 11 attempts to guess what letters are in the word", 0Ah, 0Dh,
				"and 3 attempts the guess the word. ", 0
.code
	MOV EDX, OFFSET words
	call WriteString

	ret
Instructions ENDP

PickGameString PROC
; Returns a number from 0 - (EBX-1)
; Receives: the range starting at 0 in EBX
	call Randomize
	;PUSH EAX
	MOV EAX, 00FFFFFFFh
	MOV EDX, 0
	call RandomRange

	DIV EBX
	MOV EAX, EDX

	ret
PickGameString ENDP

PrintGuesses PROC
; Prints out the guessed letters for the current string
; Receives: offset of guesses string in EDX, length of the string in CL, number of correct letters in CH, 
;			offset of guessed letters in EBX, number of guessed letters in AL

.data
	left BYTE "(", 0
	slash BYTE "/", 0
	right BYTE ")", 0
	left1 BYTE "[ ", 0
	right1 BYTE "]", 0
.code
	PUSH EAX
	PUSH EBX
	PUSH ECX
	MOVZX ECX, CL
	MOV EBX, 0
	MOV AL, 20h
	call WriteChar
	call WriteChar
	call WriteChar
	L1:
		MOV AL, [EDX+EBX]
		call WriteChar
		MOV AL, 20h
		call WriteChar
		INC EBX
		LOOP L1

	POP ECX

	MOV EBX, 0
	MOV AL, 20h
	call WriteChar
	call WriteChar

	MOV EDX, OFFSET left
	call WriteString
	MOVZX EAX, CH
	call WriteDec
	MOV EDX, OFFSET slash
	call WriteString
	MOVZX EAX, CL
	call WriteDec
	MOV EDX, OFFSET right
	call WriteString

	call Crlf

	MOV AL, 20h
	call WriteChar
	call WriteChar
	call WriteChar
	MOV EDX, OFFSET left1
	call WriteString

	POP EBX
	POP EAX
	MOV EDX, EBX
	MOVZX ECX, AL
	MOV EBX, 0

	L2:
		MOV AL, [EDX+EBX]
		CMP AL, 0
		JE continue

		call WriteChar
		MOV AL, 20h
		call WriteChar

		continue:
		INC EBX
	LOOP L2
	MOV EDX, OFFSET right1
	call WriteString

	ret
PrintGuesses ENDP

PrintMainMenu PROC
.data
	menu1 BYTE "1. Guess a letter (", 0
	menu2 BYTE "/11)", 0Ah, 0Dh, 0
	menu3 BYTE "2. Guess the word (", 0
	menu4 BYTE "/3)", 0Ah, 0Dh, 
				"4. Exit", 0Ah, 0Dh,
				"->", 0
.code
	MOV EDX, OFFSET menu1
	call WriteString
	PUSH EAX
	MOVZX EAX, AL
	call WriteDec
	POP EAX
	MOVZX EAX, AH
	MOV EDX, OFFSET menu2
	call WriteString
	MOV EDX, OFFSET menu3
	call WriteString
	call WriteDec
	MOV EDX, OFFSET menu4
	call WriteString
	ret
PrintMainMenu ENDP

GuessALetter PROC
; Returns the number of letter matches found in the string, and puts the guessed char in the display string
; Receives: String length in CL, guessed char in CH, game string in EDX, offset display string in EBX
; Returns: number of letter matches in CL
; Requires: 
.data
	char BYTE 0
	correct BYTE 0
.code
	; save the char entered by the user
	MOV char, CH
	MOV CH, 0
	MOVZX ECX, CL

	MOV ESI, 0

	L1:
		MOV AL, [EDX+ESI]
		CMP AL, char
		JNE Continue

		MOV [EBX+ESI], AL
		INC correct

		Continue:
		INC ESI
	LOOP L1

	MOV CL, correct
	MOV correct, 0
	ret
GuessALetter ENDP

CharToLower PROC
; Receives: char in AL
; Returns: char converted to lowercase
; Requires: 

	
	; To convert a string to lowercase, loop through the string and check what range
	; the character lands in. More the current character into AL and call IsAlpha.
	; IsAlpha will return 1 in AH if the character is lower case, 1 in AL if it is
	; uppercase, or 0 in both if it is not a letter. If the character is a alpha letter
	; check if it is an uppercase letter. If so, add 32 to the uppercase letter to 
	; convert it to lowercase. Move that new letter into the current spot to "remove"
	; the uppercase letter. For each non-letter character, skip to the next letter

	PUSH EAX							; Save the letter because IsAlpha will erase it
	call IsAlpha						; check if the character is a letter

	CMP AH, 1							; If AH is 1, it is a uppercase letter
	POP EAX								; POP the letter out so that if it is uppercase we can use it
	JNE continue

	ADD EAX, 32d

	continue:
	ret
CharToLower ENDP

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

GetUserChar PROC
; Gets a char from the user
; Recieves:
; Returns: user-entered char in AL, converted to lowercase
.data
	p_guess_letter BYTE "Guess a letter", 0Ah, 0Dh, "->", 0

.code
	; Get the user char
	MOV EDX, OFFSET p_guess_letter
	call WriteString
	call ReadChar

	; Print the char to the screen so that the user can see that they entered it correctly
	call WriteChar
	PUSH EAX
	MOV EAX, 100
	call Delay
	POP EAX
	call CharToLower

	ret
GetUserChar ENDP

CheckIfLetterUsed PROC
; Check if a letter is in the array (it has already been guessed)
; Receives: offset of array in ESI, char in AL, array length in AH
; Returns: 1 in AH if letter is in the array, 0 if not
; Requires: 

.data
	flg BYTE 0
.code
	MOV flg, 0
	MOVZX ECX, AH
	MOV EBX, 0			; iterator

	L1:
		MOV AH, [ESI+EBX]
		CMP AH, AL
		JNE ContinueL1

		MOV flg, 1
		JMP BreakL1

		ContinueL1:
		INC EBX
	LOOP L1

	BreakL1:
	MOV AH, flg
	ret
CheckIfLetterUsed ENDP

GuessAString PROC

	ret
GuessAString ENDP

END main	; end of source code