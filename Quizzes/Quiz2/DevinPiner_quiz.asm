; Program template

Include Irvine32.inc

.data
	; declare variables here
	Grades dword 50 DUP(0)
	lenArray BYTE 0

.code
main proc
	; write your code here

	MOV EAX, 0
	MOV EBX, OFFSET lenArray
	call userInt

	MOV EBX, OFFSET Grades
	MOVZX ECX, lenArray
	call FillArray

	MOV EBX, OFFSET Grades
	MOVZX EAX, lenArray
	call AlphaGrade

	MOV EBX, OFFSET Grades
	MOVZX EAX, lenArray
	call PrintGrade

	exit
main endp

userInt PROC

.data
	promptUser BYTE " Please enter a number <- 50: ", 0h
	oops BYTE "Invalid entry. Please try again", 0h

.code
	starthere:
		call clrscr
		MOV EDX, OFFSET promptUser
		call WriteString
		call readDec
		CMP EAX, 50d
		JA tooBig
		mov [EBX], EAX
		
		ret

		tooBig:
		mov EDX, OFFSET oops
		call WriteString
		call WaitMsg
		jmp starthere

userInt ENDP

FillArray PROC
	.code
	MOV ESI, 1							; Why is this 1? So that we skip the first byte of each element
	call Randomize

	FillIt:
		MOV EAX, 51d
		call RandomRange
		ADD EAX, 50d					; What does this do? pushes the random number into the range 50-100
		MOV [EBX + ESI], EAX
		ADD ESI, 4						; Why can't we use type here? Because when we went into this proc we lost all references to the size
	LOOP FillIt

	ret
FillArray ENDP

AlphaGrade PROC
; Puts the letter grade in the top byte of each element of a dword array
; Receives: Offset of array in EDX, array length in EAX
; Returns:
; Requires: Array of dword size elements, value in each element must only be in the bottom byte

.data
	letter_grade BYTE "?"

.code

	; Once we are in AlphaGrade, we have an array of number grades that we must assign a letter grade to.
	; to do this, we loop through the array and compare each number to the letter grades specified,
	; A 100-90
	; B 89-80
	; C 79-70
	; D 69-60
	; F 59-0
	; We test these starting at n < 60, if not test n < 70, and so on. At each test, if it 
	; returns false, we just continue to the next step. This makes it so that we only need jumps after
	; each test if it returns true. If it does return true, it jumps before the other tests can be checked.
	; Once we have a letter, we put the letter grade into AL as a char. This way, the number score is stored
	; in AH and the letter grade is stores in AL. Once we have all the letter grades assigned, we need to 
	; assign them a color scheme, which is determined in AssignColor

	PUSH EAX								; Save EAX
	MOV ECX, EAX							; Make ecx the array length for the loop
	MOV EDX, 0								; Make EDX 0 and use it as an iterator through the array

	L1:
		MOV EAX, [EBX + EDX*4]				; Put the whole dword element into EAX

		CMP AH, 60							; If AH , 60, we assign an F
		JB F_grade
		CMP AH, 70							; If AH < 70, we assign a D
		JB D_grade
		CMP AH, 80							; If AH < 80, we assign a C
		JB C_grade
		CMP AH, 90							; If AH < 90, we assign a B
		JB B_grade
		CMP AH, 100							; If AH <= 100, we assign an A
		JBE A_grade
		

		F_grade:
			MOV AL, 'F'							; Assign an F
			JMP Continue_loop
		D_grade:
			MOV AL, 'D'							; Assign a D
			JMP Continue_loop
		C_grade:
			MOV AL, 'C'							; Assign a C
			JMP Continue_loop
		B_grade:
			MOV AL, 'B'							; Assign a B
			JMP Continue_loop
		A_grade:
			MOV AL, 'A'							; Assign an A
			JMP Continue_loop

		Continue_loop:
		MOV [EBX+EDX*4], EAX					; Put the element with it's new letter grade back into the array
		INC EDX									; Increment the array iterator
	LOOP L1

	POP EAX										; Restore EAX
	call AssignColor							; Go assign the grades a color scheme
	ret
AlphaGrade ENDP

PrintGrade PROC
; Prints out the contents of the grades array
; Receives: Offset of array in EBX, array length in EAX
; Returns:
; Requires: Array to have dword size elements, the letter grade in the first (least significant) byte,
;	number grade in the second byte

.data
	current_row BYTE 1
	left_paren BYTE "(", 0h
	right_paren BYTE ")", 0h
	text_color BYTE 0
	bg_color BYTE 0
	irvine_format BYTE 0

