ASM=nasm
AFLAGS=-ggdb -f elf
CC=gcc
CFLAGS=-ggdb -Wall
MAIN=main.c
MAIN2= main.o
OBJS=dividirBloques.o transpuesta.o generarDCT.o transformar.o cuantizar.o codificar.o decodificar.o descuantizar.o antitransformar.o unirBloques.o
EXE=tp2orga

	$(ASM) $(AFLAGS) dividirBloques.asm -o $(PATHOBJ)dividirBloques.o
	$(ASM) $(AFLAGS) transpuesta.asm -o $(PATHOBJ)transpuesta.o
	$(ASM) $(AFLAGS) generarDCT.asm -o $(PATHOBJ)generarDCT.o
	$(ASM) $(AFLAGS) transformar.asm -o $(PATHOBJ)transformar.o
	$(ASM) $(AFLAGS) cuantizar.asm -o $(PATHOBJ)cuantizar.o
	$(ASM) $(AFLAGS) codificar.asm -o $(PATHOBJ)codificar.o
	$(ASM) $(AFLAGS) decodificar.asm -o $(PATHOBJ)decodificar.o
	$(ASM) $(AFLAGS) descuantizar.asm -o $(PATHOBJ)descuantizar.o
	$(ASM) $(AFLAGS) antitransformar.asm -o $(PATHOBJ)antitransformar.o
	$(ASM) $(AFLAGS) unirBloques.asm -o $(PATHOBJ)unirBloques.o
	$(CC) $(CFLAGS) -c $(MAIN)
	$(CC) $(CFLAGS) -o $(EXE) $(MAIN2) $(OBJS)
