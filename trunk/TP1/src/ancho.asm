global ancho

section .text
%define param_header [ebp + 8]

ancho:
	push ebp
	mov ebp,esp
	push ebx
	push esi
	push edi

	mov ebx, param_header
	lea ebx, [ebx+18] 
	mov eax, [ebx]

fin:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret