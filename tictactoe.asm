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
	r1:		db "    ", 179, "    ",179,"    ",10
	r2:		db "    ", 179, "    ",179,"    ",10
	r3:		db 196,196,196,196,197,196,196,196,196,197,196,196,196,196,10
	r4:		db "    ", 179, "    ",179,"    ",10
	r5:		db "    ", 179, "    ",179,"    ",10
	r6:		db 196,196,196,196,197,196,196,196,196,197,196,196,196,196,10
	r7:		db "    ", 179, "    ",179,"    ",10
	finr:		db "    ", 179, "    ",179,"    ",10
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
	call whitefont
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

	drawBoard:		;Draw TicTacToe grid
	push dword finr
	push dword r7
	push dword r6
	push dword r5
	push dword r4
	push dword r3
	push dword r2
	push dword r1
	push dword r1
	call printf
	add esp,36
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
