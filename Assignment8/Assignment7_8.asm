TITLE DevinPiner_Assignment7_8.asm
; Description: 
; Author: Devin Piner 107543409
; Date Created:

INCLUDE Irvine32.inc

Sieve PROTO, saddr:DWORD, n:WORD, len:WORD
FindPrimes PROTO, saddr:DWORD, len:WORD

.data
	;{your variables are to be defined here}
	SIEVE_LENGTH = 1001
	sieve_prompt BYTE "Enter a number between 2 and 1000:", 0
	UserOption BYTE 0
	primes BYTE SIEVE_LENGTH DUP(1)

.data?
	;{used as necessary}

.code

main PROC	
	;{executable code here}

	startHere:
		call PrintMainMenu									; Print the main menu
		call ReadDec										; get the menu option from the user
		mov UserOption, al									; store the value in UserOption

		CMP AL, 3											; Check if UserOption == 3 
		JE Opt3												; (exit)
		CMP Al, 1											; Check if UserOption == 1
		JE Opt1												; (Sieve of Eratosthenes)
		CMP Al, 2											; Check if UserOption == 2
		JE Opt2												; (GCD)

	Opt1:													; (Sieve of Eratosthenes)
		call Clrscr											; Clear the screen
		MOV EDX, OFFSET sieve_prompt						; Print out the prompt
		call WriteString
		call ReadDec										; Get the upperbound value from the user (store in EAX)
		call Clrscr											; Clear the screen

															; Check for errors from the user input
		CMP EAX, 2											; Check if EAX < 2
		JB Opt1												; Restart the prompt
		CMP EAX, SIEVE_LENGTH								; Check if EAX >= SIEVE_LENGTH (1001)
		JAE Opt1											; Restart the prompt

		PUSH EAX											; Save EAX because FindPrimes will change it
		INVOKE FindPrimes, OFFSET primes, AX				; do the SoE to find all of the primes between 2 and EAX
		POP EAX												; Restore EAX to get the upperbound value back
		INVOKE Sieve, OFFSET primes, AX, SIEVE_LENGTH		; Print out the primes
		JMP startHere										; Go back to the menu

	Opt2:
		call Clrscr
		call GCD
		JMP startHere

	Opt3:

	call WaitMsg

exit
main ENDP	; end main procedure

PrintMainMenu PROC
.data
	menu BYTE	"1. Seive of Eratosthenes", 0Ah, 0Dh,
				"2. Euclidian Algorithm (GCD)", 0Ah, 0Dh,
				"3. Exit", 0Ah, 0Dh,
				"->", 0
.code
	MOV EDX, OFFSET menu
	call WriteString
	ret
PrintMainMenu ENDP

Sieve PROC, saddr:DWORD, n:WORD, len:WORD
; Prints the sieve results
; Receives: sieve array address, the value to check all primes below, length of the array
; Returns:
; Requires: SoE function already executed, 0 marks a non-prime, 1 marks a prime

LOCAL	count:WORD, row:BYTE, column:BYTE
.data
	sieve_header BYTE "There are ", 0
	sieve_header2 BYTE " prime numbers between 2 and n (n = ", 0
	sieve_line BYTE ")",  0Ah, 0Dh, "-----------------------------------------------------------------", 0
.code
	
	; To print the results of the sieve of Eratosthenes, we first need to count the number of 1's
	; in the array from 2-n. If the array value is 1, we know that it is prime, otherwise nonprime.
	; We need to do this first because the specification requires us to print the number of primes
	; before the list of primes so we need to count them before printing. For both loops, we start
	; at index 2 because 0 & 1 were skipped by the sieve of Eratosthenes. We also need to print the
	; numbers in columns, so we keep track of the row and column. 5 numbers will be printed per line
	; with 4 spaces between them. If column is greater than 20, we need to do a "carriage return line
	; feed" to start the numbers on the next line (just inc the row and loop the columns back to 0)

	; Get the cursor intitial values ready
	MOV count, 0										; initialize the number of primes to 0
	MOV row, 2											; initialize rows to 2 after the header is printed
	MOV column, 0										; initialize column to 0
	MOV EAX, saddr										; move the array address into EAX so that we can use [EAX+n]

	MOVZX ECX, n										; extend n into ECX for the loop
	SUB ECX, 2											; subtract 2 because the first two values (0 & 1) aren't counted in the array
	MOV EBX, 2											; move 2 into EBX to user as an index to the array (skipping 0 & 1)
										
	count_primes:										; a loop to cound the number of 1's in the sieve array
		PUSH EAX										; save EAX so that we can compare the array value
		MOV EAX, [EAX+EBX]								; move the array value into EAX
		CMP AL, 1										; compare it to 1 (1=prime, 0=nonprime)
		JNE not_prime1									; jump to the next index if the value != 1

		INC count										; if we get here, the value is prime, so inc the total primes < n

		not_prime1:										; when we get here, we have skipped/counted the current index
		POP EAX											; restore EAX so that we can use the array address again
		INC EBX											; inc the index to the array
	LOOP count_primes

	MOV EDX, OFFSET sieve_header						; print out the header
	call WriteString
	MOVZX EAX, count									; move the number of primes into EAX to print
	call WriteDec										; print the total number of primes
	MOV EDX, OFFSET sieve_header2						; print out the second part of the header
	call WriteString
	MOVZX EAX, n										; move n into EAX to print
	call WriteDec
	MOV EDX, OFFSET sieve_line							; print out the third part of the header
	call WriteString
	call Crlf											; go to the next line

	MOVZX ECX, n										; extend n into ECX for the loop
	SUB ECX, 2											; subtract 2 because the first two values (0 & 1) aren't counted in the array
	MOV EBX, 2											; move 2 into EBX to user as an index to the array (skipping 0 & 1)
	MOV EAX, saddr										; move the array address back into EAX

	L2:													; a loop to print out the prime numbers < n
		PUSH EAX										; save the array address
		MOV EAX, [EAX+EBX]								; move the array value into EAX
		CMP AL, 1										; check if AL != 1 (nonprime), us AL because that's where the value will be
		JNE continue									; jump to the next index if this one isn't prime

		MOV dh, row										; set the cursor to the correct row
		MOV dl, column									; set the cursor to the correct column
		call Gotoxy										; move the cursor

		MOV EAX, EBX									; move the index value into EBX (EBX is the value of the prime number)
		call WriteDec									; print out the prime number

		ADD column, 5									; move the cursor 5 spaces to the right
		CMP column, 20									; compare the column number to 20
		JBE continue									; jump to the next index if column <= 20
														; (once column > 20, we need to go to the next line/row)

		INC row											; move to the next line/row
		MOV column, 0									; move the column back to the left
		call Crlf										; go to the next line

		continue:										; when we get here, we have printed/skipped the number & updated the cursor vals
		POP EAX											; restore the array address in EAX
		INC EBX											; inc the index
	LOOP L2

	call Crlf											; go to the next line
	ret
