global tamTabla

extern malloc
extern free

section .text

%define buffer [ebp+8]
%define img_size [ebp + 12]
%define ancho [ebp + 16]
%define basura [ebp + 20]

%define tam [ebp - 4]
%define estr [ebp - 8]

tamTabla:
                    push ebp
                    mov ebp,esp
		    sub esp, 8
                    push edi
                    push esi
                    push ebx

                    mov esi, buffer;pongo en esi la direccion del buffer con los datos de la imagen

                    mov eax, 1024	;pongo en eax la cantidad de memoria que voy a pedir
                    push eax
                    call malloc		;pido memoria
                    add esp, 4		;balanceo la pila
                    cmp eax,0		;me fijo si pudo darme la memoria
                    jne mem_ok		;si me pudo dar memoria inicializo la estructura
                    jmp mem_error	; sino devuelvo un error
mem_ok:
                    mov edi, eax	;copio el puntero a la memoria que me dio malloc en edi
                    mov ecx, 256	;pongo ecx en 256 porque lo vamos a usar como contador para la inicializacion
inicializar:
                    mov dword [eax], 0	; pongo cero en la i-esima posicion
                    lea eax, [eax + 4]	; voy a la siguiente posicion
                    loop inicializar	;repito este paso hasta llegar al final de la estructura

                    mov ecx, img_size	; guardo el tamaño de la imagen en ecx
		    mov tam, ecx 

                    xor ebx, ebx	;pongo ebx en 0 porque lo vamos a usar como contador de simbolos diferentes
                    cld		;seteo en cero el bit de direccion para moverme para la derecha cuando use lods
cicloext:
		    cmp dword tam, 0
		    je terminar
		    mov ecx, ancho
cicloint:
		    xor eax, eax	;pongo eax en cero porque lods va a guardar datos aca
                    lodsb		;leo un byte
                    lea edx, [edi + 4 * eax]	;direcciono a la estructura auxiliar
                    cmp dword [edx], 0		; me fijo si la cantidad de apariciones de ese elemnto es cero
                    je aumentar	;si es cero agrego el simbolo con una aparicion
siguiente:
		    loop cicloint

		    mov ecx, ancho
		    sub tam, ecx
		    mov ecx, basura
		    sub tam, ecx
		    lea esi, [esi + ecx]
                    jmp cicloext		;repito este ciclo hasta llegar al final de la imagen
aumentar:
		inc dword [edx]
		inc ebx
		jmp siguiente
terminar:
		push edi
		call free
		add esp, 4
		mov eax, ebx
		jmp fin
mem_error:
                    mov eax, 0
                    jmp fin

fin:
                    pop ebx
                    pop esi
                    pop edi
		    add esp, 8
                    pop ebp
                    ret
 
