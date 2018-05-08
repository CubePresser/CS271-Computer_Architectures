TITLE Advanced String Data Validation     (6Program.asm)

; Author: Jonathan Jones
; Course / Project ID   CS271              Date: 3/10/2017
; Description: This program takes in 10 string inputs from the user, validates them and convertes them into floats BYTE by BYTE using the stosb
;	and lodsb commands. Those numbers are stored into a REAL4 array, a sum and average is calculated and the floats are converted
;	BYTE by BYTE back into strings and printed to the screen.

INCLUDE Irvine32.inc

;MACRO Name: getString
;Description: Prompts the user and inserts string input into string passed in.
;Recieves: String prompt (reference), string to store input (reference)
;Returns: Memory address in uInputLoc gets the user input
;Pre-Conditions: Addresses of valid strings are passed in.
;Post-Conditions: Prompt has been displayed to screen. Memory address at uInputLoc contains user input.
getString		MACRO	dispPrompt, uInputLoc

	push	edx
	mov		edx, dispPrompt
	call	WriteString
	mov		ecx, 32
	mov		edx, uInputLoc
	call	ReadString
	pop		edx

ENDM

;MACRO Name: displayString
;Description: Prints a string of characters to the screen.
;Recieves: String to be printed (reference)
;Returns: none
;Pre-Conditions: Address of valid string must be passed in (Its gotta be a string)
;Post-Conditions: String is displayed on screen.
displayString	MACRO	dispStr

	push	edx
	mov		edx, dispStr
	call	WriteString
	pop		edx

ENDM

;MACRO Name: clearString
;Description: Fills a passed in string with null terminators (zeroes)
;Recieves: String to be "cleared" (reference)
;Returns: Passed in string only contains null terminators
;Pre-Conditions: Address of string MUST START AT THE BEGINNING OF THE STRING! STRING MUST NOT BE EMPTY!
;Post-Conditions: Passed in string only contains null terminators

clearString		MACRO	strBeans
	LOCAL	_clearStrLp
	push	edi
	push	ecx						;save used registers
	push	eax
	INVOKE Str_length, strBeans		;get length of the string
	cld								;clear direction flag (just in case)
	mov		edi, strBeans			;edi contains string to be cleared
	mov		ecx, eax
	_clearStrLp:
		mov		eax, 0
		stosb					;store 0 at position, next position, repeat
		loop	_clearStrLp
	pop		eax
	pop		ecx					;save used registers
	pop		edi

ENDM

;constants

MAX = 10		;How big will the array be?

;;;;;START OF DATA SEGMENT;;;;;

.data

;introduction

intro	BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",10,13
		BYTE	"Written by: Jonathan Jones",10,13,10,13
		BYTE	"Please provide 10 signed integers or floats. To preserve precision, a maximum of 8 chars is allowed including the '.'",10,13
		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",10,13
		BYTE	"After you have finished inputting the raw numbers I will display a list",10,13
		BYTE	"of the numbers, their sum, and their average value.",10,13,10,13
		BYTE	"*EC: Number each line of user input and display a running subtotal of the user's numbers.",10,13
		BYTE	"**EC: Handle signed integers.",10,13,9
		BYTE	"The program will take in signed integer input such as +5 or -2 and items like 0 as well",10,13,9
		BYTE	"but will convert them to floats for calculations.",10,13
		BYTE	"***EC: Make your readVal and writeVal procedures recursive.",10,13,9
		BYTE	"I was able to make writeVal recursive but due to the amount of information that was needed",10,13,9
		BYTE	"from readVal due to the extra credits I couldn't make it recursive.",10,13
		BYTE	"****EC: Implement procedures ReadVal and WriteVal for floating point values using the FPU.",10,13,9
		BYTE	"The entire program uses floating point values and reads them. The sum and the average are rounded to .001",10,13,9
		BYTE	"to avoid the mathematical hell of calculating the number of digits on the right.",10,13,10,13,0

;arrays
valArr		REAL4	MAX	DUP(0.0)		;will hold values entered by user
valArrSize	DWORD	0					;keeps track of current size of array
LeftDigits	DWORD	MAX DUP(0)			
RightDigits	DWORD	MAX DUP(0)			;the digits array contain the number of digits to the left and right of the radix point of its
										;respectable counterpart in valArr (for conversion routines)

;User Input buffer
userInput	BYTE	32 DUP(0)

;more buffers
leftBuffer	DWORD	?
rightBuffer	DWORD	?					;buffers to keep track of information while in procedures
sumBuffer	BYTE	32 DUP(0)
avgBuffer	BYTE	32 DUP(0)

stringBuff	BYTE	32 DUP(0)			;fill these with strings to print
anotherStr	BYTE	32 DUP(0)
counter		DWORD	0

;Strings
	;error
errMsg		BYTE	"ERROR: You did not enter a valid signed floating point or signed integer or your number was too large. Try again!",10,13,0
numTries	DWORD	0
title0		BYTE	"You entered the following numbers: ",10,13,0
title1		BYTE	"The sum (rounded to a .001 precision) of these numbers is: ",0
title2		BYTE	"The average (rounded to a .001 precision) is: ",0
title3		BYTE	"Current sum: ",0


	;prompt
prompt		BYTE	"Please enter a signed integer or a signed float (All # must have a + or - except 0): ",0

;;;;;START OF CODE SEGMENT;;;;;

.code
main PROC

	;introduction
	push	OFFSET intro
	call	introduction

	;An unhealthy amount of parameters being passed into getData (This program gets a bunch of essential data from the user input, if I had more time and no finals, I would modularize it more (if possible))
	push	OFFSET	sumBuffer		;ebp+60
	push	OFFSET	title3			;ebp+56
	push	OFFSET	anotherStr		;ebp+52
	push	OFFSET	stringBuff		;ebp+48
	push	OFFSET	counter			;ebp+44
	push	OFFSET	valArrSize		;ebp+40
	push	OFFSET	valArr			;ebp+36
	push	OFFSET	rightDigits		;ebp+32
	push	OFFSET	leftDigits		;ebp+28
	push	OFFSET	errMsg			;ebp+24
	push	OFFSET	prompt			;ebp+20
	push	OFFSET	userInput		;ebp+16
	push	OFFSET	rightBuffer		;ebp+12
	push	OFFSET	leftBuffer		;ebp+8
	call	getData

	call	crlf

	;display the title for the list of user input
	push	OFFSET title0
	call	arrayDisplayTitle

	;display the list of user input
	push	OFFSET anotherStr
	push	OFFSET leftDigits
	push	OFFSET rightDigits
	push	OFFSET valArrSize
	push	OFFSET valArr
	call	displayArray

	call	crlf

	;Calculate and display the sum of all user input
	push	valArrSize
	push	OFFSET title1
	push	OFFSET sumBuffer
	push	OFFSET valArr
	call	calculateSum

	call	crlf

	;Calculate and display the average of all user input
	push	OFFSET title2
	push	OFFSET avgBuffer
	push	OFFSET valArr
	call	calculateAvg

	call	crlf

	exit	; exit to operating system
main ENDP

;Function Name: Introduction
;Description: Displays introductory strings to the screen
;Recieves: Intro string (Reference)
;Returns: Prints to screen
;Pre-Conditions: Valid intro and extra credit strings recieved
;Post-Conditions: Prints to the screen the two passed in strings
introduction	PROC
	push	ebp
	mov		ebp, esp

	mov		edi, [ebp+8]		;edi contains introductory strings
	displayString	edi

	pop		ebp
	ret		4
introduction	ENDP

