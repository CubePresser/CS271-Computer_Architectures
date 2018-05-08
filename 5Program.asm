TITLE Sorting Random Real Numbers    (5Program.asm)

; Author: Jonathan Jones
; Course / Project ID     CS271            Date: 2/23/2017
; Description: Generates random floating point numbers in the range 100 to 999 and writes them to a file.
;	The program then reads from this file into an array of real numbers. The array is displayed to the screen
;	then is sorted in descending order using a recursive quick sort. The median of the array is displayed and so is the sorted array.

INCLUDE Irvine32.inc

min = 10
max = 200
lo = 100
hi = 999
places = 1000			;How many digits on the right of the radix point? 1000 = .001
BUFFERSIZE = 6			;The buffer size is the total number of digits to the right and left of the radix point. EX: 6 means that there are 6 total digits EX: 123.456 or 1.23456
DIGITSLEFT = 3			;How many digits will be to the left of the radix point?

.data

;filename
fileName	BYTE	"footest.txt",0

;important variables and tools
elements	DWORD	0
array		REAL4	max	DUP(?)
charTab		BYTE	"    ",0			;This was originally ASCII 9 but the numbers were only 1 space apart, for numbers larger than 7 char spaces, change to 9
median		BYTE	10,13,"Median: ",0
uInput		BYTE	32 DUP(0)

;introductory string
intro		BYTE	"Sorting Random Real Numbers",9,9,"Programmed by Jonathan Jones",10,13,10,13
			BYTE	"This program generates random floating point numbers in the range [100 .. 999] and writes",10,13
			BYTE	"them to a file. The program then reads from this file into an array of real numbers.",10,13
			BYTE	"The array is displayed to the screen then is sorted in descending order using a recursive quick sort.",10,13
			BYTE	"The median of the array is displayed and then the sorted array is displayed.",10,13
			;extra credit
			BYTE	"*EC: Display the numbers ordered by column instead of by row.",10,13
			BYTE	"**EC: Use a recursive sorting algorithm (e.g. Merge Sort, Quick Sort, Heap Sort, ect).",10,13,9
			BYTE	"For this program I used the quick sort recursive algorithm, see the sortArray procedure and related for more information (it was hard).",10,13
			BYTE	"***EC: Implement the program using floating-point numbers and the floating-point processor.",10,13,9
			BYTE	"This EC combined with all the other EC credits was quite the challenge. Extra extra credit points?",10,13
			BYTE	"****EC: Generate the numbers into a file, then read the file into the array.",10,13,9
			BYTE	"I had to convert the floating point numbers to strings by multiplying them into integers and then using the",10,13,9
			BYTE	"long lost wsprintf procedure to convert them to strings and write them into the file. This was extrememly challenging and time consuming but so worth it.",10,13,9
			BYTE	"Check the folder that this running in to find the file footest.txt. Remember, the floats are written without their radix points.",10,13,10,13
			BYTE	"There you have it, every single extra credit combined and working together, it was hard but I feel like a champion. Have fun!",10,13,10,13,0

;getData strings
prompt		BYTE	"How many numbers should be generated? [10 .. 200]: ",0
errormsg	BYTE	"Out of Range.",10,13,0

;Printing the unsorted list
title_1		BYTE	10,13,"Unsorted random numbers: ",10,13,0
decPt		BYTE	".",0

;Printing the sorted list
title_2		BYTE	"Sorted numbers (REMEMBER: This is written in column-major not row-major): ",10,13,0


;wsprintf items
fmt				BYTE	"%d",0
numberString	BYTE	32 DUP(0)
strBuffer		BYTE	32 DUP(0)

