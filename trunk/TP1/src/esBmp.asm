global esBmp

section .text
%define param_header [ebp + 8]
esBmp:
	push ebp
	mov ebp,esp
	push ebx
	push esi
	push edi

	xor ebx, ebx; limpio ebx
	mov ebx,param_header; muevo la unica variable a ebx
	cmp word [ebx], 6677;comparo y verifico que diga "BM"
	jne noEsBm
	je esBm

esBm:
	xor eax, eax
	mov eax, 1 ; escribo true
	jmp fin
noEsBm:
	xor eax. eax
	mov eax, 0; escribo false
	jmp fin

fin:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret