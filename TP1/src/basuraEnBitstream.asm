global basuraEnBitstream

extern malloc
extern free

section .text

%define tabla [ebp + 8]
%define buffer [ebp + 12]
%define tamBuff [ebp + 16]
%define ancho [ebp + 20]
%define trash [ebp + 24]
%define tamBitstream [ebp + 28]

%define contadorBuff [ebp - 4]
%define queTanLleno [ebp - 8]
%define solucion [ebp - 12]
%define bytesUtil [ebp - 16]

%define tabla_simb 0
%define tabla_longcod 1
%define tabla_cod 4
%define tabla_sig 8

basuraEnBitstream:
	push ebp
	mov ebp, esp
	sub esp,16
	push edi
	push esi
	push ebx	; convencion c
	
;***************************************************************************
;**								Crear bitstream					  		  **
;***************************************************************************

	mov ecx, tamBuff	; copio ecx para dar el tamaño de buffer
	mov contadorBuff, ecx	; inicializo contador de long buffer
			;contadorBuff = tamBuff
	mov edx,ancho
	mov dword bytesUtil,edx	; bytesUtil = ancho
				; servirá para recorrer las lineas

	mov edi, buffer	; uso ebx(ptr) para recorrer buffer

	xor edx, edx
	xor ebx, ebx	; edi sera para imprimir en bstream

	mov esi, 8	; cargo inicialmente que tan lleno esta edi

	
;***************************************************************************
;**							BUSQUEDA DEL CARACTER					  	  **
;***************************************************************************

buscar:	; cargo el caracter para el cual le busco su codificacion
	cmp dword contadorBuff,0	; veo si llegue al final de buffer antes de seguir
	je termine
	dec dword contadorBuff	; sino decremento el contador de longitud buffer

	cmp dword bytesUtil, 0	; veo si llegue al final de linea
	je saltar_linea
	dec dword bytesUtil	; decremento por el avance que hare en la linea

;sino es fin de linea

	mov queTanLleno, esi	; guardo temporalmente en queT.. el estado de edi
	mov esi, tabla	; uso esi(ptr) para recorrer tabla de codificacion
;esi podria ser usado luego para recorrer la tabla de codificacion o tambien eventualmente como registro auxiliar para actualizar el contador bytesUtil

	mov dl, [edi]; en dl tengo el simbolo que quiero su codificacion
	lea edi,[edi + 1]; me posicion al siguiente simbolo
	jmp busq_lineal

saltar_linea:;como dice la etiqueta...
	mov queTanLleno, esi	; guardo temporalmente en queT.. el estado de edi

	mov esi,ancho

	mov dword bytesUtil,esi	; bytesUtil = ancho
	;dec dword bytesUtil

	mov esi, trash
	dec esi
	lea edi,[edi + esi]	; me posicion al siguiente simbolo
	;mov esi, tabla	; uso esi(ptr) para recorrer tabla de codificacion
	;mov dl, [ebx]	; en dl tengo el simbolo que quiero su codificacion
	sub contadorBuff,esi
	mov esi, queTanLleno
	;inc dword contadorBuff
	;lea ebx, [ebx+1]
	jmp buscar

busq_lineal:	;realiza busq lineal para devolver la codificacion
	cmp dl,[esi + tabla_simb]	; comparo con el primero en esi
	je guardar_cod

	lea esi, [esi + tabla_sig]	; me muevo al sig simb en la tabla de cod
	jmp busq_lineal

termine:	
	;inc esi
	xor ecx, ecx
	mov ecx, esi
	rol bl, cl

	mov ebx, esi	; muevo a eax el ptr solucion
	mov eax, ebx
	jmp fin

guardar_cod:; guardo la codificacion
	xor ecx, ecx
	xor edx, edx
	mov edx, [esi + tabla_cod]; guardo en edx la codificacion del simb evaluado
	mov cl, [esi + tabla_longcod]; guardo en cl la longitud de lo codificado

	ror edx, cl	;muevo a los bits mas significativos
	clc
	mov esi, queTanLleno	; esi indica el estado del reg que pasa a mem

;ESTADO: edx: tengo la codificacion,
;	 ebx: ubicado en el caracter siguiente, ebx = ebx_0 + 1
;	 cl: longitud del simb codificado
;	 esi: es nuevamente el contador que indica que tan lleno esta edi, esi = 		esi_0

;***************************************************************************
;**							ESCRITURA SOBRE BITSTREAM					  **
;***************************************************************************

mover_sim:	; mueve bit a bit el simbolo codificado
	cmp cl, 0	; veo si ya termine de carga el simb codificado
	je buscar
	dec cl	; decremento el contador de long cod

	cmp esi, 0; veo si me queda lugar en edi
	je recargar
	dec esi
seguir:
	shl edx, 1; muevo hacia derecha y cargo en carry el bit menos sig
	jc agrego_1
	jmp agrego_0

agrego_1:

    	shl bl, 1	; muevo uno hacia izq
	add bl, 1	; pongo un uno en el menos significativo

	jmp mover_sim

agrego_0:

	shl bl, 1; muevo hacia izq

	jmp mover_sim

recargar:
	xor ebx, ebx	; limpio ebx para la proxima carga a ebx
	mov esi, 7	; cargo el contador que verifica si se llenó
	jmp seguir
	
fin:
	pop ebx
	pop esi
	pop edi
    	add esp, 16
	pop ebp
	ret
