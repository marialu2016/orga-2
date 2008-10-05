global decodificar

section.text

%define tabla_cod [ebp + 8]


decodificar:
	push ebp
	mov ebp, esp
	push edi
	push esi
	push ebx

	mov esi, bitstream

fin:
	pop ebx
	pop esi
	pop edi
	pop ebp
	ret