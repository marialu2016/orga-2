global calcularApariciones

extern malloc
extern free

section .text

%define buffer [ebp+8]
%define img_size 34
%define img_begin 10

calcularApariciones:
                    push ebp
                    mov ebp,esp
		    push edi
                    push esi
                    push ebx

                    mov esi, buffer	;pongo en esi la direccion del buffer con los 				datos de la imagen

                    mov eax, 1024	;pongo en eax la cantidad de memoria que voy a pedir
                    push eax
                    call malloc		;pido memoria
                    add esp, 4		;balanceo la pila
                    cmp eax,0		;me fijo si pudo darme la memoria
                    jne mem_ok		;si me pudo dar memoria inicializo la estructura
                    jmp mem_error	; sino devuelvo un error
mem_ok:
                    mov edi, eax	;copio el puntero a la memoria que me dio malloc en edi
                    xor ebx, ebx	;pongo ebx en 0 porque lo vamos a usar para inicializar el 			arreglo en cero
                    mov ecx, 256	;pongo ecx en 256 porque lo vamos a usar como contador para 			la inicializacion
inicializar:
                    mov [eax], ebx	; pongo cero en la i-esima posicion
                    lea eax, [eax + 4]	; voy a la siguiente posicion
                    loop inicializar	;repito este paso hasta llegar al final de la estructura 
                    
                    lea ebx, [esi + img_size]	;me paro en el lugar que me dice el tamaño de la 				imagen
                    mov ecx, [ebx]	; guardo el tamaño de la imagen en ecx
                    
                    lea ebx, [esi + img_begin]	;me paro en el lugar que me dice donde comienza 				la imagen
                    mov edx, [ebx]	; guardo en que byte empieza la imagen en edx
                    
                    lea esi, [esi + edx]	; voy al inicio de los datos de la imagen
                    xor ebx, ebx	;pongo ebx en 0 porque lo vamos a usar como contador de 			simbolos diferentes
                    cld		;seteo en cero el bit de direccion para moverme para la derecha 		cuando use lods
ciclo:
		    xor eax, eax	;pongo eax en cero porque lods va a guardar datos aca
                    lodsb		;leo un byte
                    lea edx, [edi + eax]	;direcciono a la estructura auxiliar
                    mov eax, [edx]	;pongo en eax el contenido de la posicion de la estrucxtura 			auxiliar, que es la cantidad de apariciones de ese 				elemento
                    cmp eax, 0		; me fijo si la cantidad de apariciones de ese elemnto es cero
                    je agregar_simbolo	;si es cero agrego el simbolo con una aparicion
                    mov eax, 1		
                    add [edx], eax	;sino le sumo una aparicion mas
                    loop ciclo		;repito este ciclo hasta llegar al final de la imagen

		    mov ecx, 5		;pongo en ecx un 5 porque mi estructura tiene lugares de 			5 bytes
                    mov eax, ebx	;pongo en eax la cantidad de elementos
                    mul ecx		;multiplico ecx por 5,que es la cantidad de memoria a 				pedir
                    push eax
                    call malloc
                    add esp, 4
                    cmp eax, 0
                    jne guardar		;guardo la estructura a devolver
                    jmp mem_error
guardar:
                    xor cl, cl		;seteo en cero cl, que lo usaremos para copiar el simbolo
                    mov esi, edi	; pongo la estructura auxiliar en esi
                    mov edi, eax	; pongo la estructura a devolver en edi
                    mov edx, esi	;pongo en edx el puntero a la estructura auxiliar para 				poder moverme por la estructura
                    mov eax, edi	;pongo en eax el puntero a la estructura a devolver para 			poder moverme por la estructura
ciclo_2:
                    mov ebx, [esi]	;pongo en ebx la cantidad de elementos del simbolo
                    cmp ebx, 0		;la comparo co cero
                    je sigo		; si es cero entonces sigo
                    mov [eax], cl	;sino copio el simbolo
                    lea eax, [eax + 1]
                    mov [eax], ebx	; y la cantidad de apariciones
                    lea eax, [eax + 4]
sigo:
                    lea edx, [edx + 4]	;voy a la proxima posicion
                    inc cl		;incremento cl, que es el siguiente caracter
                    cmp cl, 255		;me fijo si ya llegue al final de la estructura
                    jbe ciclo_2		; en caso de que no, sigo con el ciclo
                    mov eax, edi	;en caso que si, pongo en eax, el puntero a la 					estructura a devolver
                    mov edi, esi	; pongo en edi el puntero a la estructura auxiliar
                    push edi		; la pusheo para liberar la memoria
                    call free		;libero la memoria
                    add esp, 4		;balanceo la pila
                    jmp fin
agregar_simbolo:
		    mov eax, 1
                    mov [edx], eax
                    inc ebx

mem_error:
                    mov eax, 0
                    jmp fin

fin:
                    pop ebx
                    pop esi
                    pop edi
                    pop ebp
                    ret