.code
main PROC

	call	Randomize				;get random seed

	push	OFFSET intro			;intro
	call	introduction

	push	OFFSET uInput
	push	OFFSET errormsg
	push	OFFSET prompt
	push	OFFSET elements			;get all the data and store floats into a file "footest.txt"
	push	OFFSET numberString
	push	OFFSET fmt
	push	OFFSET fileName
	call	getData

	push	OFFSET strBuffer
	push	OFFSET array
	push	elements				;fill the array
	push	OFFSET fileName
	call	fillArray

	push	OFFSET fmt
	push	OFFSET numberString
	push	OFFSET charTab
	push	OFFSET title_1
	push	elements			;print the unsorted array of random floats to the screen
	push	OFFSET array
	call	displayList
	call	crlf

	push	elements
	push	OFFSET array
	call	sortList			;sort in descending order

	push	OFFSET fmt
	push	OFFSET numberString
	push	OFFSET median
	push	elements
	push	OFFSET	array			;print the median to the screen
	call	displayMedian
	call	crlf
	call	crlf

	push	OFFSET fmt
	push	OFFSET numberString
	push	OFFSET charTab
	push	OFFSET title_2
	push	elements
	push	OFFSET array			;print the sorted array to the screen
	call	displayList
	call	crlf


	exit	; exit to operating system
main ENDP

;Function Name: introduction
;Description: introduces the program to the user
;Recieves: OFFSET of introduction string
;Returns: prints introduction to the screen
;Pre-Conditions: All conditions in "Recieves:" must be met
;Post-Conditions: Must have printed out introduction to the screen.
introduction PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp+8]
	call	WriteString
	pop		ebp
	ret		4
introduction ENDP

;Function Name: getData
;Description: Creates a file called "footest.txt", uses randomFloat to generate random floating point numbers and then uses WriteRealToFile to write the floating points to "footest.txt"
;Recieves: OFFSET of a filename, format string "%d" for wsprintf, OFFSET of numberString, OFFSET of elements (to record the length of the array will be), dialog offsets like (errormsg, prompt), empty string to hold user input
;Returns: file: "footest.txt" that contains a set of floating point numbers in string format, number of elements that array will have
;Pre-Conditions: all conditions in "Recieves:" MUST be met.
;Post-Conditions: file called "footest.txt" is created and contains a set of random floating point numbers. Elements has the number of elements that the array will contain.
getData PROC

	fileHandle	EQU	DWORD	PTR [ebp-4]
	randFloat	EQU	REAL4	PTR [ebp-8]			;name locals so they are easy to read and keep track of
	count		EQU	DWORD	PTR	[ebp-12]

	push	ebp
	mov		ebp, esp
	sub		esp, 12		;make room for local variables

	mov		edx, [ebp+8]		;mov	edx, OFFSET fileName

	call	CreateOutputFile	;create a file with fileName ("footest.txt")
	mov		fileHandle, eax		;mov		fileHandle, eax

	call	getUserData			;get the number of elements that the array will contain in ecx

;for loop to generate ecx number of random floating points into the file ("footest.txt")
_l1:
	mov		edi, [ebp+20]		;mov	edi, OFFSET elements
	mov		eax, 1
	add		[edi], eax			;increment number of elements by 1
	mov		count, ecx			;store ecx
	call	randomFloat			;generate a random float into ST(0)
	fstp	randFloat			;pop ST(0) into randFloat

	call	WriteRealToFile		;write randFloat to the file

	INVOKE	SetFilePointer, fileHandle, 1, 0, FILE_CURRENT ;Tells the file pointer to move one byte forward effectively creating a space between the numbers
	
	mov		ecx, count			;restore ecx
	loop	_l1

	mov		eax, fileHandle
	call	CloseFile			;close the file
	mov		eax, fileHandle

	mov		esp, ebp
	pop		ebp					;clear the stack frame and locals
	ret		24
getData ENDP

;Function Name: getUserData
;Description: Gets user input as a string, validates that it is within the range [min .. max] and sets ecx equal to the number of floats that should be created for the array in this program.
;Recieves: OFFSETS of strings to print out, errormsg and prompt
;Returns: ecx is the number of elements for the array
;Pre-Conditions: conditions of "Receives:" must be met.
;Post-Conditions: ecx contains the number of floats to be generated for the array
getUserData PROC

	push	ebp
	mov		ebp, esp

	jmp		_valid
_error:
	mov		edx, [ebp+48]		;mov		edx, OFFSET errormsg
	call	WriteString
