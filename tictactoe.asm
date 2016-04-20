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
	vertbord: 	db 179,0
	horbord:	db 196,196,196,196,0
	joint:		db 197,0
	newline:	db 10,0
	xRow1:		db " \/ ",0
	xRow2:		db " /\ ",0
	oRow1:		db 218,196,196,191,0
	oRow2:		db 192,196,196,217,0
	nothing:	db "    ",0
	;0 For nothing | 1 for X | -1 for O
	topleft:	dd 0
	topmid:		dd 0
	topright:	dd 0
	midleft:	dd 0
	midmid:		dd 0
	midright:	dd 0
	bottomleft:	dd 0
	bottommid:	dd 0
	bottomright:	dd 0
	;Misc
	limit:		dd 2			;
	;Escape Sequences
	;clearatr:	db 27,'(0',27,'[m',0;		;Until we need this let's leave it uncommented
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
	;call greenback		;Set background color
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
	call printslottop	;Top most rows
	call printvertbord	;I also seperated the rows and what not to make it easier

	mov EAX,[topmid]
	call printslottop
	call printvertbord

	mov EAX,[topright]
	call printslottop
	call printnewline

	mov EAX,[topleft]
	call printslotbottom
	call printvertbord
	
	mov EAX,[topmid]
	call printslotbottom
	call printvertbord

	mov EAX,[topright]
	call printslotbottom
	call printnewline

	call printhorbord	;1st Horizontal boundary
	call printjoint
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

	printslottop:
	cmp EAX,0
	jg prnsxtop
	jl prnsotop
	jz prnsn
	
	printslotbottom:
	cmp EAX,0
	jg prnsxbottom
	jl prnsobottom
	jz prnsn
	
	prnsxtop:
	push xRow1
	push strfmt
	call printf
	add esp,8
	ret

	prnsotop:
	push oRow1
	push strfmt
	call printf
	add esp,8
	ret

	prnsxbottom:
	push xRow2
	push strfmt
	call printf
	add esp,8
	ret

	prnsobottom:
	push oRow2
	push strfmt
	call printf
	add esp,8
	ret

	prnsn:
	push nothing
	call printf
	add esp,4
	ret

	printvertbord:
	push vertbord
	push strfmt
	call printf
	add esp,8
	ret

	printhorbord:
	push horbord
	push strfmt
	call printf
	add esp,8
	ret

	printjoint:
	push joint
	push strfmt
	call printf
	add esp,8
	ret

	printnewline:
	push newline
	push strfmt
	call printf
	add esp,8
	ret


	pickPlayer:
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

	grnfont:
	push dword gfont
	call printf
	add esp,4
	ret

	whitefont:
	push dword wfont
	call printf
	add esp,4
	ret
Exit:
	ret
