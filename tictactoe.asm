;Authors: Garrett Walker - David Hudson
;Date Started: April/4/2016
;To Compile
;nasm -f elf32 tictactoe.asm && gcc -m32 -o tictactoe tictactoe.o
;Or use the make file - That is easier

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
	cpuname:	db "Hal",0			
	greetings:	db "Hello Human.", 10, "My name is Hal. What is yours?: ",0
	shittalk:	db "Hello, %s, prepare to lose!", 10, 0
	playerwins:	db "%s wins the game!",10,0
	halwins:	db "HAHA!",10,"You lose, %s!",10,0
	menu:		db "Player vs Hal(1) or Player vs Player(2)",0
	makemove:	db "Make a move sucka'?", 10, 0
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
	topleft:	times 4 db 0			;Our player(s) and CPU should change these values
	topmid:		times 4 db 0
	topright:	times 4 db 0
	midleft:	times 4 db 0
	midmid:		times 4 db 0
	midright:	times 4 db 0
	bottomleft:	times 4 db 0
	bottommid:	times 4 db 0
	bottomright:	times 4 db 0
	;Misc
	limit:		dd 2				;We mod random with this to pick who goes first
	easymodelimit	dd 10
	bef:		db "Before",0
	aft:		db "After",0
	currentPlayer	times 4 db 0
	currentMove	times 4 db 0
	clearReg	times 4 db 0			;Let's use this to clear out EAX between operations
	playerWins	times 4 db 0
	HalWin		times 4 db 0
	return		times 4 db 0			;At this point im abusing the times stuff, but so far it has solved some bugs for me
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
	random  	resw	1			;Memory for our random value, who goes first
	;currentPlayer	resw	1			;Who currently goes first
	;currentMove	resw	1			;Players current move
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SECTION .text

main:
	;--------------
	;Let's try initializing data
	xor EAX,EAX		;Neat way of getting 0
	mov [random],EAX
	mov [currentPlayer],EAX
	mov [currentMove],EAX
	;Dunno if it works, will delete if it doesnt

	call clearScreen	;Clear screen
	call grnfont
	push dword greetings	;Push our message
	call printf		;Print it
	add esp,4
	
	push name		;Let's get our users name
	push strfmt		;Push the format to extract a string
	call scanf		;Call the function
	add esp,8		;Move the stack pointer

	call clearScreen

	push name		;Push user's name
	push dword shittalk	;Let's shittalk
	call printf		;Print to screen
	add esp,8		;Move stack pointer
	
	call pickPlayer		;Let's pick who goes first
	call loopGame		;Let's play until someone wins

	jmp Exit		;Exit our program
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	
	loopGame:
	loopGameLoop:		;Loop until someone wins
		call playTurn	;Play current players turn
		call drawBoard	;Draw updated board
		call checkWin	;Check if someone won, if not then keep looping
		cmp EAX,0
		jz loopGameLoop
	ret
	
	checkWin:	;So neat way to check if they've won
			;We know that all player slot values are 1 and 
			;all Hal slot values are -1.
			;There are only 8 patterns to win tictactoe
			;So by adding those patterns up, a Player win should be 3
			;And a Hal win should be -3
	
	;Row 1
	mov EAX,[topleft]
	add EAX,[topmid]
	add EAX,[topright]
	call chkPlayerWin
	cmp EAX,0		;Check the result of our chkPlayerWin
	jnz checkWinExit
	;Row 2
	mov EAX,[midleft]
	add EAX,[midmid]
	add EAX,[midright]
	call chkPlayerWin
	cmp EAX,0		;Check the result of our chkPlayerWin
	jnz checkWinExit
	;Row 3
	mov EAX,[bottomleft]
	add EAX,[bottommid]
	add EAX,[bottomright]
	call chkPlayerWin
	cmp EAX,0		;Check the result of our chkPlayerWin
	jnz checkWinExit
	;Col 1
	mov EAX,[topleft]
	add EAX,[midleft]
	add EAX,[bottomleft]
	call chkPlayerWin
	cmp EAX,0		;Check the result of our chkPlayerWin
	jnz checkWinExit
	;Col 2
	mov EAX,[topmid]
	add EAX,[midmid]
	add EAX,[bottommid]
	call chkPlayerWin
	cmp EAX,0		;Check the result of our chkPlayerWin
	jnz checkWinExit
	;Col 3
	mov EAX,[topright]
	add EAX,[midright]
	add EAX,[bottomright]
	call chkPlayerWin
	cmp EAX,0		;Check the result of our chkPlayerWin
	jnz checkWinExit
	;TLtoBR Diag
	mov EAX,[topleft]
	add EAX,[midmid]
	add EAX,[bottomright]
	call chkPlayerWin
	cmp EAX,0		;Check the result of our chkPlayerWin
	jnz checkWinExit
	;BLtoTR Diag
	mov EAX,[bottomleft]
	add EAX,[midmid]
	add EAX,[topright]
	call chkPlayerWin

	checkWinExit:
	ret

	chkPlayerWin:
	cmp EAX,3
	jz playerWon		;Check if our math worked and player won
	chkHalWin:
	cmp EAX,-3
	jz HalWon		;Check if math worked and Hal won
	mov EAX,0		;Noone won so put 0 in EAX so our earlier loop knows
	ret

	playerWon:		;Add 1 to the amount of player wins
	mov EAX,[playerWins]
	add EAX,1
	mov [playerWins],EAX
	mov EAX,1		;Let's our earlier loop know player won

	push name
	push playerwins
	call printf
	add esp,8
	ret

	HalWon:			;Add 1 to the amount of Hal wins
	mov EAX,[HalWin]
	add EAX,1
	mov [HalWin],EAX
	mov EAX,-1		;Let's our loop know Hal won
	
	push name
	push halwins
	call printf
	add esp,8
	ret

	startGame:			;Starts our game of tictactoe
	call resetBoard			;Get our game ready
	mov EAX,[random]		;Set who goes first
	mov [currentPlayer],EAX
	

	ret

	printcurplayer:
	push dword [currentPlayer]
	push intfmt
	call printf
	add esp,8
	call printnewline
	ret

	playTurn:
	cmp dword [currentPlayer],0		;Compare who should go with 0 to jump to said players turn
	jg xmoveHuman
	call xmoveHAL

	push bef
	push strfmt
	call printf
	add esp,8
	call printcurplayer

	xor EAX,EAX
	mov EAX,[currentPlayer]
	cbw
	cwd
	add EAX,2
	mov [currentPlayer],EAX
	
	push aft
	push strfmt
	call printf
	add esp,8
	call printcurplayer



	ret

	xmoveHuman:			;-Error is guarunteed between scanf and 2nd printcurplayer
	call xmovePlayer
	playerMakeMove:
	call parseMove
	cmp EAX,0
	je playerMakeMove
	
	push bef
	push strfmt
	call printf
	add esp,8
	call printcurplayer

	xor EAX,EAX
	mov EAX,[currentPlayer]
	sub EAX,2
	mov [currentPlayer],EAX

	push aft
	push strfmt
	call printf
	add esp,8
	
	push name
	push strfmt
	call printf
	add esp,8
	call printcurplayer
	call printnewline
	ret
	
	xmoveHAL:
	;The 8 steps of tictactoe will go here
	mov dword EAX,[random]
	sub EAX,[random]
	mov [random],EAX
        

	;This is our Easy Peasy mode AI
	;Basically if somewhere if our logic we don't know what to do, just do this
	;It works pretty well
	HalrandomMove:
	push 0                  ;Push 0 for default time
        call time               ;Seed random and generate number
        add esp,4               ;Move stack pointer
	
	push EAX                ;Push the time it returned
        call srand              ;Now lets seed our random func with it
        add esp,4               ;Move stack pointer
        
	push EAX                ;Push so random will store in EAX
        call rand               ;Let's get our random value
        add esp,4               ;Move stack pointer
        
	mov EBX,[easymodelimit]         ;Move 10 to EBX
        xor EDX,EDX             	;Clear out EDX
        div EBX                 	;Divide EAX by EBX remainder stored in EDX
	mov EAX,EDX
	cbw
	cwd
	mov [currentMove],EAX	
	call parseMove
	
	cmp EAX,0		;Let's see if we made a move
	je HalrandomMove

	HalmovePlayed:
	push cpuname
	push strfmt
	call printf
	add esp,8
	call printcurplayer
	ret
	
	xmovePlayer:
	push makemove		;Tell the player to input a move
	push strfmt
	call printf
	add esp,8

	push currentMove	;For now were gonna get input in a shitty way until I feel like doing it a good way
	push intfmt		;board goes in order 1-TL 2-TM 3-TR and so on until 9 is BR
	call scanf
	add esp,8

	ret


	parseMove:
	mov EAX,[currentMove]

	pmoveTL:
	sub EAX,1
	jnz pmoveTM
	mov EAX,[topleft]
	cmp EAX,0
	jnz parseMoveSlotFilled
	mov EAX,[currentPlayer]
	mov [topleft],EAX
	jmp xmovePlayerExit

	pmoveTM:
	sub EAX,1
	jnz pmoveTR
	mov EAX,[topmid]
	cmp EAX,0
	jnz parseMoveSlotFilled
	mov EAX,[currentPlayer]
	mov [topmid],EAX
	jmp xmovePlayerExit

	pmoveTR:
	sub EAX,1
	jnz pmoveML
	mov EAX,[topright]
	cmp EAX,0
	jnz parseMoveSlotFilled
	mov EAX,[currentPlayer]
	mov [topright],EAX
	jmp xmovePlayerExit

	pmoveML:
	sub EAX,1
	jnz pmoveMM
	mov EAX,[midleft]
	cmp EAX,0
	jnz parseMoveSlotFilled
	mov EAX,[currentPlayer]
	mov [midleft],EAX
	jmp xmovePlayerExit

	pmoveMM:
	sub EAX,1
	jnz pmoveMR
	mov EAX,[midmid]
	cmp EAX,0
	jnz parseMoveSlotFilled
	mov EAX,[currentPlayer]
	mov [midmid],EAX
	jmp xmovePlayerExit

	pmoveMR:
	sub EAX,1
	jnz pmoveBL
	mov EAX,[midright]
	cmp EAX,0
	jnz parseMoveSlotFilled
	mov EAX,[currentPlayer]
	mov [midright],EAX
	jmp xmovePlayerExit

	pmoveBL:
	sub EAX,1
	jnz pmoveBM
	mov EAX,[bottomleft]
	cmp EAX,0
	jnz parseMoveSlotFilled
	mov EAX,[currentPlayer]
	mov [bottomleft],EAX
	jmp xmovePlayerExit

	pmoveBM:
	sub EAX,1
	jnz pmoveBR
	mov EAX,[bottommid]
	cmp EAX,0
	jnz parseMoveSlotFilled
	mov EAX,[currentPlayer]
	mov [bottommid],EAX
	jmp xmovePlayerExit

	pmoveBR:
	sub EAX,1
	jnz xmovePlayerExit
	mov EAX,[bottomright]
	cmp EAX,0
	jnz parseMoveSlotFilled
	mov EAX,[currentPlayer]
	mov [bottomright],EAX
	
	xmovePlayerExit:
	mov EAX,1		;Let's earlier functions know move was made
	ret

	parseMoveSlotFilled:
	mov EAX,0		;Move was not made, slot was full
	ret	

	resetBoard:		;Resets all slots to 0
	mov dword [topleft],0
	mov dword [topmid],0
	mov dword [topright],0
	
	mov dword [midleft],0
	mov dword [midmid],0
	mov dword [midright],0
	
	mov dword [bottomleft],0
	mov dword [bottommid],0
	mov dword [bottomright],0
	ret


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
	xor EAX,EAX
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
	mov EAX,EDX		;Store random result in random (0 = cpu, 1 = human)
	
	cmp EAX,0		;Except our moveparser is going to use -1 for cpu and 1 for human so we need to change it
	jz pickPlayerCPU
	mov [currentPlayer],EAX
	ret

	pickPlayerCPU:
	sub EAX,1
	mov [currentPlayer],EAX
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
