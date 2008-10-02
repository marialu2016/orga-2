global tamImg

section .text
%define param_header [ebp + 8]

tamImg:
	push ebp
	mov ebp,esp
	push ebx
	push esi
	push edi

	mov ebx,param_header; muevo header a ebx
	lea ebx, [ebx + 34]; muevo desde la cabecera hasta la pos 34 que tiene tamImg
	mov eax, [ebx]; muevo el valor contenido en la direccion de ebx a eax
	
fin:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret