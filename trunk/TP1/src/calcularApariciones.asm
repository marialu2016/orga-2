global calcularApariciones

section.text

calcularApariciones:
	push ebp
	mov ebp, esp
	push edi
	push esi
	push ebx

fin:
	pop ebx
	pop esi
	pop edi
	pop ebp
	ret