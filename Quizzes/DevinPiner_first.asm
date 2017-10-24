; Program template

Include Irvine32.inc

clearEAX TEXTEQU <mov EAX, 0>
clearEBX TEXTEQU <mov EBX, 0>
clearECX TEXTEQU <mov ECX, 0>
clearEDX TEXTEQU <mov EDX, 0>
Size1 = 072h

.data
	; declare variables here
	GetIntPrompt BYTE "Please enter the number of numbers to generate, less than 20: ", 0
	LowerBoundPrompt BYTE "Please enter the lower bound of numbers: ", 0
	UpperBoundPrompt BYTE "Please enter the upper bound of numbers: ", 0
	ArrayPrintingPrompt BYTE "The Array is:", 0
	
	ArrayLength DWORD 0
	ArrayFixedLength = 20
	BoundLimit = 200d
	LowerBoundValue DWORD 0
	UpperBoundValue DWORD 0
	IntArray DWORD 50 DUP(0)

.code
main proc
	; write your code here

	clearEAX;
	clearEBX;
	clearECX;
	clearEDX;
	
	GetInt:
	MOV EDX, OFFSET GetIntPrompt
	call WriteString
	call ReadInt
	MOV ArrayLength, EAX
	CMP ArrayLength, ArrayFixedLength
	JA GetInt
	
	GetLowerBound:
	MOV EDX, OFFSET LowerBoundPrompt
	call WriteString
	call ReadInt
	MOV LowerBoundValue, EAX
	CMP LowerBoundValue, BoundLimit
	JA GetLowerBound
	
	GetUpperBound:
	MOV EDX, OFFSET UpperBoundPrompt
	call WriteString
	call ReadInt
	MOV UpperBoundValue, EAX
	CMP UpperBoundValue, BoundLimit
	JA GetUpperBound

	call Crlf

	MOV EAX, OFFSET IntArray
	MOV EBX, UpperBoundValue
	MOV ECX, LowerBoundValue
	MOV EDX, ArrayLength
	call fillArray

	MOV EDX, OFFSET ArrayPrintingPrompt
	call WriteString
	call Crlf

	;MOV ESI, OFFSET IntArray
	;MOV ECX, ArrayLength
	;MOV EBX, 4

	;call DumpMem

	call Crlf
	call WaitMsg
	exit
main endp

fillArray PROC
;Recieves: array address in EAX, lowerbound in ECX, upperbound in EBX, array length in EDX

	.data
	BoundDistance DWORD 0
	UserLength DWORD 0

	.code

		call Randomize
		MOV UserLength, EDX
		MOV BoundDistance, ECX
		SUB BoundDistance, EBX
		MOV EBX, ECX					;We don't need the upper bound anymore, lower bound is not in EBX

		MOV ECX, ArrayLength
		GenerationLoop:
			MOV EAX, BoundDistance
			call RandomRange
			ADD EAX, EBX				;Add the lower bound to the number generated

			MOV [EDX+ECX], EAX

		LOOP GenerationLoop

		ret
fillArray ENDP

end main