.code
	
	; In PrintGrade, we need to iterate through the array and print out the grade information.
	; Each element of the array stores information about its self. The most significant byte
	; is the text color, the next byte is the background color, the next byte is the score,
	; and the least significant byte is the letter grade. First we print out the score, then
	; use GoToXY to print 5 spaces after the score. The row used in GoToXY is kept in current_row
	; and is incremented after each array element has been printed. To correctly print each grade
	; in it's color scheme, we need to rotate the register it is stored in so that the 2 most
	; significant bytes can be accessed using AH and AL. To use the colors, we need to get them
	; into the format required by SetTextColor. The format, according to the textbook, is the text
	; color is in the top 4 bits of the least significant byte, and the background color is in the 
	; 4 least significant bits of the least significant byte. To do this, we just need to put the 
	; text color into AL and rotate the EAX register 4 bits to the left (ROL EAX, 4), then move the
	; background color into AL again. Now the register should be in the format expected by SetTextColor.
	; Once the colors have been set, we need to restore the register so that we can access the letter
	; grade from the register

	MOV ECX, EAX
	MOV EDX, 0

	L1:
		MOV EAX, [EBX+EDX*4]				; Letter score in AL, number score in AH

		PUSH EAX							; save the register
		MOVZX EAX, AH						; Move the score in EAX by itself				
		call WriteDec						; Print the number
		POP EAX								; restore the register

		PUSH EDX							; save the register
		MOV DH, current_row					; Push the current row into DH
		MOV DL, 7							; put 7 into dl so that 7 spaces are printed
		call GoToXY							; move the cursor
		POP EDX								; restore the register

		PUSH EDX							; Save the register and print out the left parenthesis						
		MOV EDX, OFFSET left_paren
		call WriteString

		; now we need to set the color scheme for the letter grade
		ROL EAX, 16							; Rotate the register so that the color scheme is in AX

		PUSH EAX							; Save the register
		MOV text_color, AH					; Save the text color
		MOV bg_color, AL					; Save the bg color
		MOV EAX, 0							; clear eax
		MOV AL, text_color					; put the text color in AL
		ROL EAX, 4							; move the text color up 4 bits
		ADD AL, bg_color					; move the bg color into the bottom 4 bits

		call SetTextColor

		POP EAX
		ROL EAX, 16
		call WriteChar

		call ResetConsoleColors

		MOV EDX, OFFSET right_paren
		call WriteString

		call Crlf
		POP EDX

		INC current_row
		INC EDX
	LOOP L1

	ret
PrintGrade ENDP

AssignColor PROC
; Assigns a color for each grade level
;	A & B: green on black bg
;	C: yellow on black bg
;	D: black on yellow bg
;	F: red on black bg
; The text color will be stores in the most significant byte, BG color will be in the next byte
; Receives: Offset of array in EBX, array length in EAX
; Returns:
; Requires: Array to have dword size elements, the letter grade in the first (least significant) byte,
	
.data
	temp_letter_grade BYTE 0
	temp_number_grade BYTE 0

.code
	MOV ECX, EAX
	MOV EDX, 0

	L1:
		MOV EAX, [EBX+EDX*4]				; Letter score in AL, number score in AH
		MOV temp_letter_grade, AL
		MOV temp_number_grade, AH
		ROL EAX, 16							; Rotate everything to the right, the most significant byte is now in AH
											; the next byte is in AL

		CMP temp_number_grade, 60
		JB F_grade
		CMP temp_number_grade, 70
		JB D_grade
		CMP temp_number_grade, 80
		JB C_grade
		CMP temp_number_grade, 100
		JBE AB_grade
		
		; AH = text color
		; AL = BG color
		F_grade:
			MOV AL, 4
			MOV AH, 0
			JMP Continue_loop
		D_grade:
			MOV AL, 0
			MOV AH, 14
			JMP Continue_loop
		C_grade:
			MOV AL, 14
			MOV AH, 0
			JMP Continue_loop
		AB_grade:
			MOV AL, 2
			MOV AH, 0
			JMP Continue_loop

		Continue_loop: 
		ROL EAX, 16
		MOV [EBX+EDX*4], EAX
		INC EDX
	LOOP L1

	ret
AssignColor ENDP

ResetConsoleColors PROC
	PUSH EAX
		MOV EAX, lightgray+(black*16)
		call SetTextColor
	POP EAX

	ret
ResetConsoleColors ENDP

end main