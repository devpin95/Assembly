TITLE DevinPiner_RString.asm
; Description: Input from the user determines how many times to generate a random string
; Author: Devin Piner 107543409
; Date Created: Oct. 11, 2017

INCLUDE Irvine32.inc

.data
	;{your variables are to be defined here}

.data?
	;{used as necessary}

.code
UserInt PROC	;--------------------------------------------------------------------------------------------
	; Prompts the user to enter an integer
	; Recieves: 
	; Returns: EAX, the value entered by the user
	; Requires: 

	.data
		prompt1 BYTE "Please enter an integer: ", 0

	.code
		MOV EAX, 0					;clear eax
		MOV EDX, OFFSET prompt1		;put the address of the prompt message into EDX for WriteString

		call WriteString			;Print the prompt
		call ReadInt				;Get the value from the user
		ret
UserInt ENDP

RandStr PROC	;--------------------------------------------------------------------------------------------
; Generates n number of random strings where n is in ECX
; Recieves: ECX - the number of strings to generate
; Returns: 
; Requires: ECX > 1

	.data
		random_string BYTE 26 DUP(0)
		random_string_size = $-random_string

	.code
		call Randomize

		RandStr_MainLoop:	;------------------------------------------------------------^

			; We are going to use several loops to generate the string, so we need to store
			; the count of the outer loop (RandStr_MainLoop). We also need the size of the
			; string so that we can clear the string.
			MOV EBX, ECX
			MOV ECX, random_string_size
			
			RandStr_ClearLoop:	;---------------------------------------------^
				MOV [random_string + ECX], 0
			LOOP RandStr_ClearLoop ;------------------------------------------^

			; Generate a random number between 0 and 20, then add 5
			; This number will be the number of character that will be generated
			; By the requirements, the size of the string must be 5-25
			; Because RandomRange only returns 0 - (n-1), we have to give it 20
			; and add 5 so that we satisfy the requirements
			MOV EAX, 20				;Move 20 into EAX
			call RandomRange		;Call RandomRange, will return 0-19 in EAX
			ADD EAX, 5				;Add 5 to the number to make the range 5-24
			MOV ECX, EAX			;Move the random number into ECX to use in the next loop

			; Step through the characters of random_string and generate a random letter for each
			; The same constraints are applied as the code above: We need a number between 41h and 5Ah
			; (A-Z). RandomRange only returns 0 - (n-1), so we get a number between 0 and 25,
			; which represents the number of letter in A-Z. Then, we can add that number to 'A' and get
			; a letter between 'A' and 'Z'. Once we have the letter, we just move it into the currect
			; position which is being tracked by ECX, ECX = the number of characters to randomly generate
			; We also know that the lowest byte is all that is being used, so we just put that in the string
			RandStr_CharLoop: ;---------------------------------------------^
				MOV EAX, 25						;Move the range we need into EAX
				call RandomRange				;Call RandomRange to get a number from 0-25
				ADD EAX, 'A'					;Add 'A' (41h) to the random number in EAX
				MOV [random_string+ECX], AL		;Move the randomly generate number into the string
			LOOP RandStr_CharLoop ;-----------------------------------------^

			; The loop doesn't reach the first element of the string, so do it manually
			; This is exactly the same code as the loop
			MOV EAX, 25
			call RandomRange
			ADD EAX, 'A'
			MOV [random_string], AL

			; Now that we have a randomly generated string, we need to print it to the console
			; To do this we need to call WriteString, which expects the address of the string 
			; to be in EDX. We ar alread using EDX to store the loop counter of the main loop
			; (RandStr_MainLoop), so we need to swap it into EAX temporarily. Once we do that,
			; we get the address of the string and put it in EDX and call WriteString and Crlf.
			; Then we put the count of the main loop back into EDX from EAX
			;MOV EAX, EDX
			MOV EDX, OFFSET random_string
			call WriteString
			call Crlf
			;MOV EDX, EAX

			; Now we're at the end of the main loop, so put EBX back into ECX so that we generate
			; the correct number of strings specified by the user
			MOV ECX, EBX

		LOOP RandStr_MainLoop	;--------------------------------------------------------^
		ret
RandStr ENDP

COMMENT ?
	ClearRandStr PROC
		L2:	;---------------------------------------------
			MOV [ESI], 0
			INC ESI
		LOOP L2 ;-----------------------------------------
		ret
	ClearRandStr ENDP
?

main PROC		;--------------------------------------------------------------------------------------------
	;{executable code here}

	call UserInt					;Get an int from the user, value returned in EAX
	MOV ECX, EAX					;Move the value from EAX to ECX

	call Crlf
	call RandStr
	call Crlf
	call WaitMsg

	call DumpRegs

exit
main ENDP	; end main procedure
END main	; end of source code