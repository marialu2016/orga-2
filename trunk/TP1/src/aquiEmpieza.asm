global aquiEmpieza

section .text

%define param_header [ebp + 8]

aquiEmpieza:
	push ebp
	mov ebp,esp
	push ebx
	push esi
	push edi

	mov ebx, param_header;pongo en ebx el puntero al header
	lea ebx, [ebx+10];me posiciono en el byte 10 del header
	mov eax, [ebx];pongo en eax el offset en donde comienza el archivo

fin:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret