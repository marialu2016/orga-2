global decodificar

section.text

%define tabla [ebp + 8]
%define bitstream [ebp + 12]
%define tamBitst [ebp + 16]

%define solucion [ebp - 4]

decodificar:
	push ebp
	mov ebp, esp
	push edi
	push esi
	push ebx
	;///////////////PEDIR MEMORIA//////////////
	;consultar sobre cuanta memoria se debe de pedir
	;se asumira que el bitsrteam esta en eax por ahora

	mov eax, solucion; copio la direccion
	mov ebx, bitstream; ebx(ptr) recorre el bstream
	mov ecx, 32;ecx dice cuando tengo que mover al prox bstream
	
	mov edi, [ebx]; edx tiene los 32 bits de bstream

	xor edx, edx; seteo en 0 el registro edx
	

leer:; lee del bitstream 
	


buscar:; busca en la tabla de codificación


refresh:; escribe sobre buffer cuando se llena el registro






fin:
	pop ebx
	pop esi
	pop edi
	pop ebp
	ret