;Function Name: arrayDisplayTitle
;Description: Displays to the screen a string that serves as a title for the array when printed out at the end.
;Recieves: Title for array of numbers to be displayed 
;Returns: none
;Pre-Conditions: Must recieve a valid string to be displayed.
;Post-Conditions: String title must have been displayed to the screen.
arrayDisplayTitle	PROC
	push	ebp
	mov		ebp, esp

	mov		edi, [ebp+8]
	displayString	edi

	pop		ebp
	ret		4
arrayDisplayTitle	ENDP

;Function Name: getData
;Description: The boss procedure. Runs procedures that get user input ten times and displays a list of the user input on each loop. Gathers a massive amount of data.
;Recieves: DWORD var to hold num digits left of radix point (reference), DWORD var to hold num digits left of radix point (reference)
; String to hold user input (reference), Prompt string (reference), error message string (reference),
; DWORD Array to hold each number of digits left of radix point (reference), DWORD Array to hold each number of digits right of radix point (reference),
; REAL4 Array to hold floating point user input (reference), DWORD var to hold size of array of float user input (reference)
; DWORD var counter to be used to count each line of user input (reference), Two empty 32-bit strings for printing (reference)
; String that says "Current sum: "
; Empty 32 bit string buffer for holding the sum
;Returns: Array filled with floats, size of that array, arrays containing # of digits left and right of radix point for each float in the values array
;Pre-Conditions: Must recieve all parameters as per usual. Must recieve valid strings to print. All other variables should be empty.
;Post-Conditions: All strings must have been printed out. Values array must contain MAX number floating point numbers. Size of array must be MAX. Left and Right digit arrays must contain the left and right number of digits for each number in the values array.
getData PROC
	push	ebp
	mov		ebp, esp		;set up stack frame

	mov		ecx, MAX		;ecx contains the maximum size of the val array as a constant
	mov		eax, 0			;eax will be used do incrememnt through the val array (incremented by 4 after each insertion into the values array)



