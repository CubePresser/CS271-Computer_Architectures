TITLE Program 2: Fibonacci Numbers     (2Program.asm)

; Author: Jonathan (Alex) Jones
; Course / Project ID     CS271 Winter2017           Date: 1/29/2017
; Description: This program takes in from the user their name and an integer between 1 and 46.
;		The program then calculates and displays all the Fibonacci terms in the range the user specified.

INCLUDE Irvine32.inc

;Upper limit
UPPER = 46


;;;;;;DATA SEGMENT;;;;;;;
.data

;user name
user		BYTE		33 DUP(0)

;user integer input
input_1		BYTE		33 DUP(0)		;string input to be checked
input_2		DWORD		?				;Actual integer input to be placed in ecx register

;counter for placing spaces between terms and for how many tabs should be made
counter		DWORD		0
counter2	DWORD		0

;variables useful in calculations
fibnum		DWORD		?
prev_1		DWORD		0
prev_2		DWORD		0

;text to be displayed
header		BYTE		"Program 2: Fibonacci Numbers",10,13
header_2	BYTE		"By: Jonathan (Alex) Jones",10,13,0

intro_1		BYTE		"Hello! My name is Jonathan Jones. Today we will be calculating Fibonacci numbers!",10,13
prompt_1	BYTE		"Before we get started, what is your name? ",0

intro_2		BYTE		"Hi ",0

intro_3		BYTE		", let us begin...",10,13,10,13,0

intro_4		BYTE		"Enter the number of Fibonacci terms to be displayed.",10,13 
intro_5		BYTE		"Give the number as an integer in the range [1 .. 46].",10,13,10,13,0

prompt_2	BYTE		"How many Fibonacci terms do you want?: ",0

error_1		BYTE		"Out of range.  Enter a number in [1 .. 46].",10,13,0

outro_1		BYTE		"How wonderful..",10,13
outro_2		BYTE		"Farewell, ",0

;Extra credit strings
ec_1		BYTE		"*EC: Display the numbers in alligned columns.",10,13,9
ec_2		BYTE		"To do this, I used ASCII for tab instead of a 5 spaced string!",10,13
ec_3		BYTE		"**EC: Do something incredible.",10,13,9
ec_4		BYTE		"The program takes in a string as the integer in the range [1 .. 46] and converts",10,13,9
ec_5		BYTE		"this string to a 32-bit integer. It can handle negative integers and strings with",10,13,9
ec_6		BYTE		"no integers in it at all or even strings with characters and integers together!",10,13,9
ec_7		BYTE		"Im doing some advanced data validation here (for this assignment at least).",10,13,9
ec_8		BYTE		"See how I did it by reading the comments or code. Enjoy :)",10,13,10,13,0

;other useful display items
spc			BYTE		9,9,0
spc2		BYTE		9,0


;;;;;;CODE SEGMENT;;;;;;;
.code
main PROC

;introduction + get user name

	;intro
	mov		edx, OFFSET header
	call	WriteString
	mov		edx, OFFSET ec_1
	call	WriteString
	mov		edx, OFFSET intro_1
	call	WriteString

	;get user name
	mov		edx, OFFSET user
	mov		ecx, 32						;Set string length
	call	ReadString
	
	;intro 2
	mov		edx, OFFSET intro_2
	call	WriteString
	mov		edx, OFFSET user
	call	WriteString
	mov		edx, OFFSET intro_3
	call	WriteString

;User instructions
	mov		edx, OFFSET intro_4
	call	WriteString

;Get user input and check to see if valid

	jmp		_start						;Skip error message on first loop
_l1:		;Top of loop
	mov		edx, OFFSET error_1				;display error message
	call	WriteString
_start:		;first loop start here
	mov		edx, OFFSET prompt_2
	call	WriteString
	mov		edx, OFFSET input_1
	mov		ecx, 32							;set string length
	call	ReadString						;get string integer from user
	mov		edx, OFFSET input_1
	call	ParseDecimal32					;convert string to unsigned integer
	cmp		eax, 0
	je		_l1								;jump if user entered 0 or no integer was found
	cmp		eax, UPPER
	jg		_l1								;jump if user entered a num greater than 46	

	mov		input_2, eax				;store converted valid int

;Calculate Fibonacci numbers

	mov		eax, 1				;Initialize eax to 1 so that the program can actually advance past 0
	mov		ecx, input_2		;Initialize ecx to the number of Fibonacci terms the user wants
	jmp		_begin				;skip the intialization of eax to 0 for the first run through the loop
_l2:
	mov		eax, 0					;initialize eax to 0 after the first loop and all others following
_begin:
	add		eax, prev_1				;Add the two previous fibonacci terms to eax
	add		eax, prev_2
	mov		fibnum, eax				;store new fibonacci term
	mov		eax, prev_1				
	xchg	eax, prev_2				;place the new fib term in prev_1 and shift the previous prev_1 to prev_2
	mov		eax, fibnum
	mov		prev_1, eax

;Display Fibonacci numbers

	call	WriteDec
	inc		counter					;One more term is on the line!
	inc		counter2				;One more term has been written
	mov		eax, counter
	;check if 5 terms are displayed on a line yet, if so, make a new line
	cmp		eax, 5
	je		_newline				;jump to make a new line
	mov		eax, counter2
	cmp		eax, 35					;If the number of terms has exceeded 35, stop "double tabbing" and just single tab
	jge		_altspace						;start single tabbing
	mov		edx, OFFSET spc			;else double tab
	call	WriteString	
	loop	_l2
	jmp		_end
_altspace:
	mov		edx, OFFSET spc2
	call	WriteString
	loop	_l2
	jmp		_end
_newline:
	mov		counter, 0				;set "how many on the line" counter to 0
	call	Crlf
	loop	_l2
	

;Say goodbye

_end:
	call	Crlf						;add some extra lines to make it look nicer
	call	Crlf
	mov		edx, OFFSET outro_1
	call	WriteString
	mov		edx, OFFSET user
	call	WriteString
	call	CrLf

	exit	; exit to operating system

main ENDP

END main
