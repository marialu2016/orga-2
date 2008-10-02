global es24

section .text

%define param_header [ebp + 8]

es24:
	push ebp
	mov ebp,esp
	push ebx
	push esi
	push edi

	mov ebx,param_header; muevo header a ebx
	lea ebx, [ebx + 28]; me desplazo a donde esta si es 
	cmp word[ebx], 24; comparo si es 24 o no
	je seVerifica
	jne noSeVerifica

seVerifica:
	xor eax, eax
	mov eax, 1
	jmp fin

noSeVerifica:
	xor eax, eax
	mov eax, 0
	jmp fin

fin:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret