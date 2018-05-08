TITLE Program 4: Composite Numbers     (template.asm)

; Author: Jonathan Jones
; Course / Project ID    CS271             Date: 2/19/2017
; Description: This program takes in a number from the user between 1 and UPPER and then prints out all the
;	composite numbers in that range.

INCLUDE Irvine32.inc

UPPER = 400

.data

;extra credit strings
ec_1		BYTE	"*EC: Align the columns.",10,13
ec_2		BYTE	"**EC: Display more composites but show them one page at a time.",10,13,9,"NOTE: Given that the numbers don't reach above 1 million or so, this works fine.",10,13,9,"Thats too many numbers for my primes array anyway :) Try out some different UPPER sizes!",10,13
ec_3		BYTE	"***EC: Check only against prime divisors.",10,13,9,"I used an array to hold my primes for this problem. The number being checked would divide from that",10,13,9,"array of primes only. If it wasn't a composite it was placed in the primes array",10,13
ec_4		BYTE	"****EC???: I used string data validation once again instead of just checking integers.",10,13,10,13,0

;introduction
intro_1		BYTE	"Program 4: Composite Numbers",9,"By: Jonathan Jones",10,13,0
intro_2		BYTE	"This program will recieve a number between 1 and ",0
intro_3		BYTE	" and print all the composite numbers in that range!",10,13,10,13,0

;GetUserData
	;strings
prompt_1	BYTE	"Enter all the composite numbers you would like to see.",10,13,"I will accept all numbers between 1 and ",0
prompt_2	BYTE	" inclusive.",10,13,0

prompt_3	BYTE	"Enter the number of composites to display [1...",0
prompt_4	BYTE	"]: ",0

error_1		BYTE	"Out of range. Try again.",10,13,0

	;variables
uinput		BYTE	33	DUP(0)		;user input as a string
unum		DWORD	?				;user input when converted to unsigned integer

;ShowComposites
count		DWORD	?			;Holds value of ECX in top loop for the nested loop procedure
count_1		DWORD	1			;number to be printed if a composite

;IsComposite
count_2		DWORD	0			;Keeps track of the loop that checks if composite or not

;PrintComposites
num_comp	DWORD	0								;number of composites currently printed to the screen on current line
num_line	DWORD	1								;number of lines currently printed to the screen
ptab		BYTE	9,0								;tab
npl			DWORD	10								;number of composites per line allowed
toGO		BYTE	"To go to the next page: ",0

;Farewell
outro_1		BYTE	10,13,10,13,"It has been a great pleasure having you here.",10,13,"Farewell...",10,13,0

;Primes array info
primes		DWORD	1000	DUP(?)		;Array that holds all prime numbers discovered in the program
numprimes	DWORD	0					;Number of primes in the array so far
ptr_prim	DWORD	OFFSET primes		;Address of the beginning of primes
ptr_loc		DWORD	OFFSET primes		;Address of current location when inserting prime #'s into the primes array

.code
main PROC

	call	Introduction
	call	GetUserData
	call	ShowComposites
	call	Farewell

	exit	; exit to operating system
main ENDP

;Function Name: Introduction
;Description: Introduces the user to the program
;Recieves: none
;Returns: none
;Pre-Conditions: introduction strings defined globally
;Post-Conditions: introduction strings are printed to the console
Introduction PROC

	mov		edx, OFFSET intro_1
	call	WriteString
	mov		edx, OFFSET ec_1
	call	WriteString
	mov		edx, OFFSET intro_2			;introductory strings
	call	WriteString
	mov		eax, UPPER
	call	WriteDec
	mov		edx, OFFSET intro_3
	call	WriteString

	ret

Introduction ENDP

;Function Name: GetUserData
;Description: Gets a number from the user between 1 and UPPER, uses Validate to validate the number and then stores it in unum
;Recieves: none
;Returns: none
;Pre-Conditions: Strings used are defined globally
;Post-Conditions: User data is validated as a valid integer and then is stored in unum
GetUserData PROC

	mov		edx, OFFSET prompt_1
	call	WriteString
	mov		eax, UPPER
	call	WriteDec
	mov		edx, OFFSET prompt_2		;introduce prompting to user
	call	WriteString
	jmp		_loopVal

_error:
	mov		edx, OFFSET error_1
	call	WriteString
_loopVal:
	mov		edx, OFFSET prompt_3
	call	WriteString
	mov		eax, UPPER
	call	WriteDec
	mov		edx, OFFSET prompt_4
	call	WriteString
	mov		edx, OFFSET uinput
	mov		ecx, 32
	call	ReadString					;prompt user for integer in range of [1...UPPER]
	mov		edx, OFFSET uinput
	call	Validate				;call validation procedure to validate user entered string
	cmp		eax, 0					
	je		_error			;if eax is 0 then user has entered an invalid input else, mov into unum the user entered integer
	mov		unum, eax

	ret

GetUserData ENDP

;Function Name: Validate
;Description: Gets a string, converts it to an unsigned integer and checks if it is within 1 to UPPER and if it is even
;	an integer at all.
;Recieves: string to be validated to only contain a positive integer
;Returns: eax will be 0 if the string is invalid or will contain the converted valid unsigned integer if valid 
;Pre-Conditions: edx register must contain the number (that is a string) to be validated
;Post-Conditions: the value of eax must be 0 or a converted number upon exit that is within 1 to UPPER
Validate PROC

	call	ParseDecimal32			;convert string into integer, will be 0 if invalid
	cmp		eax, 1	
	jl		_falseRet				;number is not valid if it is less than 1
	cmp		eax, UPPER
	jg		_falseRet				;number is not valid if it is greater than UPPER
	jmp		_trueRet
