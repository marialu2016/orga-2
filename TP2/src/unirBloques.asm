global unirBloques

section .text

;PROTOTIPO C: void unirBloques (char* buffer,char* bloque, int coord_1, int coord_j, int ancho)

%define buffer [ebp + 8]
%define bloque [ebp + 12]
%define coord_i [ebp + 16]
%define coord_j [ebp + 20]
%define ancho [ebp + 24]

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
	mov edi, buffer
	mov eax, ancho
	mov ecx, coord_i
ubicar_i:
    cmp ecx, 0
    je seguir
    dec ecx
	lea edi, [edi + eax]
    jmp ubicar_i
    
seguir:
	;Ubico en la coordenada j
	xor eax, eax
	mov eax, coord_j
	lea edi, [edi + eax]

	;Copio bloque en i,j
	mov ebx, ancho	
	mov esi, bloque

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi + 8]
	lea edi, [edi + ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi + 8]
	lea edi, [edi + ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi + 8]
	lea edi, [edi + ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi + 8]
	lea edi, [edi + ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi + 8]
	lea edi, [edi + ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
    lea esi, [esi + 8]
	lea edi, [edi + ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi + 8]
	lea edi, [edi + ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax


fin:
	pop ebx
	pop esi
	pop edi
	pop ebp
	ret