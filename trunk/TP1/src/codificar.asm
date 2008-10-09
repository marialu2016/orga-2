global codificar

extern malloc

section.text

%define tabla [ebp+8]
%define buffer [ebp+12]
%define tamBuff [ebp+16]

%define contador [ebp-4]
%define queTanLleno [ebp-8]
%define solucion [ebp-12]

codificar:
	push ebp
	mov ebp, esp
	sub esp,12
	push edi
	push esi
	push ebx; convencion c

	;///////////////PEDIR MEMORIA//////////////
	;consultar sobre cuanta memoria se debe de pedir
	;se asumira que el bitsrteam esta en eax por ahora

	mov solucion, eax; guardo la dir en solucion
	
	mov ecx, tamBuff; copio ecx para dar el tamaño de buffer
	mov contador, ecx; inicializo contador de long buffer
			;contador = tamBuff

	mov ebx, buffer; uso ebx(ptr) para recorrer buffer

	xor edx, edx
	xor edi, edi; edi sera para imprimir en bstream

	mov esi, 32
	
buscar:; busca el simbolo en la tabla de codificacion
	mov queTanLleno, esi; guardo temporalmente en queT.. el estado de edi
	mov esi, tabla; uso esi(ptr) para recorrer tabla de codificacion

	cmp dword contador,0; veo si llegue al final de bstream antes de seguir
	je fin;
	dec dword contador; sino decremento el contador de longitud bstream

	mov dl, [ebx]; en dl tengo el simbolo que quiero su codificacion

	
busq_lineal:;realiza busq lineal para devolver la codificacion
	cmp dl,[esi]; comparo con el primero en esi
	je guardar_cod
	
	lea esi, [esi+6]; me muevo al sig simb en la tabla de cod
	jmp busq_lineal

guardar_cod:
	xor ecx, ecx
	xor edx, edx
	mov edx, [esi+2]; guardo en edx la codificacion del simb evaluado
	mov cl, [esi+1]; guardo en cl la longitud de lo codificado
	
	lea ebx,[ebx+1]; me posicion al siguiente simbolo
	mov esi, queTanLleno; esi indica el estado del reg que pasa a mem

;ESTADO: edx: tengo la codificacion, 
;	 ebx: ubicado en el caracter siguiente, ebx = ebx_0 + 1
;	 cl: longitud del simb codificado
;	 esi: volvio a la primera pos de tabla, esi = esi_0

mover_sim:; mueve bit a bit el simbolo codificado
	cmp cl, 0; veo si ya termine de carga el simb codificado
	je buscar;
	dec cl; decremento el contador de long cod

	cmp esi, 0; veo si me queda lugar en edi
	je recargar
	dec esi

	shr edx, 1; muevo hacia derecha y cargo en carry el bit menos sig
	jc agrego_1
	jmp agrego_0

agrego_1:

	adc ecx,0; pongo un uno en el menos significativo
	shl ecx,1; muevo uno hacia izq

	jmp mover_sim

agrego_0:
	
	shl ecx,1; muevo hacia izq

	jmp mover_sim

recargar:;mueve a bitstream y restaura el registro
	ror edi, 31; como está al reves, lo invierto
	mov [eax], edi; transfiero a bstream
	lea eax, [eax+4]; avanzo el ptr eax a los prox 32 bits
	xor edi, edi; limpio edi para la proxima carga a edi
	mov esi, 32; cargo el contador que verifica si se llenó 
	jmp mover_sim


fin:
	mov eax, solucion; muevo a eax el ptr solucion
	
	add esp, 4
	pop ebx
	pop esi
	pop edi
	pop ebp
	ret