;Authors: Garrett Walker - David Hudson
;Date Started: April/4/2016
;To Compile
;nasm -f elf32 tictactoe.asm && gcc -m32 -o tictactoe tictactoe.o

;~~~~C Functions~~~~;
extern printf           ;Printing to the screen
extern scanf            ;Receiving input
extern srand            ;Seed random
extern rand             ;Random
extern time             ;For srand
global main
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SECTION .data
	;Prompts
	cpuname:	db "Hal"			
	greetings:	db "Hello Human.", 10, "My name is Hal. What is yours?: ",0
	shittalk:	db "Hello, %s, prepare to lose!", 10, 0
	;Formats
	strfmt:		db '%s',0
	intfmt:		db '%d',0
	;TicTacToe Grid
	vertbord: 	db 179,0			;This is our vertical border |
	horbord:	db 196,196,196,196,0		;This is our horizontal border --
	joint:		db 197,0			;A Cross section for the two borders
	newline:	db 10,0				;Makes life easier for printing the grid
	xRow1:		db " \/ ",0			;Top row of X
	xRow2:		db " /\ ",0			;Bottom row of X
	oRow1:		db 218,196,196,191,0		;Top row of O
	oRow2:		db 192,196,196,217,0		;Bottom row of O
	nothing:	db "    ",0			;Incase nothing on that slot of board
	;0 For nothing | 1 for X | -1 for O
	topleft:	dd 0				;Our player(s) and CPU should change these values
	topmid:		dd 0
	topright:	dd 0
	midleft:	dd 0
	midmid:		dd 0
	midright:	dd 0
	bottomleft:	dd 0
	bottommid:	dd 0
	bottomright:	dd 0
	;Misc
	limit:		dd 2				;We mod random with this to pick who goes first
	;Escape Sequences
	clearscr:	db 27,'[H',27,'[2J',0;		;PrintF this to clear the screen between draws
	;Background Colors
	greenbackgrnd:	db 27,'[42m',0			;Change what were drawing to have a green background
	redbackgrnd:	db 27,'[41m',0			;Change what were drawing to have a red background
	cyanbackgrnd:	db 27,'[45m',0			;Change what were drawing to have a cyan background
	;Font Colors
	gfont:		db 27,'[32m',0
	rfont:		db 27,'[31m',0
	wfont:		db 27,'[37m',0
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SECTION .bss
	name		resb	20			;Reserve memory for user's name
	terminal	resb	9 			;One byte for each board position, (0=empty,1=Human,2=CPU)
	random  	resb	4			;Memory for our random value, who goes first
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SECTION .text