_falseRet:
	mov	eax, 0				;set EAX to 0 so the result is false on return
	ret
_trueRet:
	ret

Validate ENDP

;Function Name: ShowComposites
;Description: Implements a counted loop between 1 and unum for a incrementing number count_1 in which count_1 is checked by
;	IsComposite to determine if that number should be printed or not. If it should be printed, PrintComposite is called. 
;Recieves: integer between 1 and UPPER
;Returns: none
;Pre-Conditions: user data has been entered and validated
;Post-Conditions: All composites from 1 to unum have been printed to the console
ShowComposites PROC

	mov		eax, unum
	mov		ecx, eax			;set loop counter equal to user specified number
	jmp		_compLoop			;skip the conditional blocks
_twoFill:
	mov		eax, 2
	call	ArrayInsert			;insert two into the primes array
	jmp		_lp
_compLoop:
	cmp		count_1, 1		;increment loop if number is 1		
	je		_lp
	cmp		count_1, 2		;add 2 to primes array if number is 2
	je		_twoFill

	mov		count, ecx			;save the current counter for this loop
	call	IsComposite			;check if count_1 is a composite number
	mov		ecx, count			;restore current counter for this loop
	cmp		eax, 0
	je		_lp					;if eax is 0 then the number is not composite so we skip the print call go to _lp
	call	PrintComposite		;print count_1
	inc		count_1				;increment count_1 just as loop decrements the ECX, we're moving up and ecx is moving down.
	loop	_compLoop
	ret
_lp:							;avoid decrementing ecx in this conditional block so that we only print unum composites
	inc		count_1
	jmp		_compLoop

ShowComposites ENDP

;Function Name: IsComposite
;Description: Divides count_1 by all #'s in primes until the remainder is 0 or all numbers are cycled through, adds prime numbers
;	to the primes array
;Recieves: none
;Returns: eax will be 0 if the number is not a composite number else eax will be 1
;Pre-Conditions: The primes array MUST contain at least 2, count_1 must be greater than 2
;Post-Conditions: prime number is inserted into primes array and declared as not composite or is declared as composite
IsComposite PROC

	mov		ecx, numprimes			;set this counted loop for the number of primes in the primes array
	mov		esi, ptr_prim			;start at the beginning of the primes array
	jmp		_primeloop
_increment:
	add		esi, 4					;move 4 bytes through the primes array
_primeLoop:
	mov		eax, count_1
	cdq
	mov		ebx, [esi]
	div		ebx					;divide count_1 by a prime in the primes array
	cmp		edx, 0
	je		_ret2				;if the remainder is 0, we have a composite (jump) else keep looping until we run out of primes
	loop	_increment
	mov		eax, count_1
	call	ArrayInsert			;insert the prime number into the primes array
	mov		eax, 0
	ret

_ret2:
	mov		eax, 1
	ret

IsComposite ENDP

;Function Name: PrintComposite
;Description: Prints count_1 and organizes the output. 200 numbers are printed per page. 
;Recieves: none
;Returns: none
;Pre-Conditions: count_1 contains an integer
;Post-Conditions: count_1 is printed and is in an appropriate location on the console window
PrintComposite PROC

	mov		eax, count_1
	call	WriteDec				;first print the number
	inc		num_comp				;increment the number of composites currently printed on the current line
	mov		eax, npl
	cmp		num_comp, eax			;if more composites are printed on this line than npl (default: 10) make a new line
	je		_newline
	mov		edx, OFFSET ptab		;tab to keep the numbers aligned
	call	WriteString
	jmp		_return
_newline:
	mov		num_comp, 0				;set number of composites on this line to 0
	call	crlf					;make a new line
	inc		num_line
	cmp		num_line, 20			;if there are more than 20 lines on this page, make a new page else leave this proc
	jg		_newPage
	jmp		_return
_newPage:
	call	crlf
	mov		edx, OFFSET toGO
	call	WriteString				;pause the program with WaitMsg and then clear the screen for a new page
	call	WaitMsg
	call	Clrscr
	mov		num_line, 0				;set the number of lines on new page to 0
_return:
	ret

PrintComposite ENDP

;Function Name: ArrayInsert
;Description: Inserts eax into the array primes
;Recieves: eax
;Returns: none
;Pre-Conditions: eax must contain a prime number
;Post-Conditions: eax has been added to the primes array and the ptr_loc has been incremented by 4 bytes. Number of primes in array incremented.
ArrayInsert PROC

	mov		esi, ptr_loc				;set esi equal to saved location in primes array (which element are we at right now?)
	mov		[esi], eax					;put eax into the empty location
	add		ptr_loc, 4					;move to the next empty location in the primes array
	inc		numprimes					;increment the number of primes in the array
	ret

ArrayInsert ENDP

;Function Name: Farewell
;Description: Says farewell to the user
;Recieves: none
;Returns: none
;Pre-Conditions: strings used are defined as global strings
;Post-Conditions: prints a farewell message to the user
Farewell PROC

	mov		edx, OFFSET outro_1
	call	WriteString
	ret

Farewell ENDP


END main
