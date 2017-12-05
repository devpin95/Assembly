TITLE DevinPiner_Assignment7_8.asm
; Description: Prints all the primes less than n. Finds the GCD of 2 numbers and finds if it's prime
; Author: Devin Piner 107543409
; Date Created: Dec. 1, 2017

INCLUDE Irvine32.inc

Sieve PROTO, saddr:DWORD, n:WORD, len:WORD
FindPrimes PROTO, saddr:DWORD, len:WORD
Euclid PROTO, saddr:DWORD, len:WORD
GCD PROTO, a:WORD, b:WORD

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
		INVOKE Euclid, OFFSET primes, SIEVE_LENGTH
		call Clrscr
		;INVOKE GCD, 512, 56
		;MOVZX EAX, BX
		;call WriteDec
		;call Crlf
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
	none BYTE "There are no prime numbers less than ", 0
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

	CMP n, 2
	JBE skip_counting
										
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

	skip_counting:

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

	CMP n, 2
	JBE skip_printing

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

	JMP return

	skip_printing:
		MOV EDX, OFFSET none
		call WriteString
		MOVZX EAX, n
		call WriteDec

	return:
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

	CMP len, 2
	JBE return

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

	return:
	ret
FindPrimes ENDP

GCD PROC, a:WORD, b:WORD
; Find the greatest common divisor of a and b
; Receives: a & b as unsigned words
; Returns: the greatest common divisor in BX
; Requires: 

LOCAL r:WORD

.code

	; To find the greatest common divisor of 2 numbers a and b, find the numbers q and
	; r such that a = qb + r. q will be floor(a/b) and r will be the remainder. We don't
	; need to find q, only r. We can calculate r using modulus (division) of the two numbers.
	; DIV will give us a remainder. If r is 0, the GCD will be b and we can return. Otherwise,
	; if r is not 0, we need to find gcd(b, r) and continue recursively until r = 0, which
	; means the GCD will be b in the base case

														; Prepare the registers for the division
	MOV DX, 0											; clear the top 2 bytes
	MOV AX, a											; move a into the bottom 2 bytes of the numerator
	MOV CX, b											; move b into the demoninator
	DIV CX												; do the division

	MOV r, DX											; the remainder will be in DX, so move it into r

	CMP r, 0											; compare r to 0
	MOV BX, b											; move b into BX to return
	JNE recurse											; If r!=0, we need to recurse

	base_case:											; base case
		JMP return										; return
	recurse:
		INVOKE GCD, b, r								; recurse
	
	return:
	ret
GCD ENDP

Euclid PROC, saddr:DWORD, len:WORD
; prompts the user to enter two numbers, prints the gcd of them and if it is prime
; Receives: address of array, length of the array
; Requires:
; Returns:

LOCAL a:WORD, b:WORD, row:BYTE

.data
	header BYTE "a       b       GCD    Prime", 0Ah, 0Dh, 
				"--------------------------------------", 0
	continue_prompt BYTE "Do you wish to enter another pair (y/n) ", 0
	yes BYTE "YES", 0
	no BYTE "NO", 0
	no_idea BYTE "?", 0

.code
	; Prompts the user to enter a number in the column specified in the requirements.
	; Simply uses ReadDec and moves the cursor using gotoxy. Once both numbers are entered
	; calculate the greatest common divisor by invoking GCD. Then, after passing the GCD 
	; value to FindPrimes to find all of the primes less than the GCD, we can use the array
	; to tell if the number at the index of GCD (array[GCD]) is prime (1=prime,0=non-prime).
	; Then we prompt the user if the want to run the function again

	MOV row, 2										; The header is to lines long, so start rows on 2
	MOV EDX, OFFSET header							; move the header address into EDX
	call WriteString								; print the header

	while_yes:										; do while the user wants to continue

	MOV dh, row										; set the cursor to the correct row
	MOV dl, 0										; set the cursor to the correct column
	call Gotoxy										; move the cursor

	call ReadDec									; get the first number from the user
	MOV a, AX
	
	MOV dh, row										; set the cursor to the correct row
	MOV dl, 8										; set the cursor to the correct column
	call Gotoxy										; move the cursor

	call ReadDec									; get the second number from the user
	MOV b, AX

	MOV dh, row										; set the cursor to the correct row
	MOV dl, 16										; set the cursor to the correct column
	call Gotoxy										; move the cursor

	CMP b, 0										; check if the user entered 0 as the second number
	JE divide_by_zero								; if it is 0, jumped to divide_by_zero to prevent an error

	INVOKE GCD, a, b								; otherwise, calculate the GCD

	MOVZX EAX, BX									; extend the return value into EAX
	call WriteDec									; print the GCD

	CMP BX, 1001									; Make sure the GCD is within the range of the array
	JA outside

	PUSH EBX										; save EBX
	ADD BX, 25										; add 25 arbitrarily to make sure the seive will include the GCD

	INVOKE FindPrimes, saddr, BX					; find all of the primes less than GCD+25

	POP EBX											; restore EBX
	MOVZX EBX, BL									; extend BL into the rest of the register

	MOV dh, row										; set the cursor to the correct row
	MOV dl, 23										; set the cursor to the correct column
	call Gotoxy										; move the cursor

	MOV EAX, saddr									; put the address of the primes array in EAX
	MOV EAX, [EAX+EBX]								; move the value of the array at [EAX+EBX] into EAX

	CMP AL, 1										; compare the value  to 1
	JNE is_not_prime								; if the value is not 1, it is non-prime

	MOV EDX, OFFSET yes								; move the address of the yes string into EDX
	call WriteString								; print the yes string
	JMP done_with_prime								; jump to the end of the test

	is_not_prime:									; if we get here, the number is not prime
		MOV EDX, OFFSET no							; move the address of the no string into EBX
		call WriteString							; print the no string
		JMP done_with_prime							; jump to the end of the test
	outside:										; if we get here, the GCD is bigger than the array
		MOV EDX, OFFSET no_idea						; move the address of the ? string into EBX
		call WriteString							; print the ? string

	done_with_prime:								; when we get here, we are done with the current line

	call Crlf										; go to the next line

	MOV EDX, OFFSET continue_prompt					; move the continue prompt into EBX
	call WriteString								; print the continue prompt
	call ReadChar									; get the answer from the user (y/n)
	call WriteChar									; write the char to the screen so that the user can see it

	ADD row, 2										; move the row down 2
	CMP AL, 'y'										; compare to user's entry to 'y'
	JE while_yes									; if they entered 'y', restart the function
	JMP return										; return from the functions

	divide_by_zero:									; if we get here, the user ented 0 for a second number
	INC row											; go to the next line
	JMP while_yes									; restart the functions

	return:											; when we get here, go down 2 lines
	call Crlf
	call Crlf

	ret
Euclid ENDP

END main	; end of source code