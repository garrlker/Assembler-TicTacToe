#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				MAKEFILE					#
#
#
#
#
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
TARGET  = tictactoe	#Output binary
RMEXTS	= *.o
all: 
	nasm -f elf32 tictactoe.asm && gcc -m32 -o tictactoe tictactoe.o

clean:
	rm $(RMEXTS) $(TARGET)
run:
	./$(TARGET)
gstart:
	git add *
