global ancho

section .text

%define param_header [ebp + 8]

ancho:
	push ebp
	mov ebp,esp
	push ebx
	push esi
	push edi

	mov ebx, param_header;pongo en ebx el puntero al header
	lea ebx, [ebx+18]; me posiciono en el byte 18 del header
	mov eax, [ebx];pongo en eax el byte 18,19,20,21 que indican el ancho de la imagen en 			pixeles

fin:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret