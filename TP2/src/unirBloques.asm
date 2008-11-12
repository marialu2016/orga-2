global unirBloques

section .text

;PROTOTIPO C: void unirBloques (char* buffer,char* bloque, int coord_1, int coord_j, int ancho)

%define buffer [ebp + 8]
%define bloque [ebp + 12]
%define coord_i [ebp + 16]
%define coord_j [ebp + 20]

unirBloques:
	push ebp
	mov ebp, esp
	push edi
	push esi
	push ebx

	xor eax, eax
	xor edi, edi
	xor ecx, ecx

	;Ubico en la coordenada i
	mov eax, ancho
	mov ecx, coord_i
ubicar_i:
	lea edi, [edi+eax]
	loop ubicar_i

	;Ubico en la coordenada j
	xor eax, eax
	mov eax, coord_j
	lea edi, [edi+eax]

	;Copio bloque en i,j
	mov ebx, ancho	
	mov esi, bloque
	mov al, [esi]
	mov byte[edi], al
	lea esi, [esi+1]
	lea edi, [edi+ebx]

	mov al, [esi]
	mov byte[edi], al
	lea esi, [esi+1]
	lea edi, [edi+ebx]

	mov al, [esi]
	mov byte[edi], al
	lea esi, [esi+1]
	lea edi, [edi+ebx]

	mov al, [esi]
	mov byte[edi], al
	lea esi, [esi+1]
	lea edi, [edi+ebx]

	mov al, [esi]
	mov byte[edi], al
	lea esi, [esi+1]
	lea edi, [edi+ebx]

	mov al, [esi]
	mov byte[edi], al
	lea esi, [esi+1]
	lea edi, [edi+ebx]

	mov al, [esi]
	mov byte[edi], al
	lea esi, [esi+1]
	lea edi, [edi+ebx]

	mov al, [esi]
	mov byte[edi], al


fin:
	pop ebx
	pop esi
	pop edi
	pop ebp
	ret