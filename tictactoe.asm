;Authors: Garrett Walker - David Hudson
;Date Started: April/4/2016
;To Compile
;nasm -f elf32 task4.asm && gcc -m32 -o task4 task4.o

;~~~~C Functions~~~~;
extern printf           ;Printing to the screen
extern scanf            ;Receiving input
extern srand            ;Seed random
extern rand             ;Random
extern time             ;For srand
global main
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SECTION .data

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SECTION .bss

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SECTION .text

main:



Exit:
	ret