_valid:

	mov		edx, [ebp+44]		;mov		edx, OFFSET prompt
	call	WriteString

	mov		edx, [ebp+52]		;mov		edx, OFFSET uInput
	mov		ecx, 32						;get a range from user in a string
	call	ReadString

	call	ParseDecimal32			;convert the string to an unsigned integer
	cmp		eax, min
	jl		_error					;if the string is invalid or the number is out of range, print error msg
	cmp		eax, max
	jg		_error

	mov		ecx, eax			;set ecx equal to the number provided by the user

	pop		ebp				;clear stack frame

	ret
getUserData ENDP

;Function Name: WriteRealToFile
;Description: Converts a REAL4 number to a string and writes it to the file "footest.txt".
;Recieves: a REAL4 at [ebp+12]. Valid file handle at [ebp+16]
;Returns: none
;Pre-Conditions: There must be a REAL4 at [ebp+12]. File must be open and valid handle stored at [ebp+16]
;Post-Conditions: REAL4 number must have been converted to a string and written to the file "footest.txt"
WriteRealToFile PROC

	locHandle	EQU	DWORD	PTR [ebp+16]	;locHandle = fileHandle
	locReal		EQU REAL4	PTR [ebp+12]	;locReal = randFloat
	locInt		EQU	SDWORD	PTR [ebp-4]
	placeDiv	EQU	DWORD	PTR	[ebp-8]						;name locals so they are easy to read and keep track of

	push	ebp
	mov		ebp, esp			;initialize stack frame
	sub		esp, 8				;make room for locals on the stack frame

	mov		eax, places
	mov		placeDiv, eax			;set the local placeDiv equal to the magnitiude of the fractional places in the floats (i.e. .001 = 1000)

	finit
	fld		locReal				;load the REAL4 located at [ebp+12] to the FPU stack
	fild	placeDiv
	fmul						;multiply the REAL4 by the magnitude of the number of fractional places to convert it into an integer
	fistp	locInt				;pop ST(0) and store as an integer in locInt

	push	locInt		;push	testAfter             ; Argument for format string
	push	[ebp+32]		;push	OFFSET fmt             ; Pointer to format string ("%d")
	push	[ebp+36]		;push	OFFSET numberString   ; Pointer to buffer for output
    call	wsprintf               ;old windows function that converts an integer to a string
	mov		ecx, BUFFERSIZE			;size of string is BUFFERSIZE
    add		esp, (3*4)              ;Adjust the stack.

    mov		eax, locHandle
	mov		edx, [ebp+36]		;mov edx, OFFSET numberString
    call	WriteToFile			;Write to the file the string buffer numberString

	mov		esp, ebp		;clear stack frame and locals
	pop		ebp

	ret

WriteRealToFile	ENDP

