TITLE Program 1: Arithmetic     (1Program.asm)

; Author: Jonathan (Alex) Jones
; Course / Project ID      CS271           Date: 01/22/17
; Description: Takes in integers from the user and uses them to do simple arithmetic operations

INCLUDE Irvine32.inc

.data

x			DWORD	?			;User input 1
y			DWORD	?			;User input 2
aadd		DWORD	?			;Result of addition
asub		DWORD	?			;Result of subtraction
amul		DWORD	?			;Result of multiplication
adiv		REAL4	?			;Result of division
arem		DWORD	?			;Remainder
thousand	WORD	1000
intro_0		BYTE	"--START OF PROGRAM--", 0
intro_1		BYTE	"        Program 1: Arithmetic        By: Jonathan Jones", 0
intro_2		BYTE	"This program will recieve two integers from the user to be added, subtracted, multiplied and divided.", 0
prompt_1	BYTE	"First integer: ", 0
prompt_2	BYTE	"Second integer: ",0
stradd		BYTE	" + ", 0
strsub		BYTE	" - ", 0			;Various strings to be used...
strmul		BYTE	" x ", 0
strdiv		BYTE	" / ", 0
strrem		BYTE	" remainder ", 0
streq		BYTE	" = ", 0
outro		BYTE	"Goodbye! --END OF PROGRAM--", 0
prompt_3	BYTE	"Enter 0 to play again or any other positive integer to end the program: ", 0
error_1		BYTE	"The second integer is not supposed to be greater than the first! Oops...", 0
ec_1		BYTE	"*EC: Program repeats until user chooses to quit.", 0
ec_2		BYTE	"**EC: Program validates the second number to be less than the first.", 0
ec_3		BYTE	"***EC: Program calculates and displays the Quotient as a floating point number.", 0
ec_4		BYTE	"(Additionally the program will repeat upon an **EC error)", 0

.code
main PROC

;introduction

_start:				;Start of the program upon activation of a jmp directive pointed here

	call	CrLf
	mov		edx, OFFSET intro_0			;Prints indicator for start of program
	call	WriteString
	call	CrLf
	mov		edx, OFFSET intro_1			;print intro 1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_1			;print extra credit part 1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_2			;print extra credit part 2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_3			;print extra credit part 3
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_4			;print extra credit part 4
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET intro_2			;print description of what the code does
	call	WriteString
	call	CrLf
	call	CrLf

;recieve user input

	mov		edx, OFFSET prompt_1		;prompt user for first integer
	call	WriteString
	call	ReadInt
	mov		x, eax
	call	CrLf
	mov		edx, OFFSET prompt_2		;prompt user for second integer
	call	WriteString
	call	ReadInt
	mov		y, eax
	call	CrLf
	call	CrLf

;Check if first integer is greater than the second

	mov		eax, x
	cmp		eax, y
	JL		_error			;jump to the error block of code

;addition calculation
	
	;perform addition

	mov		eax, x
	add		eax, y
	mov		aadd, eax

;subtraction calculation

	;perform subtraction

	mov		eax, x
	sub		eax, y
	mov		asub, eax

;multiplication calculation

	;perform multiplication

	mov		eax, x
	mov		ebx, y
	mul		ebx
	mov		amul, eax

;division calculation

	;perform division

	mov		eax, x
	cdq					;extend sign into EDX
	mov		ebx, y
	div		ebx
	mov		adiv, eax		;get the quotient
	mov		arem, edx		;get the remainder

	;EXTRA CREDIT

	fild		x			;Convert x to a floating point number
	fidiv		y			;Convert y to a floating point number
	fimul		thousand	;Multiply by 1000 to begin rounding up to .001
	frndint					;Round up to the nearest integer
	fidiv		thousand	;Divide by 1000 to round to .001
	fst			adiv		;Store the result in adiv

;print out results

	;addition

	mov		eax, x
	call	WriteDec
	mov		edx, OFFSET stradd
	call	WriteString
	mov		eax, y
	call	WriteDec
	mov		edx, OFFSET streq
	call	WriteString
	mov		eax, aadd
	call	WriteDec
	call	CrLf

	;subtraction

	mov		eax, x
	call	WriteDec
	mov		edx, OFFSET strsub
	call	WriteString
	mov		eax, y
	call	WriteDec
	mov		edx, OFFSET streq
	call	WriteString
	mov		eax, asub
	call	WriteDec
	call	CrLf

	;multiplication

	mov		eax, x
	call	WriteDec
	mov		edx, OFFSET strmul
	call	WriteString
	mov		eax, y
	call	WriteDec
	mov		edx, OFFSET streq
	call	WriteString
	mov		eax, amul
	call	WriteDec
	call	CrLf

	;division

	mov		eax, x
	call	WriteDec
	mov		edx, OFFSET strdiv
	call	WriteString
	mov		eax, y
	call	WriteDec
	mov		edx, OFFSET streq
	call	WriteString
	mov		eax, adiv
	call	WriteFloat
	mov		edx, OFFSET strrem
	call	WriteString
	mov		eax, arem
	call	WriteDec
	call	CrLf

;ask if user wants to quit or not

	mov		edx, OFFSET prompt_3
	call	WriteString
	call	ReadInt
	JZ		_start
	jmp		_end

_error:
;error message: Second int greater than first, returns user to start of program
	mov		edx, OFFSET error_1
	call	WriteString
	call	CrLf
	jmp		_start

_end:
;say goodbye

	call	CrLf
	mov		edx, OFFSET outro
	call	WriteString

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
