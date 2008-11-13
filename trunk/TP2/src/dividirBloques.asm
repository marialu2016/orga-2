global dividirBloques

extern malloc

section .text

%define canal [ebp + 8]
%define i [ebp + 12]
%define j [ebp + 16]
%define prox_fila [ebp + 20]

%define resultado [ebp - 4]
%define prox_col 4

dividirBloques:
    push ebp
    mov ebp, esp
    sub esp, 4
    push edi
    push esi
    push ebx

    mov esi, canal

    mov eax, 64
    shl eax, 2
    push eax
    call malloc
    add esp, 4

    mov resultado, eax
    mov edi, eax
    mov eax, prox_fila
    mov ecx, i

ubicar_i:
	lea edi, [edi+eax]
	loop ubicar_i

;Ubico en la coordenada j
	xor eax, eax
	mov eax, j
	lea esi, [esi+eax]

	;Copio canal en i,j
	mov ebx, prox_fila	
	mov edi, resultado

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi+ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi+ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi+ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi+ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi+ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi+ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax
	lea esi, [esi+ebx]

	mov eax, [esi]
	mov [edi], eax
	mov eax, [esi + 4]
	mov [edi + 4], eax

fin:
    mov eax, resultado
    pop ebx
    pop esi
    pop edi
    add esp, 4
    pop ebp
    ret