main:
	call clearScreen	;Clear screen
	call grnfont
	push dword greetings	;Push our message
	call printf		;Print it
	add esp,4
	
	push name		;Let's get our users name
	push strfmt		;Push the format to extract a string
	call scanf		;Call the function
	add esp,8		;Move the stack pointer

	push name		;Push user's name
	push dword shittalk	;Let's shittalk
	call printf		;Print to screen
	add esp,8		;Move stack pointer
	
	call pickPlayer		;Let's pick who goes first

	call drawBoard
	jmp Exit		;Exit our program
	
	clearScreen:		;Will clear the screen of everything
	push dword clearscr
	call printf
	add esp,4
	ret

	drawBoard:		;PrintSlotTop and PrintSlopBottom are printing the top and bottom halfs of each slot based on the number in the given slot
	mov EAX,[topleft]	;Print each row one after another
	call printslottop	;Top Left Slot
	call printvertbord	

	mov EAX,[topmid]	;Top Middle Slot
	call printslottop	;Prints top half of X,O,or nothing
	call printvertbord

	mov EAX,[topright]	;Top Right Slot
	call printslottop	;
	call printnewline	;This is the end so newline

	mov EAX,[topleft]	;Top Left Slot - Bottom
	call printslotbottom	;Prints bottom half of X,O,or nothing
	call printvertbord
	
	mov EAX,[topmid]	;Top Middle Slot
	call printslotbottom	;Prints the bottom half of X,o,or nothing
	call printvertbord

	mov EAX,[topright]
	call printslotbottom
	call printnewline

	call printhorbord	;1st Horizontal boundary
	call printjoint		;Cross section
	call printhorbord
	call printjoint
	call printhorbord
	call printnewline
	
	mov EAX,[midleft]	;Middle Rows
	call printslottop
	call printvertbord

	mov EAX,[midmid]
	call printslottop
	call printvertbord

	mov EAX,[midright]
	call printslottop
	call printnewline
	
	mov EAX,[midleft]
	call printslotbottom
	call printvertbord

	mov EAX,[midmid]
	call printslotbottom
	call printvertbord

	mov EAX,[midright]
	call printslotbottom
	call printnewline

	call printhorbord	;2nd Horizontal boundary
	call printjoint
	call printhorbord
	call printjoint
	call printhorbord
	call printnewline
	
	mov EAX,[bottomleft]
	call printslottop
	call printvertbord

	mov EAX,[bottommid]
	call printslottop
	call printvertbord

	mov EAX,[bottomright]
	call printslottop
	call printnewline

	mov EAX,[bottomleft]
	call printslotbottom
	call printvertbord

	mov EAX,[bottommid]
	call printslotbottom
	call printvertbord

	mov EAX,[bottomright]
	call printslotbottom
	call printnewline
	ret

	printslottop:		;Prints the top half of an X,O,or nothing depending on the value in EAX(-1(O),0( ),1(X))
	cmp EAX,0
	jg prnsxtop
	jl prnsotop
	jz prnsn
	
	printslotbottom:	;Prints the bottom half of an X,O,or nothing depending on the value in EAX(-1(O),0( ),1(X))
	cmp EAX,0
	jg prnsxbottom
	jl prnsobottom
	jz prnsn
	
	prnsxtop:		;Prints top half of X
	push xRow1
	push strfmt
	call printf
	add esp,8
	ret

	prnsotop:		;Prints the top half of O
	push oRow1
	push strfmt
	call printf
	add esp,8
	ret

	prnsxbottom:		;Prints the bottom half of X
	push xRow2
	push strfmt
	call printf
	add esp,8
	ret

	prnsobottom:		;Prints the bottom half of O
	push oRow2
	push strfmt
	call printf
	add esp,8
	ret

	prnsn:			;Prints a whole lotta nothing
	push nothing
	call printf
	add esp,4
	ret

	printvertbord:		;Prints a vertical border (|)
	push vertbord
	push strfmt
	call printf
	add esp,8
	ret

	printhorbord:		;Prints a horizontal border (----)
	push horbord
	push strfmt
	call printf
	add esp,8
	ret

	printjoint:		;Prints a cross section (+)
	push joint
	push strfmt
	call printf
	add esp,8
	ret

	printnewline:		;Prints newline char
	push newline
	push strfmt
	call printf
	add esp,8
	ret


	pickPlayer:		;Randomly picks who will go first(Value is stored in random)
	mov dword EAX,[random]
	sub EAX,[random]
	mov [random],EAX
        
	push 0                  ;Push 0 for default time
        call time               ;Seed random and generate number
        add esp,4               ;Move stack pointer
	
	push EAX                ;Push the time it returned
        call srand              ;Now lets seed our random func with it
        add esp,4               ;Move stack pointer
        
	push EAX                ;Push so random will store in EAX
        call rand               ;Let's get our random value
        add esp,4               ;Move stack pointer
        
	mov EBX,[limit]         ;Move 2 to EBX
        xor EDX,EDX             ;Clear out EDX
        div EBX                 ;Divide EAX by EBX remainder stored in EDX
	mov [random],EDX	;Store random result in random (0 = cpu, 1 = human)
	ret

	redback:		;Changes the cursor background to red
	push dword redbackgrnd
	call printf
	add esp,4
	ret
	
	greenback:		;Changes the cursor background to green
	push dword greenbackgrnd
	call printf
	add esp,4
	ret

	grnfont:		;Changes font to green
	push dword gfont
	call printf
	add esp,4
	ret

	whitefont:		;Changes font to white
	push dword wfont
	call printf
	add esp,4
	ret
Exit:
	ret