;Function Name: randomFloat
;Description: Generates random integers for the left and right of the radix point of a float then appends them to make a float
;Recieves: none (user input within the procedure)
;Returns: floating point number in ST(0)
;Pre-Conditions: none
;Post-Conditions: Random float is generated and placed in ST(0)
randomFloat PROC

	leftBuffer		EQU DWORD PTR [ebp-4]
	rightBuffer     EQU DWORD PTR [ebp-8]			;name locals so they are easy to read and keep track of
	placeDiv		EQU	DWORD PTR [ebp-12]

	push	ebp
	mov		ebp, esp			;initialize stack frame
	sub		esp, 12

	mov		eax, places
	mov		placeDiv, eax		;set the local placeDiv equal to the magnitiude of the fractional places in the floats (i.e. .001 = 1000)

	mov		eax, hi-lo			;subtract from the high limit the low limit since random range calculates from 0 to n-1
	add		eax, 1				;make sure we get every number in [lo .. hi]
	call	RandomRange
	add		eax, lo
	mov		leftBuffer, eax		;place this number into the left buffer (left of the radix point)

	mov		eax, places
	call	RandomRange			;generate random number from 0 to places. This will be right of the radix point.
	mov		rightBuffer, eax

	;convert buffers to floats and append them
	finit
	fild	rightBuffer			;divide the right buffer by the number of places it should be (i.e. (123/1000 = 0.123)
	fild	placeDiv
	fdiv
	fild	leftBuffer			;append the left and the right buffer
	fadd

	mov		esp, ebp		;clear stack frame and locals
	pop		ebp
	ret
randomFloat ENDP

;Function Name: fillArray 
;Description: Reads from the file "footest.txt" a series of BUFFERSIZE long strings and converts them into floats based on information from constant: places (basically, where is the radix point?)
;Recieves: fileName, array(reference), number of elements
;Returns: Array filled with floats.
;Pre-Conditions: Array must be of size max and be REAL4. fileName must be valid. File must be closed.
;Post-Conditions: File must be closed. Array is filled with floats.
fillArray PROC

	fileHandle	EQU DWORD PTR [ebp-4]
	count		EQU	DWORD PTR [ebp-8]
	intBuffer	EQU DWORD PTR [ebp-12]			;name locals so they are easy to read and keep track of
	placeDiv	EQU	DWORD PTR [ebp-16]
	curElem		EQU	DWORD PTR [ebp-20]

	push	ebp			;initialize stack frame
	mov		ebp, esp
	sub		esp, 20		;make room for local vars

	mov		edx, [ebp+8]		;mov	edx, OFFSET filename
	call	OpenInputFile		;open the file for reading
	mov		fileHandle, eax		;move the file handle into fileHandle

	mov		eax, 0
	mov		curElem, eax		;set current element equal to 0

	mov		eax, places			
	mov		placeDiv, eax		;set the local placeDiv equal to the magnitiude of the fractional places in the floats (i.e. .001 = 1000)
	mov		ecx, [ebp+12]		;set counter equal to number of elements in file

_l2:
	mov		count, ecx			;save ecx

	;tell ReadFromFile which file to read from, how many bytes and where to store it (strBuffer)
	mov		ecx, BUFFERSIZE		
	mov		eax, fileHandle
	mov		edx, [ebp+20]		;mov	edx, OFFSET strBuffer
	call	ReadFromFile

	;convert string read into an integer
	mov		edx, [ebp+20]		;mov	edx, OFFSET strBuffer
	mov		ecx, BUFFERSIZE
	call	ParseDecimal32
	mov		intBuffer, eax		;store into intBuffer the integer recieved from ParseDecimal32

	mov		esi, [ebp+16]		;mov	esi, OFFSET array

	finit
	fild	intBuffer			;convert integer to float
	frndint						;round just in case (making things as clean as possible)
	fidiv	placeDiv			;divide the float by the magnitude of the number of fractional places it should have (.001 = 1000)

	mov		ebx, curElem		;set ebx equal to the current index to insert in

	fstp	REAL4 PTR [esi+ebx]		;pop the top of the FPU stack into the array at curElem

	add		curElem, 4			;increment curElem by 4 bytes			

	INVOKE	SetFilePointer, fileHandle, 1, 0, FILE_CURRENT		;Increment the file pointer by 1, jumping the space between numbers in the file

	mov		ecx, count		;restore count

	loop	_l2

	mov		eax, fileHandle			;close the file
	call	CloseFile

	mov		esp, ebp			;clear stack frame and locals
	pop		ebp
	ret		16
fillArray ENDP

;Function Name: sortList 
;Description: Sets up the stack frame before a recursive sorting function quickSort is called
;Recieves: array(reference), Length of array(value)
;Returns: none (no arguments are changed)
;Pre-Conditions: Array must be of type REAL4. Array must not be empty.
;Post-Conditions: List is sorted in descending order.
sortList PROC

	push	ebp				;initialize stack frame
	mov		ebp, esp
    
	mov		esi, [ebp+8]    ;mov	esi, OFFSET array
	mov		eax, [ebp+12]	;mov	eax, elements

	dec		eax				;decrement eax by 1 so that the high index when computed isn't outside the array			 
	mov		ebx, 4
	mul		ebx				;multiply (length of array -1) by 4 bytes

	mov		ebx, eax		;Set ebx equal to the high index
	mov		eax, 0			;Set the low index equal to 0
	call	quickSort

	pop		ebp				;restore the stack

	ret		8
sortList ENDP

;Function Name: quickSort
;Description: A recursive sorting procedure using the quickSort algorithm. Uses a pivot to sort the array using the "divide and conquer" method of sorting
;Recieves: esi = OFFSET array, eax = 0, ebx = high index ((length of array -1)*4)
;Returns: none
;Pre-Conditions: all conditions in "Recieves:" must be met. Array must be REAL4. Array must not be empty.
;Post-Conditions: Array is sorted in descending order.
quickSort PROC

	;if low index is greater than the high index, exit the procedure
	cmp		eax, ebx
	jge		_procEnd

	push	eax			;push the low index to the stack to save it
	push	ebx			;push the high index to the stack to save it
	add		ebx, 4		;increment ebx by 4 bytes so that when j loop runs it doesn't miss the last index

    add		esi, eax
	mov		edi, esi	;set edi equal to the address of the pivot (low index to start)
	sub		esi, eax
    
_partition:			;beginning of partition segment, I wanted to make it another procedure but the stack was getting very complicated
	
	;find the number on the left side to swap
	_findLeft:

		add		eax, 4		;shift the low index by 4 bytes (now a tracker of the current location)
		
		;exit the findLeft loop if the current index location # is greater than the high index (i.e. reverse swap, bad)
		cmp		eax, ebx
		jge		_foundLeft
            
		;fpu comparison between the pivot and current index location
		finit
		fld		REAL4 PTR [esi+eax]			;fld	array[currentIndex]
		fld		REAL4 PTR [edi]				;fld	array[pivot]
		fcom								;fpu comparison (sets fpu flags)
		push	eax		;save eax
		fnstsw	ax		;send fpu status flags to the eflags register
		sahf
		pop		eax		;restore eax
		finit			;clear fpu stack

		;is the pivot greater than the current index?
		jae	_foundLeft
		jmp _findLeft		;not greater

	_foundLeft:
	
	;find the number on the right side to swap
	_findRight:
	
		sub		ebx, 4		;decrement the high index by 4
		
		;fpu comparision between the pivot and current index location
		finit
		fld		REAL4 PTR [esi+ebx]			;fld	array[currentIndex]
		fld		REAL4 PTR [edi]				;fld	array[pivot]
		fcom								;fpu comparison (sets fpu flags
		push	eax		;save eax
		fnstsw	ax		;send fpu status flags to the eflags register
		sahf
		pop		eax		;restore eax
		finit			;clear fpu stack

		;is the pivot less than the current index?
		jbe	_foundRight
		jmp _findRight		;not less
		
	_foundRight:
        
        ;check if left number is at higher index than right number. Exit partition if true (reverse swap, bad)
		cmp		eax, ebx
		jge		_partitionEnd
		
		;swap right index with left index in fpu
		call	exchangeElements

		jmp _partition		;next partition
		
_partitionEnd:
    
	pop		edi		;pop high into edi
	pop		eax		;pop low into eax
    
    ;check if pivot is equal to current high index
	cmp		eax, ebx

	je _noSwap

	;Swap pivot and current high index
	call	exchangeElements

_noSwap:

	push	edi		;save high index again
	push	ebx		;save current location of pivot(after movement through right loop and such)
    
	sub		ebx, 4		;decrement by 4 bytes like before

	;quickSort(array, low index, p-1)
    call quickSort

	pop		eax			;set eax (low current) to the pivot
	add		eax, 4		;increment by 4 bytes like before

	pop		ebx			;ebx is now high index
	
	;quickSort(array, p+1, high index)
	call quickSort
    
_procEnd:

	ret

quickSort ENDP

;Function Name: exchangeElements 
;Description: Swaps two array index locations via the FPU
;Recieves: array[reference], left index[value], right index[value]
;Returns: none
;Pre-Conditions: esi contains the array offset, eax contains the left index, ebx contains the right index. Array must be REAL4. Array must not be empty. 
;Post-Conditions: array indexes are swaped
exchangeElements PROC

	finit
	fld		REAL4 PTR [esi+eax]			;load left index
	fld		REAL4 PTR [esi+ebx]			;load right index
	fstp	REAL4 PTR [esi+eax]			;pop right index into left index
	fstp	REAL4 PTR [esi+ebx]			;pop left index into right index

	ret
exchangeElements ENDP

;Function Name: displayMedian
;Description: Determines if the length of the array given is odd or even then computes the median and prints to the screen.
;Recieves: array[reference], length of array[value], string format, string buffer
;Returns: none (no changes made in arguments)
;Pre-Conditions: All conditions in "Recieves:" must be met. Array must not be empty. Must be an array of REAL4.
;Post-Conditions: Median is displayed to the screen.
displayMedian PROC

	count		EQU	DWORD PTR [ebp-4]
	intBuffer	EQU DWORD PTR [ebp-8]
	placeDiv	EQU DWORD PTR [ebp-12]

	push	ebp					;initialize stack frame
	mov		ebp, esp
	sub		esp, 4			
	mov		esi, [ebp+8]		;mov	esi, OFFSET array

	mov		eax, places
	mov		placeDiv, eax

	mov		edx, [ebp+16]		;mov	edx, OFFSET median
	call	WriteString			;print "Median: "

	;Odd or even?
	mov		eax, [ebp+12]	;mov	eax, elements
	mov		ebx, 2
	cdq
	div		ebx				;quotient is in eax, remainder is in edx
	cmp		edx, 0
	je		_even			;if the remainder is 0 then there is an even number of elements

;if the number of elements is odd, find the center
_odd:
	inc		eax			;quotient plus 1 to get the center
	mov		ebx, 4
	mul		ebx			;multiply by 4 bytes
	sub		eax, 4
	finit
	fld		REAL4 PTR [esi+eax]		;pull the median from the array
	jmp		_printFloat

;if the number of elements is even, find the two numbers in the center and get their average
_even:
	mov		ebx, 4
	mul		ebx			;multiply quotient+1 by 4 bytes
	finit
	fld		REAL4 PTR [esi+eax]		;load the quotient+1
	sub		eax, 4
	fld		REAL4 PTR [esi+eax]		;load the quotient
	fadd
	fld1
	fld1						;add half the denominator to the numerator and divide by 2 (just in case, works like a charm)
	fadd
	fdiv

_printFloat:

	fild	placeDiv
	fmul
	frndint
	fistp	intBuffer
	push	intBuffer		;push	testAfter             ; Argument for format string
	push	[ebp+24]		;push	OFFSET fmt             ; Pointer to format string ("%d")
	push	[ebp+20]		;push	OFFSET numberString   ; Pointer to buffer for output
    call	wsprintf               ;old windows function that converts an integer to a string
	mov		ecx, BUFFERSIZE			;size of string is BUFFERSIZE
    add		esp, (3*4)              ;Adjust the stack.
	push	ecx
	mov		ecx, BUFFERSIZE
	push	esi						;save array offset
	mov		esi, [ebp+20]			;mov		esi, OFFSET numberString
	mov		count, 0

_printLoop:
	mov		ebx, count				;number of bytes printed to screen
	mov		al, [esi+ebx]
	call	WriteChar				;print 1 byte of the int (floats) string
	inc		count					;increment number of bytes printed counter
	mov		eax, DIGITSLEFT			;set eax equal to the number of digits that are supposed to be to the left of the radix point
	cmp		count, eax
	jne		_noRadix				;if the number of bytes printed is equal to that of the number of digits to the left of the radix point, print the radix point
	mov		al, '.'
	call	WriteChar
_noRadix:
	loop	_printLoop
	pop		esi
	pop		ecx

_finish:

	mov		esp, ebp			;clear stack frame
	pop		ebp
	ret		20
displayMedian ENDP

;Function Name: displayList
;Description: Prints out the contents of the REAL4 array passed to it in column-major order.
;Recieves: array(reference), lengthOfArray(value), title(reference), string format, string buffer
;Returns: prints title and contents of array to screen.
;Pre-Conditions: Array must be of type REAL4. Array must not be empty. Conditions of "Recieves:" is met. Constants used are calculated correctly.
;Post-Conditions: Title and array must be printed to screen.
displayList PROC
	
	numPrinted	EQU DWORD PTR [ebp-4]
	colPos		EQU DWORD PTR [ebp-8]			;name locals
	curPos		EQU DWORD PTR [ebp-12]
	
	placeDiv	EQU DWORD PTR [ebp-16]
	intBuffer	EQU DWORD PTR [ebp-20]			;for converting exponential floating points to readable strings
	count		EQU DWORD PTR [ebp-24]
	
	push	ebp				;initialize stack frame
	mov		ebp, esp

	sub		esp, 24			;make room for locals

	mov		eax, places
	mov		placeDiv, eax

	mov		edx, [ebp+16]		;mov	edx, OFFSET title
	call	WriteString

	mov		esi, [ebp+8]		;mov	esi, OFFSET array
	mov		colPos, 1			;set initial column position equal to 1 (first column)
	mov		curPos, 0			;set current position equal to index 0 (beginning of array)
	mov		numPrinted, 0

_loop1:
	mov		eax, colPos
	cmp		eax, 10
	jg		_lp1End				;jump if the column index is greater than 10 (no more columns)

_loop2:

	mov		eax, 4
	mov		ebx, curPos			;move into eax the current position multiplied by 4 bytes
	mul		ebx

	finit
	fld		REAL4 PTR [esi+eax]
	fild	placeDiv
	fmul						;convert to an integer for printing
	frndint
	fistp	intBuffer
	push	intBuffer		;push	testAfter             ; Argument for format string
	push	[ebp+28]		;push	OFFSET fmt             ; Pointer to format string ("%d")
	push	[ebp+24]		;push	OFFSET numberString   ; Pointer to buffer for output
    call	wsprintf               ;old windows function that converts an integer to a string
	mov		ecx, BUFFERSIZE			;size of string is BUFFERSIZE
    add		esp, (3*4)              ;Adjust the stack.
	push	ecx
	mov		ecx, BUFFERSIZE
	push	esi					;save array location
	mov		esi, [ebp+24]
	mov		count, 0			;set count of bytes printed to 0

;move through the string of ints (the float) one character at a time
_printLoop:
	mov		ebx, count			;keep track of how many bytes have been printed
	mov		al, [esi+ebx]			;print character
	call	WriteChar
	inc		count				;increment number of bytes printed by 1
	mov		eax, DIGITSLEFT			;Number of digits to the left of the radix point		
	cmp		count, eax				;if count is equal to the number of digits to the left of the radix point, print the radix point
	jne		_noRadix
	mov		al, '.'
	call	WriteChar
_noRadix:
	loop	_printLoop
	pop		esi					;restore array offset and the ecx before printing
	pop		ecx
	;
	inc		numPrinted				;add 1 to the number of items printed
	mov		eax, 10
	cmp		numPrinted, eax			;if the number of items printed to the screen is equal to 10, new line
	jl		_NoNewLine

_newLine:

	call	crlf					;print a new line
	mov		numPrinted, 0			;reset numPrinted to 0
	jmp		_noTab
_NoNewLine:

	mov		edx, [ebp+20]			;mov		edx, OFFSET charTab
	call	WriteString				;tab
_noTab:

	add		curPos, 10			;shift the current position to the next row at the same column

	mov		eax, [ebp+12]		;mov		eax, elements
	sub		eax, 1
	cmp		curpos, eax			;is the current position less than or equal to the number of elements -1?

	jle		_loop2				;repeat printing through the column 

	mov		eax, colPos
	mov		curPos, eax			;set the current position equal to the column position
	inc		colPos				;move over one column

	jmp		_loop1

_lp1End:

	mov		esp, ebp			;clear stack frame and locals
	pop		ebp
	ret		20

displayList ENDP

END main
