; Program template

Include Irvine32.inc

clearEAX TEXTEQU <mov EAX, 0>
clearEBX TEXTEQU <mov EBX, 0>
clearECX TEXTEQU <mov ECX, 0>
clearEDX TEXTEQU <mov EDX, 0>
WSTR TEXTEQU <call WriteString>
NEXTLINE TEXTEQU <call Crlf>
WMSG TEXTEQU <call WaitMsg>
RINT TEXTEQU <call ReadInt>

.data
IntPrompt BYTE "Enter a number between 0 and 20: ", 0
LowerBoundPrompt BYTE "Enter a number between 0 and 200 (lower bound): ", 0
UpperBoundPrompt BYTE "Enter a number between 0 and 200 (upper bound): ", 0
APrompt BYTE "A: ", 0
JPrompt BYTE "j: ", 0
KPrompt BYTE "k: ", 0

IntArray DWORD 20 DUP(0FFFFFFFFh)
UserLength DWORD 20
UpperBound DWORD 0
LowerBound DWORD 0

.code
main proc

	clearEAX
	clearEBX
	clearECX
	clearEDX
	
	GetArrayLength:
	MOV EDX, OFFSET IntPrompt				; Print the prompt
	WSTR									; -
	RINT									; Get the value from the user
	CMP EAX, 20								; 
	JA GetArrayLength						; EAX < 20

	MOV EBX, EAX							; EBX now has the length of the array to generate

	GetLowerBound:
	MOV EDX, OFFSET LowerBoundPrompt		; Print the prompt
	WSTR									; -
	RINT									; Get the value from the user
	CMP EAX, 200							;
	JAE GetLowerBound						; EAX >= 200

	MOV ECX, EAX							;ECX now has the lower bound

	getUpperBound:
	MOV EDX, OFFSET UpperBoundPrompt
	WSTR
	RINT
	CMP EAX, 200
	JA getUpperBound
	CMP EAX, ECX
	JBE getUpperBound

	MOV EDX, EAX							;EDX now has the upper bound

	MOV EAX, OFFSET IntArray				;EAX now has the offset of the array

	CALL fillArray

	PUSH EAX
	PUSH EBX
	PUSH ECX
	PUSH EDX

	; Print out the array
	MOV ESI, OFFSET IntArray
	MOV ECX, EBX
	MOV EBX, 4

	CALL DumpMem

	POP EDX
	POP EBX
	POP ECX
	POP EAX

	WMSG

	exit
main endp

fillArray PROC
; Generates an array of random integers of length passed in EBX
; Recieves: pointer to the array in EAX, lowerbound in ECX, upperbound in EDX, array length EBX
; Returns: An array passed in through EAX
; Requires: All values must be size DWORD

	.data
	BoundDistance DWORD 0

	.code

	CALL Randomize

	; Push all of the registers onto the stack because there are too many of them
	; to switch between during the procedure. With all of the register values on the
	; stack, we can use ESP to get the values without storing them in a register
	; Remember that the stack grows down, so we still add the number of bits
	; to get to the value we want

	PUSH EAX			;Array pointer	ESP+12	ADDRESS
	PUSH EBX			;Array Length	ESP+8	VALUE
	PUSH ECX			;Lower bound	ESP+4	VALUE
	PUSH EDX			;Upper Bound	ESP		VALUE

	; Now we need to loop through the array from 0-arraylength
	; First, put the array length into ECX, which is at ESP+8. We need to generate
	; A value between the Lower bound and the upper bound. To do this, we find the 
	; distance between the two values and generate a number between 0 and the distance
	; then add the lower bound to the number. For example, with lower bound 25 and
	; upper bound 70, the distance between the bounds is 45. We generate a number
	; between 0 and 46 (not including 46) and add 25 (the lower bound) to push
	; the number into the correct range

	; Get the distance of the ranges (Upperbound-lowerbound). Put the (ESP) upper bound into
	; EAX, the lower bound (ESP+4) into EBX, then sub EBX from EAX and store the result 
	; in EAX. EAX now holds the distance between the bounds. We need to add 1 so that the
	; last value in the upper bound is included in the range. Push the distance onto the stack
	; and access it using ESP+16
	MOV EAX, [ESP]
	MOV EBX, [ESP+4]
	SUB EAX, EBX
	ADD EAX, 1
	MOV BoundDistance, EAX	

	; Now we have the range of numbers to generate need to loop through the array and 
	; generate the random numbers to put into the array. Get the array pointer
	; From the stack at ESP+12. Get the length of the array from the stack at ESP+8 to 
	; use for the loop. Generate the number using Irvine RandomRange. Add the lower 
	; bound to the random number, then insert it into the array
	MOV ECX, [ESP+8]
	MOV EBX, [ESP+12]
	IntLoop:
		MOV EAX, BoundDistance		;Move the bound distance into EAX
		CALL RandomRange			;Generate a random number between 0 and EAX-1
		ADD EAX, [ESP+4]			;Add the lower bound to the number to get it in the range
		MOV [EBX+ECX*4], EAX		;Put the number into the array
	LOOP IntLoop

	;Get the first value of the array that the loop missed
	MOV EAX, BoundDistance		;Move the bound distance into EAX
	CALL RandomRange			;Generate a random number between 0 and EAX-1
	ADD EAX, [ESP+4]			;Add the lower bound to the number to get it in the range
	MOV [EBX], EAX			;Put the number into the array

	; Put all the the values back in the registers before exiting the procedure
	POP EDX
	POP ECX
	POP EBX
	POP EAX

	ret
fillArray ENDP

end main