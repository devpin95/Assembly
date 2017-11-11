TITLE template.asm
; Description: 
; Author: Devin Piner 107543409
; Date Created:

INCLUDE Irvine32.inc

.data
	;{your variables are to be defined here}
	
	; Prompts
	start_new_game BYTE "Continue? (y/n) ->", 0
	WIN BYTE "You got the word!", 0
	LOSE BYTE "Sorry. You have no more guesses.", 0Ah, 0Dh, "The word was ", 0
	wrong_letter BYTE " is not in the word", 0Ah, 0Dh, 0
	wrong_word BYTE " is not the correct word", 0Ah, 0Dh, 0
	games_won BYTE "Wins: ", 0
	games_lost BYTE "Losses: ", 0

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

	show_game_instructions:						; show the game rules to the user
		call Instructions
		call WaitMsg
		call Clrscr

	restart_game:
		call Clrscr
		MOV EBX, TOTAL_STRINGS							; first, we need to pick the game string from the pool of strings
		call PickGameString
		MOV EDX, [strings+EAX*4]						; now that we have the string, put it into EDX and then into current_string to use
		MOV current_string, EDX
		MOV DL, [strings_length+EAX]					; we also need the length of the string, get it by using the same index and the parallel arrays
		MOV current_string_length, DL

		MOV EDX, OFFSET current_string_guesses			; now we need to reset the letter guesses before continuing
		MOV ECX, 14										; we do this here so that when we restart the string is in the correct state
		call ResetCurrentGuesses
		MOV letter_guesses, LETTER_GUESS_MAX			; reset the number of letter guesses for the user
		MOV word_guesses, WORD_GUESS_MAX				; reset the number of word guesses for the user
		MOV EDX, OFFSET guessed_letters					; we also need to reset the letter board (the letters guessed by the user)
		MOV ECX, LETTER_GUESS_MAX						; this array always has the same number of letters as the max number of guesses
		call ResetGuessedLetter

	start_game:

		; check if the user has guessed all the letters correctly
		MOV AL, correct_guesses							; before we continue, we need to check if the number of correct guesses
		CMP AL, current_string_length					; is the same as the length of the string
		JE WINNER										; If they are the same, the user has guessed all the letters and has won

		; check how many letter and word guesses are left
		MOV AL, letter_guesses							; Check if there are still letter guesses for the user
		CMP AL, 0										; If there is more than 0 left, the user can still play
		JA StillPlaying
		MOV AL, word_guesses							; If the user has no more letter guesses left, check the nunmber of word guesses
		CMP AL, 0										; if the word and letter guesses are both 0, then the user has lost
		JE LOSER

		StillPlaying:									; If we get here, the user still has guesses remaining
		MOV EDX, OFFSET current_string_guesses			; put the address of the guessed letters into EDX
		MOVZX ECX, current_string_length				; put the current game string length in ECX
		MOV CH, correct_guesses							; put the number of correct guesses into CH
		MOV EBX, OFFSET guessed_letters					; put the letter board address into EBX
		MOV AL, LETTER_GUESS_MAX						; put the letter board length into AL

		call PrintGuesses								; Print out the guesses and the letter board
		call Crlf										; new line
		call Crlf										; new line

		MOV AL, letter_guesses							; put the number of letter guesses left in AL for the menu
		MOV AH, word_guesses							; put the number of word guesses left in AH for the menu
		call PrintMainMenu								; Print the main menu

		call ReadDec									; Get the menu choice from the user

		CMP EAX, 4										; Check if the user wants to exit: user_selection == 4
		JE GetOut

		CMP EAX, 1										; Check if the user entered 1 (guess a letter): user_selection == 1
		JE Option1

		CMP EAX, 2										; Check if the user entered 2 (guess a word):  user_selection == 2
		JE Option2

		CMP EAX, 3										; Check if the user entered 3: user_selection == 3
		JE Option3

		Option1:
			; Guess a letter
			call Clrscr

			CMP letter_guesses, 0						; If there are no more letter guesses left, just skip this options
			JE start_game

														; Get the registers ready to print out the guesses and letter board
			MOV EDX, OFFSET current_string_guesses		; put the address of the guessed letters into EDX
			MOVZX ECX, current_string_length			; put the current game string length in ECX
			MOV CH, correct_guesses						; put the number of correct guesses into CH
			MOV EBX, OFFSET guessed_letters				; put the letter board address into EBX
			MOV AL, LETTER_GUESS_MAX					; put the letter board length into AL
			call PrintGuesses							; print out the guesses and letter board
			call Crlf									; new line
			call Crlf									; new line

			MOV EAX, 0									; clear eax
			call GetUserChar							; get the char from the user
			
			; Receives: offset of array in ESI, char in AL, array length in AH
			; Returns: 1 in AH if letter is in the array, 0 if not 
			MOV ESI, OFFSET guessed_letters				; put the address of the letter board in ESI
			MOV AH, LETTER_GUESS_MAX					; put the length of the letter board in AH
			call CheckIfLetterUsed						; check if the letter has already been guessed

			MOVZX ESI, letter_guesses					; put the number of letter guesses into ESI
			DEC ESI										; dec esi to go to the next index
			MOV [guessed_letters+ESI], AL				; put the user-entered char into the letter board using ESI as an index

			CMP AH, 0									; If CheckIfLetterUsed returned 0 in AH, the letter has not been guessed
			JE NotGuessed								; if the letter has been guessed, skip the rest of the stuff
			jmp skip_checks

			NotGuessed:									; If we're here, the letter has not been guessed yet
			; get stuff ready for GuessALetter PROC
			; Receives: String length in CL, guessed char in CH, game string in EDX, offset display string in EBX
			; Returns: number of letter matches in CL
			MOV EDX, current_string
			MOV EBX, OFFSET current_string_guesses
			MOV CL, current_string_length
			MOV CH, AL
			call GuessALetter
			ADD correct_guesses, CL						; GuessALetter returns the number of matches the char made
														; so we need to add it to correct_guesses
			skip_checks:								; When we get here, we have gone through the function and need to get ready for the next
			call Clrscr
			DEC letter_guesses							; decremement the number of guesses
			jmp start_game								; go back to the main menu

		Option2:
			; Guess a word
			call Clrscr

			; get stuff ready for GuessAString
			; Receives: offset of the guess string in EDX, offset of the game string in EBX and length in AH
			; Returns: 1 in AL if the strings are the same, 0 in AL if they are not the same
			MOV EBX, current_string
			MOV AH, current_string_length
			MOV EDX, OFFSET current_guess
			call GuessAString

			call Clrscr

			CMP AL, 1							; if GuessAString returned 1, the string guessed matched
			JE WINNER							; and the user won
			MOV EDX, OFFSET current_guess		; otherwise, the strings didnt match and we need to tell the user
			call WriteString
			MOV EDX, OFFSET wrong_word			; print that the word was not correct
			call WriteString

			DEC word_guesses					; decremement the number of word guesses remaining
			jmp start_game						; go back to the main menu

		Option3:
			; print game stats
			jmp start_game
	
	WINNER:										; If we get here, the user has won the game
		call Clrscr
		MOV EDX, current_string					; print out the game string
		call WriteString
		call Crlf
		MOV EDX, OFFSET WIN						; print out that the user has won
		call WriteString
		call Crlf
		INC total_wins							; increment the total number of wins for the session
		JMP Ending								; go to the ending
	LOSER:										; If we get here, the user has lost the game
		call Clrscr
		MOV EDX, OFFSET LOSE					; print out that the user has lost
		call WriteString
		MOV EDX, current_string					; print out the string so the user can see what it was
		call WriteString
		call Crlf
		INC total_losses						; increment the total number of losses for the session
		JMP Ending								; go to the ending

	Ending:										; If we get here, we need to print the game status and ask the user if they want to play again
	MOV EDX, OFFSET games_won					; print the total number of games won
	call WriteString
	MOVZX EAX, total_wins
	call WriteDec
	call Crlf
	MOV EDX, OFFSET games_lost					; print the total number of games lost
	call WriteString
	MOVZX EAX, total_losses
	call WriteDec
	call Crlf

	MOV EDX, OFFSET start_new_game				; prompt the user if they want to play another game or quit
	call WriteString
	call ReadChar								; get the char and convert it to lowercase so that case doesnt matter
	call CharToLower
	CMP AL, 'y'									; y=play again, anything else is quit
	JE restart_game								; go back to the beginning of the game

	GetOut:
