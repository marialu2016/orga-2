global calcularApariciones

extern malloc
extern free

section .text

%define buffer [ebp+8]
%define img_size [ebp + 12]
%define ancho [ebp + 16]
%define basura [ebp + 20]
%define tam_tabla [ebp + 24]

calcularApariciones:
                    push ebp
                    mov ebp,esp
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

                    xor ebx, ebx	;pongo ebx en 0 porque lo vamos a usar como contador de simbolos diferentes
                    cld		;seteo en cero el bit de direccion para moverme para la derecha cuando use lods
cicloext:
		    cmp dword img_size, 0
		    je estr_devolver
		    mov ecx, ancho
cicloint:
		    xor eax, eax	;pongo eax en cero porque lods va a guardar datos aca
                    lodsb		;leo un byte
                    lea edx, [edi + 4*eax]	;direcciono a la estructura auxiliar
                    cmp dword [edx], 0		; me fijo si la cantidad de apariciones de ese elemnto es cero
                    je agregar_simbolo	;si es cero agrego el simbolo con una aparicion
                    add dword [edx], 1	;sino le sumo una aparicion mas
siguiente:
		    loop cicloint

		    mov ecx, ancho
		    sub img_size, ecx
		    mov ecx, basura
		    sub img_size, ecx
		    lea esi, [esi + ecx]
                    jmp cicloext		;repito este ciclo hasta llegar al final de la imagen
estr_devolver:
		    mov ecx, 8		;pongo en ecx un 8 porque mi estructura tiene lugares de 8 bytes
                    mov eax, ebx	;pongo en eax la cantidad de elementos
                    mov tam_tabla, ebx ; pongo en el parametro tam_tabla la cantidad de simbolos distintos ya que este sera pasado por referencia
                    mul ecx		;multiplico ecx por 5,que es la cantidad de memoria a pedir
                    push eax
                    call malloc
                    add esp, 4
                    cmp eax, 0
                    jne guardar		;guardo la estructura a devolver
                    jmp mem_error2
guardar:
                    xor ecx, ecx		;seteo en cero cl, que lo usaremos para copiar el simbolo
                    mov esi, edi	; pongo la estructura auxiliar en esi
                    mov edi, eax	; pongo la estructura a devolver en edi
                    mov edx, esi	;pongo en eax el puntero a la estructura a devolver para 			poder moverme por la estructurapoder moverme por la estructura
ciclo_2:
                    mov ebx, [edx]	;pongo en ebx la cantidad de elementos del simbolo
                    cmp ebx, 0		;la comparo co cero
                    je sigo		; si es cero entonces sigo

                    mov [edi], cl	;sino copio el simbolo
                    lea edi, [edi + 4]
                    mov [edi], ebx	; y la cantidad de apariciones
                    lea edi, [edi + 4]
sigo:
                    lea edx, [edx + 4]	;voy a la proxima posicion de la estructura auxiliar
                    inc ecx		;incremento cl, que es el siguiente caracter
                    cmp ecx, 255		;me fijo si ya llegue al final de la estructura
                    jbe ciclo_2		; en caso de que no, sigo con el ciclo
		    mov ebx, eax; salvo eax por que voy a usar free
                    push esi		; la pusheo para liberar la memoria
                    call free		;libero la memoria
                    add esp, 4		;balanceo la pila
		    mov eax, ebx
                    jmp fin
agregar_simbolo:
                    mov dword [edx], 1 ;le sumo una aparicion mas
                    inc ebx	;incremento la cantidad de simbolos diferentes
		    jmp siguiente
mem_error:
                    mov eax, 0
                    jmp fin
mem_error2:
                    push edi		;pusheo la estructura auxiliar para liberar la memoria
                    call free		;libero la memoria
                    add esp, 4		;balanceo la pila
		    mov eax, 0

fin:
                    pop ebx
                    pop esi
                    pop edi
                    pop ebp
                    ret
