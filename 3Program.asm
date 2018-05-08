TITLE Program 3: Integer Accumulator     (3Program.asm)

; Author: Jonathan (Alex) Jones
; Course / Project ID                 Date: 2/12/2017
; Description: Takes in a series of negative integers from the user between [-100, -1] until the user enters
;	a positive integer and then calculates the sum and average of these numbers. Uses data validation and accumulators.

INCLUDE Irvine32.inc

;Lower limit
LOWER = -100

;;;;; DATA SEGMENT ;;;;;
.data

;introduction strings
header_1	BYTE		"Program 3: Integer Accumulator",10,13
header_2	BYTE		"By: Jonathan (Alex) Jones",10,13,0

intro_1		BYTE		"Hello! My name is Jonathan Jones. Today we will be using a signed integer accumulator!",10,13
prompt_1	BYTE		"Before we get started, what is your name? ",0

intro_2		BYTE		"Its a pleasure to meet you ",0 ;user name here
intro_3		BYTE		", let us begin...",10,13,10,13
intro_4		BYTE		"Enter an integer in the inclusive range [-100, -1]",10,13
intro_5		BYTE		"When you are finished, enter a non-negative integer and the results will be displayed.",10,13,10,13,0

;Getting numbers from the user...
prompt_2	BYTE		9,"Enter a number: ",0 ;Print line_num before every print of prompt_2
error_1		BYTE		"Out of range. Enter a number greater than or equal to -100",10,13,0

;Results strings
results_1	BYTE		"You entered ",0
results_2	BYTE		" valid numbers.",10,13

results_3	BYTE		"The sum of your valid numbers is ",0

results_4	BYTE		10,13,"The rounded average of your numbers is ",0
results_5	BYTE		10,13,"Remember that the floating point value is written in exponent form!",0

;goodbye string
outro_1		BYTE		10,13,10,13,"Thank you for your use of my Integer Accumulator!",10,13
outro_2		BYTE		"Farewell, ",0 ;user name here

;VARIABLES SECTION
;user name
user		BYTE		33 DUP(0)
;Data Validation
ln_count		DWORD		1		;Current line number
counter			SDWORD		0		;number of valid inputs

input_1		BYTE		33 DUP(0)		;String input to be checked for validity

;Calculations
sum			SDWORD		?			;Sum of all numbers inputted
avg			REAL4		?			;Average of all numbers inputted
thousand	WORD		1000		;Used for rounding avg to .001
;orig_avg	SDWORD		?			;The non extra credit option avg just in case I need it for full points


;extra credit strings
ec_1		BYTE		"*EC: Number the lines during user input.",10,13
ec_2		BYTE		"**EC: Calculate and display the average as a floating point number rounded to the nearest .001",10,13
ec_3		BYTE		"***EC: Do something astoundingly creative",10,13
ec_4		BYTE		9,"I wouldn't call this astoundingly creative but like the last program instead of just",10,13
ec_5		BYTE		9,"taking in an integer for data validation, I took in a string and did extra validation.",10,13,10,13,0

.code
main PROC

;introduction

	;intro
	mov		edx, OFFSET header_1
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

;get user input

	jmp _top		;skip error section on first run
_error:
	mov		edx, OFFSET error_1		;print error
	call	WriteString
	inc		ln_count				;user must enter another line of input so increment line number counter by 1
_top:
	mov		eax, ln_count				;print line number
	call	WriteDec
	mov		edx, OFFSET prompt_2
	call	WriteString

	;get a string from the user
	mov		edx, OFFSET input_1
	mov		ecx, 32						;set string size
	call	ReadString

;data validation

	;validate that string is a signed integer greater than or equal to -100
	mov		edx, OFFSET input_1
	call	ParseInteger32				;sets overflow flag if invalid
	jo		_error						;jump to error if overflow flag is set
	cmp		eax, LOWER
	jl		_error						;jump to error if num is less than the lower limit
	cmp		eax, 0
	jl		_calcadd					;jump to addition calculation is number is less than 0
	jmp		_calcavg					;jump to the average calculation when a positive number is entered (i.e. other checks fail)


;Calculations
_calcadd:
	add		sum, eax
	inc		ln_count		;increment line count
	inc		counter			;increment number of valid integers entered
	jmp		_top

_calcavg:
	mov		eax, counter
	cmp		eax, 0			;jump out immediately to results if division by zero will occur
	je		_results

	fild		sum			;Convert sum to a floating point number
	fidiv		counter		;Convert counter to a floating point number
	fimul		thousand	;Multiply by 1000 to begin rounding up to .001
	frndint					;Round up to the nearest integer
	fidiv		thousand	;Divide by 1000 to round to .001
	fst			avg			;Store the result in avg

	;;;the original requirement (not sure if required for full points) !!!IF TESTING: Don't forget to uncomment orig_avg!!!
	;mov		eax, counter
	;shr		eax, 1			;half denominator
	;mov		ebx, sum		
	;sub		ebx, eax		;add half the denominator to the numerator then divide so that it can round up if necessary
	;mov		eax, ebx
	;cdq					;extend sign into EDX
	;mov		ebx, counter
	;idiv	ebx
	;mov		orig_avg, eax		;get the quotient
	;;;

;print results
_results:
	mov		edx, OFFSET results_1
	call	WriteString
	mov		eax, counter			;number of valid integers entered
	call	WriteDec
	mov		edx, OFFSET results_2
	call	WriteString
	mov		eax, sum				;sum of all valid numbers
	call	WriteInt
	mov		edx, OFFSET results_4
	call	WriteString
	mov		eax, avg				;floating point average of all valid numbers rounded to .001
	call	WriteFloat
	mov		edx, OFFSET results_5
	call	WriteString

	;;;the original requirement (not sure if required for full points) !!!IF TESTING: Don't forget to uncomment orig_avg!!!
	;mov		eax, orig_avg
	;call	WriteInt
	;;;

;goodbye
	mov		edx, OFFSET outro_1
	call	WriteString
	mov		edx, OFFSET user
	call	WriteString
	call	crlf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
