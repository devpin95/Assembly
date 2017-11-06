
ClearString PROC USES EDX ECX ESI
;Description:  Clears a byte array given offset in edx and length in ecx
;Receives: Offset of string to be cleared in edx
;          length of string to be cleared in ecx
;Returns: nothing


;// increment through the passed array and set every element to zero
clearESI
ClearIt:
mov byte ptr [edx + esi], 0
inc esi
loop ClearIt

ret
ClearString ENDP

;//------------------------------------------------------------------

CharOnly PROC USES ecx edx esi
;// Description:  Removes all non-letter elements
;// Receives:  ecx - length of string
;//            edx - offset of string
;//            ebx - offset of string length variable
;//            esi preserved
;// Returns: string with all non-letter elements removed

.data
tempstr BYTE 50 dup(0)        ;// hold string while working - 

.code
;// preserve edx, ecx
push edx
push ecx

;// clear tempstr for repeated calls from main
mov edx, offset tempstr
mov ecx, 50
call ClearString

;// restore ecx, edx
pop ecx
pop edx


push ecx                      ;// save value of ecx for next loop
clearEDI                      ;// use edi as index to step through the string
L3:
mov al, byte ptr [edx + esi]  ;// grab an element of the string

;// check to see if the element is a letter.  
cmp al, 5Ah
ja lowercase    ;// if above 5Ah has a chance of being lowercase
cmp al, 41h     ;// if below 41h will not be a letter so skip this element
jb skipit
jmp addit       ;// otherwise it is a capital letter and should be added to our temporary string

lowercase:
cmp al, 61h     
jb skipit       ;// if below then is not a letter but is in the range 5Bh and 60h
cmp al, 7Ah     ;// if above then it is not a letter, otherwise it is a lowercase letter
ja skipit

addit:          ;// if determined to be a letter, then it must be added to the temp string
mov tempstr[edi], al
inc edi         ;// move to next element of theString
inc esi         ;// move to next element of temp string
jmp endloop     ;// go to the end of the loop

skipit:         ;// skipping the element 
inc esi         ;// go to next element of theString

endloop:
loopnz L3

mov [ebx], edi   ;// updates length of string

pop ecx         ;// restores original value of ecx for the next loop

;// copies the temp string to theString will all non-letter elements removed
clearEDI
L3a:     
mov al, tempstr[edi]
mov byte ptr [edx + edi], al
inc edi
loop L3a

ret
CharOnly ENDP

