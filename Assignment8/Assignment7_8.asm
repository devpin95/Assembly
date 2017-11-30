TITLE DevinPiner_Assignment7_8.asm
; Description: 
; Author: Devin Piner 107543409
; Date Created:

INCLUDE Irvine32.inc

Sieve PROTO, saddr:DWORD, n:WORD, len:WORD
FindAllPrimes PROTO, saddr:DWORD, len:WORD

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

	; Do the whole sieve at the begginning so that

	startHere:
		call PrintMainMenu
		call ReadDec
		mov UserOption, al

		CMP AL, 3
		JE Opt3
		CMP Al, 1
		JE Opt1
		CMP Al, 2
		JE Opt2

	Opt1:
		call Clrscr
		MOV EDX, OFFSET sieve_prompt
		call WriteString
		call ReadDec
		call Clrscr
		INVOKE Sieve, OFFSET primes, AX, SIEVE_LENGTH
		JMP startHere
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
	LOCAL	count:WORD, row:BYTE, column:BYTE
.data
	sieve_header BYTE "There are ", 0
	sieve_header2 BYTE " prime numbers between 2 and n (n = ", 0
	sieve_line BYTE ")",  0Ah, 0Dh, "-----------------------------------------------------------------", 0
.code
	
	MOV count, 0
	MOV row, 2
	MOV column, 0
	MOV EAX, saddr

	INVOKE FindAllPrimes, saddr, n

	MOVZX ECX, n
	SUB ECX, 2
	MOV EBX, 2
	MOV EAX, saddr
	count_primes:
		PUSH EAX
		MOV EAX, [EAX+EBX]
		CMP AL, 1
		JNE not_prime1

		INC count

		not_prime1:
		POP EAX
		INC EBX
	LOOP count_primes

	MOV EDX, OFFSET sieve_header
	call WriteString
	MOVZX EAX, count
	call WriteDec
	MOV EDX, OFFSET sieve_header2
	call WriteString
	MOVZX EAX, n
	call WriteDec
	MOV EDX, OFFSET sieve_line
	call WriteString
	call Crlf

	MOVZX ECX, n
	SUB ECX, 2
	MOV EBX, 2
	MOV EAX, saddr

	L2:
		PUSH EAX
		MOV EAX, [EAX+EBX]
		CMP AL, 1
		JNE continue

		MOV dh, row
		MOV dl, column
		call Gotoxy

		MOV EAX, EBX
		call WriteDec

		ADD column, 5
		CMP column, 20
		JBE continue

		INC row
		MOV column, 0
		call Crlf

		continue:
		POP EAX
		INC EBX
	LOOP L2

	call Crlf
	ret
Sieve ENDP

FindAllPrimes PROC, saddr:DWORD, len:WORD
	LOCAL	index:WORD

	;http://www.algolist.net/Algorithms/Number_theoretic/Sieve_of_Eratosthenes

.code
	MOV AX, len

	MOV EAX, saddr
	MOV EDX, 0
	MOV [EAX], DL
	MOV [EAX+1], DL
	MOV index, 2

	MOVZX ECX, len
	DEC ECX
	MOV EBX, 2
	l1:
		next_number:
		MOVZX EBX, index
		PUSH EAX
		MOV EAX, EBX
		MUL BX
		MOV EBX, EAX
		POP EAX

		next_multiple:
		CMP BX, len
		JA exit_loop
		MOV [EAX+EBX], DL
		ADD BX, index
		CMP BX, len
		JB next_multiple

		next_index:
		INC index
		CMP index, 3
		JBE next_number
		INC index
		JMP continue_loop

		exit_loop:
		MOV ECX, 1

		continue_loop:
	LOOP l1

	ret
FindAllPrimes ENDP

GCD PROC
.data
	p2 BYTE "GCD!!", 0Ah, 0Dh, 0
.code
	MOV EDX, OFFSET p2
	call WriteString
	ret
GCD ENDP

END main	; end of source code