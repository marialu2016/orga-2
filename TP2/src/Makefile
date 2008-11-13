ASM=nasm
AFLAGS=-ggdb -f elf
CC=gcc
CFLAGS=-ggdb -Wall
MAIN=main.c
MAIN2= main.o
OBJS=dividirBloques.o transpuesta.o generarDCT.o transformar.o cuantizar.o codificar.o decodificar.o descuantizar.o antitransformar.o unirBloques.o
EXE=tp2orga
tp:
	$(ASM) $(AFLAGS) dividirBloques.asm
	$(ASM) $(AFLAGS) transpuesta.asm
	$(ASM) $(AFLAGS) generarDCT.asm
	$(ASM) $(AFLAGS) transformar.asm
	$(ASM) $(AFLAGS) cuantizar.asm
	$(ASM) $(AFLAGS) codificar.asm
	$(ASM) $(AFLAGS) decodificar.asm
	$(ASM) $(AFLAGS) descuantizar.asm
	$(ASM) $(AFLAGS) antitransformar.asm
	$(ASM) $(AFLAGS) unirBloques.asm
	$(CC) $(CFLAGS) -c $(MAIN)
	$(CC) $(CFLAGS) -o $(EXE) $(MAIN2) $(OBJS)
