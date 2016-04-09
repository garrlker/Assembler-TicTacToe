#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				MAKEFILE					#
#	Compiles code and had basic functionality for cleaning working 		#
#		directory and doing some basic git functions
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
	git commit -m "${m}"
gpush:
	git push origin master
pull:
	git pull
