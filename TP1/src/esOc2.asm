global esOc2

section .text
%define param_buffer [ebp + 8]

esOc2:
	push ebp
	mov ebp,esp
	push ebx
	push esi
	push edi

	xor ebx, ebx; limpio ebx
	mov ebx,param_buffer; muevo la unica variable a ebx
	cmp dword [ebx], 79834748; comparo y verifico que diga "OS2/0"
	jne noEsOs
	je esOs

esOs:
	xor eax, eax
	mov eax, 1 ; escribo true
	jmp fin

noEsOs:
	xor eax. eax
	mov eax, 0; escribo false
	jmp fin

fin:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret