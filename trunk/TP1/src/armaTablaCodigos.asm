global armarTablaCodigos

extern malloc
extern free

section .text

%define t_apariciones [ebp + 8]
%define tam [ebp + 12]
%define ptr_hojas [ebp - 4]
%define ptr_nodos [ebp - 8]

armarTablaCodigos:
                  push ebp
                  mov ebp, esp
		  sub esp, 8
                  push edi
                  push esi
                  push ebx 

                  mov esi, t_apariciones;pongo en esi el puntero a la tabla de cnatidad de 				apariciones
                  mov eax, [esi]; pongo en eax la cantidad de simbolos que tendra la tabla
                  mov tam, eax; guardo una copia de la cantidad de simbolos que tendra la tabla
                  mov ebx, 9	;cantidad de bytes del nodo
                  mul ebx	;multiplico cantidad de nodos por cantidad bytes del nodo
                  push eax
                  call malloc
                  add esp, 4	;balanceo la pila
                  cmp eax, 0	;me fijo si me pudo dar memoria
                  jne inicializar; si pudo voy a inicializar la estructura
                  jmp mem_error	;sino mando un error
inicializar:
                  mov ptr_hojas, eax;guardo el puntero a las hojas en memoria
                  mov ecx, tam	;pongo en ecx la cantidad de hojas
		  push ecx
		  push esi
		  call insertionSort	; ordeno la tabla de apariciones por frecuencia
		  add esp, 8	;balanceo la pila
ciclo_I:
                  mov dl, [esi]	;pongo en dl el simbolo
                  mov [eax], dl	;pongo en la hoja a la que estoy apuntando el caracter 
                  lea eax, [eax + 1]	; y me muevo al campo frecuencia
                  lea esi, [esi + 1]	; me muevo en la tabla apariciones a donde esta la 				frecuencia del simbolo
                  mov edx, [esi]	; pongo en edx la frecuencia del simbolo
                  mov [eax], edx	; pongo en la hoja que estoy apuntando la frecuencia
                  lea eax, [eax + 4]	; me muevo al puntero al padre de la hoja
                  lea esi, [esi + 4]	; me muevo al siguiente simbolo
                  xor edx, edx		;pongo edx en cero
                  mov [eax], edx	; porque voy a poner el puntero al padre en null
                  lea eax, [eax + 4]	; me muevo a la siguiente hoja
                  loop ciclo_I		; repito esto hasta llegar al final de la tabla

		  mov eax, tam	;pongo en eax la cantidad de hojas
		  dec eax	;le resto 1 porque la cantidad de nodos internos es igual a la 			cantidad de hojas - 1
		  mov ebx, 16	; pongo en ebx la cantidad de bytes que tiene cada nodo
		  mul ebx	; pongo en eax la cantidad de memoria a pedir 
		  push eax
		  call malloc
		  add esp, 4	; balanceo la pila
		  mov ptr_nodos, eax ;guardo en ptr_nodos el puntero a los nodos internos

		  mov ecx, tam; pongo en ecx la cantidad de hojas
		  dec ecx	; ahora ecx tiene la cantidad de nodos internos
		  mov ebx, eax;pongo en ebx el puntero a los nodos internos
inicializarNodos:
		  mov [ebx], 0	; pongo el puntero al hijo izq en null
		  lea ebx, [ebx + 4]	;avanzo al siguiente campo 
		  mov [ebx], 0	; pongo el puntero al hijo der en null
		  lea ebx, [ebx + 4]	;avanzo al siguiente campo
		  mov [ebx], 0	; pongo la frecuencia en cero
		  lea ebx, [ebx + 4]	;avanzo al siguiente campo
		  mov [ebx], 0	; pongo el puntero al padre en null
		  lea ebx, [ebx + 4]	;avanzo al siguiente nodo
		  loop inicializarNodos	;repito esto hasta llegar al final de la estructura

		  mov esi, ptr_hojas	; pongo en esi el puntero a las hojas
		  mov edi, eax	; pongo en edi el puntero a los nodos internos
		  mov ecx, tam	; pongo en ecx la cantidad de hojas
		  mov edx, ecx
		  dec edx	; y en edx la cantidad de nodos internos
		  mov ebx, edi	; pongo en ebx el puntero a los nodos internos
crearPadrehh:
		  mov [ebx], esi; pongo como hijo izq del nodo a la hoja apuntada por esi
		  lea esi, [esi + 1] ; me muevo al campo frecuencia de la hoja
		  mov eax, [esi]; pongo en eax la frecuencia de la hoja
		  lea esi, [esi + 8]; me muevo a la siguiente hoja
		  lea ebx, [ebx + 4]	; me muevo al campo hijo derecho del nodo interno
		  mov [ebx], esi; pongo como hijo der del nodo a la hoja apuntada por esi
		  lea esi, [esi + 1]; me muevo al campo frecuencia de la hoja
		  add eax, [esi]; sumo las frecuencias
		  lea ebx, [ebx + 4]; me muevo al campo frecuencia del nodo interno
		  mov [ebx], eax; pongo en el campo frecuencia la suma de las frecuencias
		  lea ebx, [ebx + 4];me muevo al campo padre del nodo interno
		  mov [ebx], 0	; pongo el puntero al padre en null
		  lea esi, [esi + 8]; me muevo a la siguiente hoja
		  sub ecx, 2;le resto dos para indicar que avance dos lugares en las hojas
		  cmp ecx, 0;comparo si ya llegue a recorrer todas las hojas
		  je seguirNodos;en caso afirmativo termino el arbol uniendo nodos
armar_arbol:
		  mov ebx, esi	; pongo en ebx el puntero a la hoja actual
		  lea ebx, [ebx + 1] ; voy al campo frecuencia de la hoja
		  mov eax, [ebx]; pongo en eax la frecuencia de la hoja
		  mov ebx, edi; pongo en ebx el puntero al nodo interno de menor frecuencia
		  lea ebx, [ebx + 8]; voy al campo frecuencia de este nodo interno
		  cmp eax, [ebx]; comparo las frecuencias de la hoja actual y el nodo actual
		  jb compararh2n; comparo la segunda hoja con el nodo interno
		  lea ebx, [ebx + 8];voy al siguiente nodo
		  cmp [ebx], 0	;me fijo si el nodo existe
		  je crearPadrenh;si no existe crea un nodo con la hoja y el nodo anterior
		  lea ebx, [ebx + 8];voy a la frecuencia del nodo
		  cmp eax, [ebx] ; comparo las frecuencias de la hoja actual y del nodo actual
		  jb crearPadrenh ;crea un nodo con la hoja y el nodo anterior
		  jmp crearPadrenn;crea un nodo con los dos nodos internos
compararh2n:
		  mov eax, [ebx]; pongo en eax la frecuencia del nodo
		  lea ebx, [esi + 10] ; con ebx apunto a la frecuencia de la segunda hoja de 				menor frecuencia no visitada
		  cmp [ebx], eax; comparo la frecuencia de la hoja con la del nodo
		  jb crearPadrehh
		  jmp crearPadrenh 
crearPadrenh:
		  mov [ebx], esi; pongo como hijo izq del nodo a la hoja apuntada por esi
		  lea esi, [esi + 1] ; me muevo al campo frecuencia de la hoja
		  mov eax, [esi]; pongo en eax la frecuencia de la hoja
		  lea esi, [esi + 8]; me muevo a la siguiente hoja
		  lea ebx, [ebx + 4]	; me muevo al campo hijo derecho del nodo interno
		  mov [ebx], edi; pongo como hijo der del nodo al nodo apuntado por edi
		  lea edi, [edi + 8]; me muevo al campo frecuencia del nodo
		  add eax, [edi]; sumo las frecuencias
		  lea ebx, [ebx + 4]; me muevo al campo frecuencia del nodo interno
		  mov [ebx], eax; pongo en el campo frecuencia la suma de las frecuencias
		  lea ebx, [ebx + 4];me muevo al campo padre del nodo interno
		  mov [ebx], 0	; pongo el puntero al padre en null
		  lea edi, [edi + 4]; me muevo al siguiente nodo
		  dec ecx;le resto uno para indicar que avance un lugar en las hojas
		  dec edx;le resto uno para indicar que avance un lugar en los nodos
		  cmp ecx, 0;comparo si ya llegue a recorrer todas las hojas
		  je seguirNodos;en caso afirmativo termino el arbol uniendo nodos
		  jmp armar_arbol
crearPadrenn:
		  mov [ebx], edi; pongo como hijo izq del nodo al nodo apuntado por edi
		  lea edi, [edi + 8] ; me muevo al campo frecuencia del nodo
		  mov eax, [edi]; pongo en eax la frecuencia del nodo
		  lea edi, [edi + 4]; me muevo al siguiente nodo
		  lea ebx, [ebx + 4]	; me muevo al campo hijo derecho del nodo interno
		  mov [ebx], edi; pongo como hijo der del nodo al nodo apuntado por edi
		  lea edi, [edi + 8]; me muevo al campo frecuencia del nodo
		  add eax, [edi]; sumo las frecuencias
		  lea ebx, [ebx + 4]; me muevo al campo frecuencia del nodo interno
		  mov [ebx], eax; pongo en el campo frecuencia la suma de las frecuencias
		  lea ebx, [ebx + 4];me muevo al campo padre del nodo interno
		  mov [ebx], 0	; pongo el puntero al padre en null
		  lea edi, [edi + 4]; me muevo al siguiente nodo
		  sub edx, 2;le resto dos para indicar que avance dos lugares en los nodos
		  cmp ecx, 0;comparo si ya llegue a recorrer todas las hojas
		  je seguirNodos;en caso afirmativo termino el arbol uniendo nodos
		  jmp armar_arbol
seguirNodos:
		  cmp edx, 0
		  je armar_tabla
		  jmp crearPadrenn
armar_tabla:
                  mov eax, tam;pongo en eax la cantidad de simbolos distintos
		  mov edx, eax;pongo en edx la cantidad de simbolos distintos
                  mov ebx, 6;pongo en ebx el tamaño de cada nodo
                  mul ebx;pongo en eax la cantidad de memoria a pedir 
                  push eax
                  call malloc
                  add esp, 4;rebalanceo la pila
                  cmp eax, 0;me fijo si me pudo dar memoria
                  jne llenar_tabla; si pudo lleno la tabla
                  jmp mem_error;sino envio un error de memoria
llenar_tabla:
                  mov esi, ptr_hojas;pongo en esi el puntero a las hojas
                  mov edi, eax; pongo en esi la estructura a devolver
		  mov eax, edx;pongo en eax la cantidad de simbolos distintos
ag_simbolo:
                  cmp eax, 0;me fijo si ya recorri todos los simbolos
                  je borrar_arbol; en este caso libero la memoria del arbol de huffman

                  mov bl, [esi];pongo en bl el simbolo de la hoja actual
                  mov [edi], bl;pongo en la tabla a devolver el simbolo
                  lea edi, [edi + 1]; y me posiciono en la longitud del codigo

                  xor ebx, ebx; limpio ebx
                  xor ecx, ecx; limpio ecx
ciclo:
                  lea esi, [esi + 5]; voy al puntero al padre de la hoja
                  lea edx, [esi];pongo en edx la direccion del padre de la hoja
                  cmp [edx], esi; me fijo si la hoja es el hijo izquierdo
                  je left;en caso afirmativo agrego un cero en el codigo e incremento la longitud
                  inc cl;sino incremento la longitud del codigo
                  shl ebx, 1; me corro un bit para la izquierda 
                  add ebx, 1; y pongo un uno en el bit menos significarivo
seguir:
                  lea edx, [edx + 12];voy al puntero al padre
                  cmp [edx], 0; y lo comparo con null
                  je setear_fila;si es null seteo la fila
                  jmp ciclo;sino sigo con el ciclo
left:
                  inc cl;incremento la longitud del codigo
                  shl ebx, 1;me corro un bit para la izquierda 
setear_fila:
                  mov [edi], cl;pongo en longcod la longitud del codigo
                  lea edi, [edi + 1];me muevo al campo cod
                  mov [edi], ebx;pongo en cod el codigo
                  lea edi, [edi + 4]; y avanzo a la siguiente fila de la tabla 
                  dec eax; decremento eax
                  jmp ag_simbolo; y voy a agregar simbolo
borrar_arbol:
		  mov esi, ptr_hojas;pongo en esi el puntero a las hojas
		  push esi
		  call free;libero la memoria de las hojas
		  mov esi, ptr_nodos; pòngo en esi el puntero a los nodos internos
		  push esi
		  call free; libero la memoria de los nodos internos
		  mov eax, edi; pongo en eax la tabla de codigos
		  jmp fin
mem_error:
                  mov eax, -1	;pongo en eax un -1 para indicar error de memoria

fin:
                  pop ebx
                  pop esi
                  pop edi
		  add esp. 8
                  pop ebp
                  ret