Sieve ENDP

FindPrimes PROC, saddr:DWORD, len:WORD
; Finds all of the primes less than len in the saddr array
; Receives: array address, upperbound value
; Returns: the array with 1's for the primes of that index value, 0's for nonprime numbers
; Requires: len <= array length
; Algorithm found here: http://www.algolist.net/Algorithms/Number_theoretic/Sieve_of_Eratosthenes

LOCAL	index:WORD

.code

	; To find all of the primes < len, we use the Sieve of Eratosthenes. Starting at index n,
	; skipping 0 & 1 because neither are prime (but we still need to make sure to mark them 0), 
	; we go to n^2 and start crossing out the multiples of n after n^2. For example, if start at
	; 2, we do not cross out 2 because it's prime, we go to 2^2=4, cross out 4 and add 2 to get to
	; 6, cross 6 out and add 2 to get to 8, cross out 8 and so on. Once we cross out all multiples
	; of 2, we go to 3. We don't cross off 3 because it is prime. We go to 3^2=9 and cross out 9,
	; then add 3 to get to 12, cross out 12, and continue as before. Instead of continuing to 4,
	; we can skip 4 and all the remaining even numbers because they were all multiples of 2 and
	; have all been crossed out. So we can focus on all odd numbers and go 5, then 7, then 9 and
	; so on until we get to a number who's square is greater than len. For example, if len=50,
	; we only need to conside up to 7, who's square is 49. Then 8, who's square is 64, can be
	; skipped because it's outside the range of the array we are interested in.

	MOV EAX, saddr										; move the array address into EAX							
	MOV EDX, 0											; move 0 into EDX as the value for non-prime numbers
	MOV [EAX], DL										; make array[0]=0 (0 is not prime)
	MOV [EAX+1], DL										; make array[1]=0 (1 is not prime)
	MOV index, 2										; move 2 into index to keep track of where we are in the array

	MOVZX ECX, len										; move the upperbound into ECX for the loop
	DEC ECX												; dec ecx so that is doesnt count the first element of the array
	MOV EBX, 2											; move 2 into EBX to use as an index to the array

	l1:													; loop through each element
		next_number:									; start here
		MOVZX EBX, index								; extend the index into EBX so that we can start at that index
		PUSH EAX										; save the array address
		MOV EAX, EBX									; move the index into EAX
		MUL BX											; square the index
		MOV EBX, EAX									; move the squared index back into EBX
		POP EAX											; restore the array address

		next_multiple:									; while loop to cross off all the multiples of index
		CMP BX, len										; while EBX < len
		JA exit_loop									; if BX > len, break out of the while loop and outer loop (index+1 >len)
		MOV [EAX+EBX], DL								; make the value 0 because it is not prime
		ADD BX, index									; add the index to go to the next multiple of index
		CMP BX, len										; make sure BX is still less than len
		JB next_multiple								; if (BX<len) continue else break

		next_index:										; when we get here, we have finished the current index
		INC index										; inc the index
		CMP index, 3									; check if it is below or equal to 3
		JBE next_number									; if it is <= 3, just inc index once
		INC index										; otherwise, inc index again to get the next odd number
		JMP continue_loop								; jump to the next loop

		exit_loop:										; if we get here, EBX^2 > len, so we need to break the loop
		MOV ECX, 1										; make ECX 1 so that it will exit the loop immediately

		continue_loop:									; if we get here, continue the loop or exit depending on the lines above
	LOOP l1

	ret
FindPrimes ENDP

GCD PROC
.data
	p2 BYTE "GCD!!", 0Ah, 0Dh, 0
.code
	MOV EDX, OFFSET p2
	call WriteString
	ret
GCD ENDP

END main	; end of source code