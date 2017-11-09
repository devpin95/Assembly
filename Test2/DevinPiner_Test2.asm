TITLE template.asm
; Description: 
; Author: Devin Piner 107543409
; Date Created:

INCLUDE Irvine32.inc

.data
	;{your variables are to be defined here}
	
	; Game variables
	LETTER_GUESS_MAX = 11
	WORD_GUESS_MAX = 3

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
	TOTAL_STRINGS = 20

	; Game data
	current_string DWORD 0
	current_string_length BYTE 0
	current_string_guesses BYTE 14 DUP('_'), 0
	letter_guesses BYTE LETTER_GUESS_MAX
	word_guesses BYTE WORD_GUESS_MAX

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
		MOV EDX, OFFSET current_string_guesses
		MOVZX ECX, current_string_length
		
		call Clrscr

		call PrintGuesses
		call Crlf
		call Crlf
		MOV EDX, current_string
		call WriteString
		MOV EAX, ECX
		call Crlf
		call WriteDec
		call Crlf

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
			MOV EDX, OFFSET current_string_guesses
			MOVZX ECX, current_string_length
			call PrintGuesses
			call Crlf
			call Crlf
			MOV EDX, current_string
			MOV EBX, OFFSET current_string_guesses
			MOVZX ECX, current_string_length
			call GuessALetter
			jmp start_game
		Option2:
			; Guess a word
			jmp start_game
		Option3:
			; Encrypt
			jmp start_game

	call WaitMsg

	Ending:
exit
main ENDP	; end main procedure

Instructions PROC
.data
	words BYTE "You have 11 attempts to guess what letters are in the word", 0Ah, 0Dh,
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
; Receives: offset of guesses string in EDX, length of the string in ECX

.data
.code
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
.data
	prompt BYTE "Guess a letter", 0Ah, 0Dh, "->", 0
	char BYTE 0
.code
	MOV EDX, OFFSET prompt
	call WriteString
	call ReadChar

	MOV char, AL

	MOV ESI, 0

	L1:
		MOV AL, [EDX+ESI]
		CMP AL, char
		JNE Continue

		MOV [EBX+ESI], AL

		Continue:
		INC ESI
	LOOP L1

	ret
GuessALetter ENDP

END main	; end of source code