_dataLoop:
	push	ecx				;save loop counter
	push	eax				;save array traversal counter
	push	[ebp+48]		;String buffer number 1
	push	[ebp+44]		;Counter for displaying number of user inputs and errors
	push	[ebp+24]		;Error message string
	push	[ebp+20]		;Prompt string
	push	[ebp+16]		;Empty string for holding user input
	push	[ebp+12]		;Buffer to hold number of digits on right of number
	push	[ebp+8]			;Buffer to hold number of digits on left of number
	call	readVal
	pop		eax				;restore array traversal counter

	mov		esi, [ebp+36]		;mov		esi, OFFSET valArr
	fstp	REAL4 PTR [esi+eax]		;store float at ST(0) into the array of values at spot eax
	
	;Store into array holding right digits the number of digits to the right from user entered number
	mov		esi, [ebp+12]		;mov		esi, OFFSET rightBuffer
	mov		ebx, [esi]
	mov		edi, [ebp+32]		;mov		edi, OFFSET rightDigits
	mov		[edi+eax], ebx
	
	;Check the left buffer
	mov		esi, [ebp+8]		;mov		esi, OFFSET leftBuffer
	mov		ebx, [esi]

	;if the number of digits to the left is shown as zero, add one (There is always one digit to the left of the radix point (even if its a zero)
	cmp		ebx, 0
	jne		_noInc
	inc		ebx
_noInc:

	;Store into array holding left figits the number of digits to the left from user entered number
	mov		edi, [ebp+28]		;mov		edi, OFFSET leftDigits
	mov		[edi+eax], ebx
	  
	mov		edi, [ebp+40]
	mov		ebx, 1				;increment valArrSize
	add		[edi], ebx

	add		eax, 4
	push	eax				;save array position counter

	push	[ebp+52]		;Empty string buffer
	push	[ebp+28]		;Array of digits left
	push	[ebp+32]		;Array of digits right
	push	[ebp+40]		;Size of values array
	push	[ebp+36]		;Values array
	call	displayArray	;Display the running subtotal of the users numbers (a list of the numbers entered in total)
	mov		edi, [ebp+40]
	mov		eax, [edi]
	push	eax						;
	push	[ebp+56]				;title
	push	[ebp+60]				;buffer
	push	[ebp+36]				;array
	call	calculateSum
	call	crlf
	pop		eax				;restore array position counter

	pop		ecx
	loop	_dataLoop

	pop		ebp

	ret		56
getData ENDP

;Function Name: readVal
;Description: Gets input from the user, converts it to a floating point, sets its sign according to user input and leaves this number at ST(0) on the FPU stack.
; User must enter a sign next to every number except for zeroes where it is assumed they are positive unless told otherwise (entering a negative fraction).
; Gets the number of digits to the left and right of the radix point from user inputted numbers (even integers).
;Recieves: Enpty string buffer (reference), array of digits left (reference), array of digits right (reference), size of values array (reference)
; Values array (reference)
;Returns: ST(0) contains user input converted into a float
;Pre-Conditions: Must recieve correct order of parameters as listed in "Recieves". All pre-conditions for getData must be met.
;Post-Conditions: User converted integer must be stored at ST(0) in the FPU stack. The number of digits left and right must be stored in their respective buffers.
; Valid user input was converted to a float. 
readVal PROC

	strLen		EQU	DWORD PTR [ebp-4]
	integerBuff	EQU	DWORD PTR [ebp-8]
	radixFound	EQU DWORD PTR [ebp-12]
	digLeft		EQU	DWORD PTR [ebp-16]			;Set up locals
	digRight	EQU DWORD PTR [ebp-20]
	ten			EQU DWORD PTR [ebp-24]
	sign		EQU SDWORD PTR [ebp-30]

	push	ebp
	mov		ebp, esp

	sub		esp, 34				;Set up stack frame
	mov		ten, 10
	mov		sign, +1			;Initialize sign variable to positive 1 (Will be used to convert float to negative number if needed)


	cld		;clear direction flag
	jmp		_readBegin

;print error message if user entered invalid input
_error:
	mov		edx, [ebp+24]		;mov	edx, OFFSET errMsg
	displayString	edx
_readBegin:
	mov		edi, [ebp+28]
	mov		eax, 1				;increment counter by 1
	add		[edi], eax			;Keeping track of how many times a prompt or error message has been printed
	mov		eax, [edi]			;Move into eax the counter
	mov		edi, [ebp+32]		;edi contains empty string for integerToString to store counter in as a string
	call	integerToString
	mov		eax, 45				;ASCII '-'
	stosb						;Add to the counter string a dash
	mov		edx, [ebp+32]		;move edi into edx and print out counter string
	displayString	edx	
	mov		integerBuff, 0
	mov		radixFound, 0		;initialize locals to be zero at the beginning of every loop caused by an error
	mov		digLeft, 0
	mov		digRight, 0
	finit							;clear FPU stack
	getString	[ebp+20], [ebp+16]		;getString	OFFSET prompt, OFFSET userInput
	xor		eax, eax					;set eax = 0
	INVOKE	Str_length, [ebp+16]		;get length of user entered string
	cmp		eax, 9
	jg		_error						;if the length of the user entered string is greater than 9 characters, it is too big. Error
	mov		esi, [ebp+16]
	mov		ecx, eax					;set counter equal to the length of the string
	mov		strLen, eax
;Beginning Validation
_Validation:
	mov		eax, strLen				;set eax equal to the length of the string
	cmp		ecx, eax				;Is eax equal to the length of the string or not? If so, check for a sign character or zero
	lodsb
	jne		_readTest3
	_readTest1:
		mov		ebx, 43		;ASCII '+'
		cmp		eax, ebx
		jne		_readTest2				;is the first character of the user input a '+'? If so set the sign variable equal to 1
		mov		sign, 1
		loop	_Validation
	_readTest2:
		mov		ebx, 45		;ASCII '-'
		cmp		eax, ebx
		jne		_zeroTest				;is the first character of the user input a '-'? If so set the sign variable equal to -1
		mov		sign, -1
		loop	_Validation
	_zeroTest:
		mov		ebx, 48
		cmp		eax, ebx
		jne		_error					;is the first character of the user input a '0', if so set the sign equal to positive
		mov		sign, 1
		loop	_Validation
		fldz
		jmp		_readEnd

_jmpHelper2:
jmp	_Validation
_jmpHelper:				;Some jumps are too far from their labels due to macros, help them jump with these
jmp	_error

	_readTest3:
		mov		ebx, 46		;ASCII '.'
		cmp		eax, ebx
		jne		_readTest4
		push	eax
		mov		eax, radixFound
		cmp		eax, 0						;does the string have a radix point? If so, set radixFound equal to 1
		jne		_jmpHelper
		mov		radixFound, 1
		pop		eax
		jmp		_floatConversionLeft		;Since a radix point was found, convert the numbers left of the radix point to a float
		loop	_jmpHelper2
	_readTest4:
		mov		ebx, 48
		cmp		eax, ebx
		jl		_jmpHelper
		mov		ebx, 57					;is the character a number?
		cmp		eax, ebx
		jg		_jmpHelper
		sub		eax, 48					;convert the ASCII character number into an integer by subtracting 48 from it
		push	eax
		mov		eax, integerBuff
		mov		ebx, 10					;set eax equal to the current number in the integer buffer, multiply it by 10
		mul		ebx						;then add the recently calculated number to it. (#=123, numfound = 3, intbuff = 12, 12*10 + 3 = 123)
		mov		ebx, eax
		pop		eax
		add		eax, ebx
		mov		integerBuff, eax
		mov		eax, radixFound			;If there is a radix found, increment the number of digits right, else increment the number of digits left
		cmp		eax, 0
		jne		_incRight
		inc		digLeft
		loop	_jmpHelper2
		fild	integerBuff				;load the integer buffer into the FPU stack
		mov		integerBuff, 0
		jmp		_readEnd

_incRight:
	inc		digRight
	loop	_jmpHelper2					;increment digits right and if the loop is finished, convert the right digits to a float
	jmp		_floatConversionRight
_floatConversionLeft:
	fild	integerBuff
	mov		integerBuff, 0				;convert the left digits to a float, jump to the end if the loop is over
	loop	_jmpHelper2
	jmp		_readEnd
_floatConversionRight:
	fld1
	push	ecx
	mov		ecx, digRight
	_placeMult:
	fild	ten
	fmul						;Exponentiate 10 to the number of digits right then divide the intbuffer by that number and add it to the entire number being calculated
	loop	_placeMult
	fild	integerBuff
	fdivr
	fadd
	pop		ecx


_readEnd:
	fild	sign
	fmul						;Multiply the calculated number by the sign (-1 or 1)
	mov		eax, digLeft
	mov		edi, [ebp+8]
	mov		[edi], eax
	mov		eax, digRight		;set leftBuffer equal to digLeft, and rightBuffer equal to digRight
	mov		edi, [ebp+12]
	mov		[edi], eax
	mov		esp, ebp
	pop		ebp
	ret		28
readVal	ENDP

;Function Name: floatToInteger
;Description: Converts value at ST(0) to an integer based on the number of digits right of the radix point (Multiplies out the fractions)
;Recieves: float to be converted at ST(0), digits to right of radix point (value)
;Returns: integer in eax register
;Pre-Conditions: ST(0) must contain the float to be converted to an integer
;Post-Conditions: eax contains converted float
floatToInteger	PROC
	ten		EQU	DWORD PTR [ebp-4]
	buffer	EQU DWORD PTR [ebp-8]			;set up locals

	push	ebp
	mov		ebp, esp

	sub		esp, 8

	mov		ten, 10
	mov		ecx, [ebp+8]		;mov		ecx, num places right
	cmp		ecx, 0				;if the number of places right is zero, Just get the absolute value of the number
	fld1						;add 1 to the FPU stack
	je		_noRight
_mulPlaces:
	fild	ten
	fmul					;for the number of digits right, exponentiate 10
	loop	_mulPlaces
_noRight:
	fmul
	fabs					;multiply ST(0) by the exponentiated 10 and get the absolute value of it so it can fit in an unsigned int var
	fistp	buffer
	mov		eax, buffer

	mov		esp, ebp
	pop		ebp
	ret		4
floatToInteger	ENDP

;Function Name: integerToString
;Description: recursively converts an integer to a string by dividing the integer by 10, pushing the remainder onto the stack until the quotient is 0 and then popping the remainder back out and storing it into a string
;Recieves: integer in eax, edi contains offset of string to be filled
;Returns: memory address im edi now contains the integer as a string
;Pre-Conditions: eax contains UNSIGNED integer to be converted, edi contains offset of string to be filled
;Post-Conditions: memory location in edi contains the integer as a string
integerToString PROC			
	push	eax					;save previous quotient
	push	edx					;save previous remainder
	xor		edx, edx			;set edx equal to 0
	mov		ebx, 10				;ebx equals 10
	div		ebx					;quotient divided by 10
	cmp		eax, 0				;is the quotient zero?
	je		_intToStrLp
	call	integerToString		;recursive call
_intToStrLp:
	mov		eax, edx			;move into eax the remainder
	add		eax, 48				;add to the number (which is single digit right now) 48 so that it is ASCII friendly
	stosb						;store the character in the string at edi
	pop		edx					;restore previous remainder
	pop		eax					;restore previous quotient
	ret
integerToString ENDP

;Function Name: writeVal
;Description: First determines if the number at ST(0) is positive or negative, adds '+' or '-' to the 
;	string passed in and calls a recursive function to convert the float to a string. Then prints out this string to the screen.
;Recieves: String buffer (reference), number of digits to the right (value), number of digits to the left (value)
;Returns: none
;Pre-Conditions: ST(0) must have a float to be converted. String buffer recieved must only contain null terminators. Either num digits left or digits right should be greater than 0
;Post-Conditions: Float is successfully converted to a string and given a sign then printed to the screen.
writeVal	PROC
	push	ebp
	mov		ebp, esp

	cld							;clear direction flag just in case
	push	edi
	mov		edi, [ebp+8]		;move into edi the string buffer to be used for printing

	xor		eax, eax
	ftst							;test ST(0) to 0.0, sets FPU flags
	fnstsw	ax						;send FPU flags to EFLAGS
	sahf
	jnc		_positive
	mov		al, '-'
	stosb				;if negative, add a '-' to the string buffer
	jmp		_skipPos
_positive:
	mov		al,'+'
	stosb				;if positive, add a '+' to the string buffer
_skipPos:
	push	[ebp+12]		;number of digits to the right
	call	floatToInteger			;convert the float to an unsigned integer
	push	eax
	mov		eax, [ebp+12]
	cmp		eax, 0				;is the number of digits right zero? If so, set the number of digits right to negative one (its a case)
	pop		eax
	jne		_pusher1
	push	eax
	mov		eax, [ebp+12]
	dec		eax						;decrement number of digits right then push as parameters before calling writeValRecursive
	mov		[ebp+12], eax
	pop		eax
	push	[ebp+12]
	push	[ebp+16]
	jmp		_callWriteVal
_pusher1:
	push	[ebp+12]			;PARAMETER: Number of digits right
	push	[ebp+16]			;PARAMETER: Number of digits left
_callWriteVal:	
	call	writeValRecurse
	pop		edi
	push	edi
	displayString	edi				;display the created string to the screen
	pop		edi
	clearString		edi				;null terminate the entire string buffer for later use

	mov		esp, ebp
	pop		ebp
	ret		12
writeVal	ENDP

;Function Name: writeValRecurse
;Description: Recursive function that converts an unsigned integer to a float string given the number of digits to the left and right.
;	Basically follows the same princples of integerToString except given the right information it places a radix point in the string if needed. 
;Recieves: String buffer (reference), number of digits left (value), number of digits right or negative one for no right digits (value)
;	(float) unsigned integer to be converted to a string
;Returns: string buffer passed in now contains the converted float to string
;Pre-Conditions: String buffer passed in must only contain null terminators and is 32 bits long, if there are no right digits then the number of digits right should be -1
;Post-Conditions: String buffer passed in now contains a successfully converted unsigned integer into a float string
writeValRecurse PROC
	push	ebp
	mov		ebp, esp

	push	eax				;save previous quotient
	push	edx				;save previous remainder
	xor		edx, edx		;set edx equal to 0

	push	eax
	mov		eax, -1
	cmp		[ebp+12], eax			;Is the number of digits right equal to negative 1? if so, skip the radix point area of code
	pop		eax
	je		_notEqual
	push	eax
	mov		eax, 0
	cmp		[ebp+12], eax		;does the number of digits to the right equal zero? if so, we can add the radix point to the string. (We are filling the stack with the number backwards)
	pop		eax
	jne		_notEqual
	mov		edx, -2				;48-2 = 45 which is ASCII for '.'
	push	eax
	mov		eax, [ebp+12]			;decrement number of digits right
	dec		eax
	mov		[ebp+12], eax
	pop		eax		
	jmp		_recurseCall			;we added the radix point so skip everything else and recurse once more

_notEqual:
	mov		ebx, 10			;divide the number by 10, the remainder is what we want (a single number character to be added as ASCII)
	div		ebx

	test	eax, eax		;if quotient equals zero then we might have our base case else, no base case
	jne		_noBoop
	push	eax
	mov		eax, [ebp+12]	;we truely have our base case if the number of digits to the right is also zero, meaning, no more stuff left to add
	cmp		eax, 0
	pop		eax
	jle		_boop2
_noBoop:
	push	eax
	mov		eax, [ebp+12]		
	dec		eax				;decrement number of digits right
	mov		[ebp+12], eax
	pop		eax
_recurseCall:
	push	[ebp+12]		;push		num digits right (will be [ebp+12] on other side)
	push	[ebp+8]			;push		num digits left (will be [ebp+8] on the other side)
	call	writeValRecurse
_boop2:
	mov		eax, edx
	add		eax, 48
	stosb				;convert the number character to ASCII by adding 48 and store in the string buffer
	pop		edx
	pop		eax
	pop		ebp
	ret		8
writeValRecurse ENDP

;Function Name: calculateSum
;Description: Takes in the array of floating point values, a title for the sum and a string to print the sum in and calculates the sum of the entire array and prints it to the screen
;Recieves: REAL4 array of floats that is size MAX (reference), string buffer to store sum in (reference), title string to be printed (reference), size of array (value)
;Returns: none
;Pre-Conditions: title string is either empty or contains a title to be printed, values array must be REAL4 and contain floats, string buffer passed in must be empty, size must not be zero
;Post-Conditions: sum must be printed to the screen
calculateSum	PROC
	push	ebp
	mov		ebp, esp

	finit
	fldz						;load into ST(0) the value zero (Serves as a starting point for the sum which will be stored at ST(0))
	mov		esi, [ebp+8]		;mov into esi, valArr
	mov		ecx, [ebp+20]			;ecx is size of array
	mov		eax, 0				;eax will be the number of bytes to access
_sumLoop1:
	fld		REAL4 PTR [esi+eax]
	fadd							;for the size of the array, add each element to ST(0)
	add		eax, 4				;increment eax by 4 bytes
	loop	_sumLoop1

	mov		edi, [ebp+16]
	displayString	edi			;print the title

	;the sum should be in eax represented as an integer
	mov		edi, [ebp+12]		;edi contains string buffer
	push	1					;number of digits left, any number you want
	push	3					;number of digits right (how many places should be rounded to? 3 for .001)
	push	edi					;string buffer
	call	writeVal			;write the value to the screen
	call	crlf

	pop		ebp
	ret		16
calculateSum	ENDP

;Function Name: calculateAvg
;Description: Does everything that calculate sum does but it has a local for the size of the array MAX and divides the sum by this number
;Recieves: REAL4 array of floats that is size MAX (reference), string buffer to store sum in (reference), title string to be printed (reference)
;Returns: none
;Pre-Conditions: title string is either empty or contains a title to be printed, values array must be REAL4 and contain floats and be size MAX, string buffer passed in must be empty
;Post-Conditions: average must be printed to the screen
calculateAvg	PROC
	ten		EQU	DWORD PTR [ebp-4]
	push	ebp
	mov		ebp, esp

	sub		esp, 4

	mov		ten, 10
	finit
	fldz						;load into ST(0) the value zero (Serves as a starting point for the sum which will be stored at ST(0))
	mov		esi, [ebp+8]		;mov into esi, valArr
	mov		ecx, MAX			;ecx is size of array
	mov		eax, 0				;eax will be the number of bytes to access
_sumLoop1:
	fld		REAL4 PTR [esi+eax]
	fadd
	add		eax, 4
	loop	_sumLoop1

	fild	ten
	fdiv

	mov		edi, [ebp+16]
	displayString	edi

	;the sum should be in eax represented as an integer
	mov		edi, [ebp+12]		;edi contains string buffer
	push	1
	push	3
	push	edi
	call	writeVal

	mov		esp, ebp
	pop		ebp
	ret		12
calculateAvg	ENDP

;Function Name: displayArray
;Description: Shows a list of all the floats in the array passed into it with signs and all for the array's current size.
;Recieves: REAL4 array of floats (reference), current size of the array, array of digits on the right of numbers, array of digits on the left of numbers, string buffer for printing
;Returns: none
;Pre-Conditions: Array of floats must not be empty and must be REAL4
;Post-Conditions: Array is displayed to the screen accurately
displayArray PROC	
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp+8]		;esi is equal to the array 
	mov		edi, [ebp+12]
	mov		ecx, [edi]			;ecx equals current size of array (For printing the array of numbers after every valid user input)
	mov		eax, 0				;eax will be current position in array in bytes
	cmp		ecx, [edi]
	mov		edi, [ebp+24]		;is ecx equal to the size, if so, store into the string "[ ", else store " ," and store a number in the string
	jne		_printArr
	push	eax
	mov		eax, 91			;ASCII '['
	cld
	stosb
	mov		eax, 32			;ASCII ' '
	stosb
	pop		eax
	jmp		_start1
_printArr:
	push	eax
	mov		eax, 44		;ASCII ','
	stosb									;store into the string " ,"
	mov		eax, 32		;ASCII ' '
	stosb
	pop		eax
_start1:
	push	ecx
	finit
	fld		REAL4 PTR [esi+eax]			;load from the array a float to be printed
	push	esi
	push	eax
	mov		esi, [ebp+20]
	mov		ebx, [esi+eax]
	push	ebx		;parameter		number of digits on the left
	mov		esi, [ebp+16]
	mov		ebx, [esi+eax]
	push	ebx		;parameter		number of digits on the right
	push	edi		;parameter		BUFFER
	mov		edi, [ebp+24]
	call	writeVal			;write the value (the buffer will be cleaned after write val is called so we won't be printing "[ #, [ #")
	pop		eax
	pop		esi

	add		eax, 4			;increment eax by 4 bytes
	pop		ecx
	loop	_printArr

	mov		edi, [ebp+24]		;edi equals beginning of string buffer
	push	edi					;save beginning
	mov		eax, 32
	stosb						;add to the string buffer " ]"
	mov		eax, 93
	stosb
	pop		edi			;restore the beginning of the array
	displayString	edi		;print the string
	clearString		edi		;clean the string

	call	crlf

	pop		ebp

	ret		20
displayArray ENDP




END main