exit
main ENDP	; end main procedure

Instructions PROC
; Prints out the instruction for hangmane
; Recieves:
; Returns:
; Requires:
.data
	words BYTE "Hangman!", 0Ah, 0Dh, "You have 11 attempts to guess what letters are in the word", 0Ah, 0Dh,
				"and 3 attempts the guess the word. ", 0
.code
	MOV EDX, OFFSET words
	call WriteString
	ret
Instructions ENDP

PickGameString PROC
; Generates a random number between 0 and(EBX-1)
; Receives: the range starting at 0 in EBX
; Returns: 0-(EBX-1) in EAX
; Requires:

	; To generate the random number as required by the specification, we get a really big number
	; and divide it by the number of string, then use the mod as the index to the array of string.
	; To get the modulus, use EAX and EDX to do 32-bit division. The quotient will be returned
	; in EAX and the remainder (the number we want) will be returned in EDX. The specification
	; didnt say how big the number had to be, so I just made a 32-bit size number with 0 as the
	; most significant byte so that it wont be negative

	call Randomize							; seed it
	MOV EAX, 00FFFFFFFh						; make the real big number
	MOV EDX, 0								; put 0 in EDX so that it isnt sign
	call RandomRange						; get a random number between 0 and EAX (the really big number)

	DIV EBX									; EBX is storing the divisor, so DIV will do EDX:EAX/EBX
	MOV EAX, EDX							; EAX (quotient), EDX (remainder)

	ret
PickGameString ENDP

PrintGuesses PROC
; Prints out the guessed letters for the current string
; Receives: offset of guesses string in EDX, length of the string in CL, number of correct letters in CH, 
;			offset of guessed letters in EBX, number of guessed letters in AL
; Returns:
; Requires:

.data
	left BYTE "(", 0
	slash BYTE "/", 0
	right BYTE ")", 0
	left1 BYTE "[ ", 0
	right1 BYTE "]", 0
.code

	; To print the guesses, we print out the guesses string filled in with the
	; letters that were correctly guessed. Following the letters guessed is the
	; number of correctly guessed letter out of the total number of letters in 
	; the string (n/m). Then we print out the letter board, which displays all of
	; the letters guessed by the user (not just the ones that were guessed correctly)

	PUSH EAX								; Save EAX
	PUSH EBX								; Save EBX
	PUSH ECX								; Save ECX

	MOVZX ECX, CL							; Extend the length of the guesses string to the rest of ECX to use in the loop
	MOV EBX, 0								; Make EBX 0 to use as an index in the array

	MOV AL, 20h								; Print out 3 spaces
	call WriteChar
	call WriteChar
	call WriteChar

	; Print out the correct guesses
	L1:
		MOV AL, [EDX+EBX]					; Put the letter into AL and print out
		call WriteChar
		MOV AL, 20h							; Print out a space to separate the letters
		call WriteChar
		INC EBX								; increment the index to the array
		LOOP L1

	POP ECX									; restore ECX so that we can get back the number of correct guesses

	MOV EBX, 0								; make EBX 0 to use it as an index again

	; Print out the number of correct letters out of the total length of the string
	MOV AL, 20h								; print out 2 spaces
	call WriteChar
	call WriteChar

	MOV EDX, OFFSET left					; Print out the left parenthesis
	call WriteString
	MOVZX EAX, CH							; Print out the number of correct guesses
	call WriteDec
	MOV EDX, OFFSET slash					; Print out a /
	call WriteString
	MOVZX EAX, CL							; Print out length of the string
	call WriteDec
	MOV EDX, OFFSET right					; Print out he right parenthesis
	call WriteString

	call Crlf								; new line

	; Print out the letter board (all the guesses made by the user)
	MOV AL, 20h								; Print out 3 spaces
	call WriteChar
	call WriteChar
	call WriteChar

	MOV EDX, OFFSET left1					; Print out the left square bracket
	call WriteString

	POP EBX									; Restore EBX to get back the address of the letter board
	POP EAX									; Restore EAX to get back the length of the letter board
	MOV EDX, EBX							; PUT the address of the letter board into EDX so that we can use EBX as an index
	MOVZX ECX, AL							; Put length of the letter board into ECX to use for the loop
	MOV EBX, 0								; make EBX 0 to use it as an index again

	L2:
		MOV AL, [EDX+EBX]					; Get the letter from the letter board
		CMP AL, 0							; Check if it has been set
		JE continue

		call WriteChar						; If the letter has been set, print it
		MOV AL, 20h							; add a space after the letter
		call WriteChar

		continue:
		INC EBX								; increment the index to the array
	LOOP L2

	MOV EDX, OFFSET right1					; Print out the right square bracket
	call WriteString

	ret
PrintGuesses ENDP

PrintMainMenu PROC
; Prints the main game menu
; Receives:
; Returns:
; Requires:

.data
	menu1 BYTE "1. Guess a letter (", 0
	menu2 BYTE "/11)", 0Ah, 0Dh, 0
	menu3 BYTE "2. Guess the word (", 0
	menu4 BYTE "/3)", 0Ah, 0Dh, 
				"4. Exit", 0Ah, 0Dh,
				"->", 0
.code
	MOV EDX, OFFSET menu1				; Print out "1. Guess a letter ("
	call WriteString
	PUSH EAX							; save EAX so that we can extend each number into the whole register
	MOVZX EAX, AL						; Print out the number of letter guesses left
	call WriteDec
	POP EAX								; restore the register and extend the number of word guesses left
	MOVZX EAX, AH						
	MOV EDX, OFFSET menu2				; Print out "/11)"
	call WriteString
	MOV EDX, OFFSET menu3				; Print out "2. Guess the word ("
	call WriteString
	call WriteDec						; Print out the number of word guesses left
	MOV EDX, OFFSET menu4				; Print out "4. Exit ->", 0
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

	; To guess a letter, step through the string and count the number of times the chars match.
	; Using the parallel strings (current_string & current_string_guesses ), for each matching
	; char in current_string, copy that char into current_string_guesses at the same index

	MOV char, CH							; save the char entered by the user so that we can use the register for other stuff
	MOV CH, 0								; clear the register
	MOVZX ECX, CL							; extend the string length to the rest of the register

	MOV ESI, 0								; move 0 into ESI and use it as an index into the string

	L1:
		MOV AL, [EDX+ESI]					; pull out the char from the string
		CMP AL, char						; compare it to the letter entered by the user
		JNE Continue

		MOV [EBX+ESI], AL					; if the characters match, add it to the current_string_guesses at the same index
		INC correct							; Increment the total number of correct matches

		Continue:
		INC ESI								; Increment the index to the string
	LOOP L1

	MOV CL, correct							; Put the number of correct matches into CL to return it
	MOV correct, 0							; reset the correct variable so that it is 0 the next time this proc is called
	ret
GuessALetter ENDP

CharToLower PROC
; Receives: char in AL
; Returns: char converted to lowercase
; Requires: 

	
	; To convert a char to lowercase, move the character into AL and call IsAlpha.
	; IsAlpha will return 1 in AH if the character is lower case, 1 in AL if it is
	; uppercase, or 0 in both if it is not a letter. If the character is a alpha letter
	; check if it is an uppercase letter. If so, add 32 to the uppercase letter to 
	; convert it to lowercase.

	PUSH EAX							; Save the letter because IsAlpha will erase it
	call IsAlpha						; check if the character is a letter

	CMP AH, 1							; If AH is 1, it is a uppercase letter
	POP EAX								; POP the letter out so that if it is uppercase we can use it
	JNE continue

	ADD EAX, 32d						; Add 32 to the char to conver it to lowercase

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
	skip_carriage_return:					; for when the user just presses enter without a character
	; Get the user char
	MOV EDX, OFFSET p_guess_letter
	call WriteString
	call ReadChar
	CMP AL, 0Dh
	JE skip_carriage_return

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
; compares the strings passed in.
; Receives: offset of the guess string in EDX, offset of the game string in EBX and length in AH
; Returns: 1 in AL if the strings a the same, 0 in AL if they are not the same
; Requires:

.data
	word_prompt BYTE "Guess a word", 0Ah, 0Dh, "->", 0
.code

	MOVZX ECX, AH
	INC ECX
	
	PUSH EDX
	MOV EDX, OFFSET word_prompt
	call WriteString
	POP EDX
	call ReadString
	DEC ECX
	MOV AH, CL

	CMP AH, AL
	JNE NotSame
	
	MOV ESI, 0
	MOVZX ECX, AH

	L1:
		MOV AL, [EDX+ESI]
		MOV AH, [EBX+ESI]
		CMP AL, AH
		JNE NotSame
		INC ESI
	LOOP L1

	;MOV AL, [EDX+ESI]
	;MOV AH, [EBX+ESI]
	;CMP AL, AH
	;JNE NotSame

	Same:
	MOV AL, 1
	JMP Return
	NotSame:
	MOV AL, 0
	JMP Return

	Return:
	ret
GuessAString ENDP

ResetCurrentGuesses PROC
; converts the guesses string back to all '_'
; Receives: offset of guesses string in EDX, string length in ECX
; Returns: the string converted to initial state
; Requires: 

	MOV AL, '_'
	L1:
		MOV [EDX+ECX], AL
	LOOP L1

	MOV [EDX], AL

	ret
ResetCurrentGuesses ENDP

ResetGuessedLetter PROC
; converts the guessed letters string back to all 0
; Receives: offset of guesses string in EDX, string length in ECX
; Returns: the string converted to initial state
; Requires: 

	MOV AL, 0
	L1:
		MOV [EDX+ECX], AL
	LOOP L1

	MOV [EDX], AL

	ret
ResetGuessedLetter ENDP

PrintGameStats PROC

	call WaitMsg

	ret
PrintGameStats ENDP

END main	; end of source code