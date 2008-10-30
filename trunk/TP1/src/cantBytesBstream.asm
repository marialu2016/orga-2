global cantBytesBstream

extern malloc

section .text

%define tabla [ebp + 8]
%define buffer [ebp + 12]
%define tamBuff [ebp + 16]
%define ancho [ebp + 20]
%define trash [ebp + 24]
%define bitstream [ebp + 28]

%define contadorBuff [ebp - 4]
%define bytesUtil [ebp - 8]

%define tabla_simb 0
%define tabla_longcod 1
%define tabla_cod 4
%define tabla_sig 8

cantBytesBstream:
	push ebp
	mov ebp, esp
	sub esp,8
	push edi
	push esi
	push ebx	; convencion c

;***************************************************************************
;**	Calcular memoria a pedir					  **
;***************************************************************************

	mov ecx, tamBuff 	; copio ecx para dar el tamaño de buffer
	mov contadorBuff, ecx 	; inicializo contador de long buffer
	;contadorBuff = tamBuff

	mov edx,ancho
	mov dword bytesUtil,edx
	; bytesUtil = ancho, servirá para recorrer las lineas

	mov esi, buffer	; uso esi(ptr) para recorrer buffer
	xor ebx, ebx
	xor eax, eax
	xor ecx, ecx
	xor edx, edx
	xor edi, edi

escaneo_long:
	cmp dword contadorBuff,0	; veo si llegue al final de buffer antes de seguir
	je inic_reservar;
	dec dword contadorBuff	; sino decremento el contador de longitud buffer

	cmp dword bytesUtil, 0	; veo si llegue al final de linea
	je prox_linea
	dec dword bytesUtil	; decremento por el avance que hare en la linea

;si no es fin de linea
	mov edi, tabla	; uso edi(ptr) para recorrer tabla de codificacion

	mov bl, [esi]	; en bl tengo el simbolo que quiero su longitud

	lea esi,[esi + 1]	; me posiciono al siguiente simbolo
	jmp busq_de_long

prox_linea:

	mov ecx, ancho
	mov dword bytesUtil, ecx	; bytesUtil = ancho
	;dec dword bytesUtil

	mov ecx, trash


	;mov edi, tabla	; uso edi(ptr) para recorrer tabla de codificacion

	lea esi, [esi + ecx]	; me posicion al siguiente simbolo
	sub contadorBuff, ecx
	inc dword contadorBuff
	jmp escaneo_long 
	;mov bl, [esi]	; en bl tengo el simbolo que quiero su codificacion
	;lea esi,[esi + 1]	; me posiciono al siguiente simbolo

busq_de_long:;
	cmp bl,[edi + tabla_simb]	; comparo con el primero en edi
	je add_long

	lea edi, [edi + tabla_sig]	; me muevo al sig simb en la tabla de cod
	jmp busq_de_long

add_long:;
	clc
	mov bl, [edi + tabla_longcod]
	add eax, ebx	; guardo en eax la long de la codificacion del simb evaluado
	adc edx, 0
	xor ebx, ebx
	;clc
	jmp escaneo_long

;***************************************************************************
;**								Pedir memoria					  		  **
;***************************************************************************
	
inic_reservar:
	xor ecx, ecx
	mov ecx, 8
	div dword ecx	; calculo el resto
	cmp edx, 0
	je reservar

	inc eax

reservar:
	mov ebx, eax
	push eax
	call malloc
	add esp, 4
	mov bitstream, eax
	mov eax,ebx

fin:
	pop ebx
	pop esi
	pop edi
	add esp, 8
	pop ebp
	ret