global armarTablaCodigos

extern malloc
extern free
extern insertionSort

section .text

%define t_apariciones [ebp + 8]
%define tam [ebp + 12]

%define apar_simb 0
%define apar_frec 4
%define apar_sig 8

%define ptr_hojas [ebp - 4]
%define ptr_nodos [ebp - 8]
%define ptr_agregar [ebp - 12]
%define tabla [ebp - 16]
%define cuantosFaltan [ebp - 20]
%define cantBits [ebp - 24]

%define hoja_simb 0
%define hoja_frec 1
%define hoja_padre 5
%define hoja_sig 9

%define nodo_izq 0
%define nodo_der 4
%define nodo_frec 8
%define nodo_padre 12
%define nodo_sig 16

%define tabla_simb 0
%define tabla_longcod 1
%define tabla_cod 4
%define tabla_sig 8

armarTablaCodigos:
                  push ebp
                  mov ebp, esp
		  sub esp, 24
                  push edi
                  push esi
                  push ebx 

                  mov esi, t_apariciones;pongo en esi el puntero a la tabla de cantidad de apariciones
		  mov eax, tam
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
		  mov ecx, tam
		  mov eax, ptr_hojas; pongo en eax el puntero a las hojas
ciclo_I:
		  xor edx,edx
                  mov dl, [esi + apar_simb]	;pongo en dl el simbolo
                  mov [eax + hoja_simb], dl	;pongo en la hoja a la que estoy apuntando el caracter 
                  mov edx, [esi + apar_frec]	; pongo en edx la frecuencia del simbolo
                  mov [eax + hoja_frec], edx	; pongo en la hoja que estoy apuntando la frecuencia
                  mov dword [eax + hoja_padre], 0	; porque voy a poner el puntero al padre en null
                  lea esi, [esi + apar_sig]	; me muevo al siguiente simbolo
                  lea eax, [eax + hoja_sig]	; me muevo a la siguiente hoja
                  loop ciclo_I		; repito esto hasta llegar al final de la tabla

		  mov eax, tam	;pongo en eax la cantidad de hojas
		  dec eax	;le resto 1 porque la cantidad de nodos internos es igual a la cantidad de hojas - 1
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
		  mov dword [ebx + nodo_izq], 0	; pongo el puntero al hijo izq en null
		  mov dword [ebx + nodo_der], 0	; pongo el puntero al hijo der en null
		  mov dword [ebx + nodo_frec], 0	; pongo la frecuencia en cero
		  mov dword [ebx + nodo_padre], 0	; pongo el puntero al padre en null
		  lea ebx, [ebx + nodo_sig]	;avanzo al siguiente nodo
		  loop inicializarNodos	;repito esto hasta llegar al final de la estructura

		  mov esi, ptr_hojas	; pongo en esi el puntero a las hojas
		  mov edi, eax	; pongo en edi el puntero a los nodos internos
		  mov ecx, tam	; pongo en ecx la cantidad de hojas
		  mov edx, ecx
		  dec edx	; y en edx la cantidad de nodos internos
		  mov ptr_agregar, edi
crearPadrehh:
		  mov ebx, ptr_agregar	; pongo en ebx el puntero al ultimo nodo interno
		  mov [ebx + nodo_izq], esi; pongo como hijo izq del nodo a la hoja apuntada por esi
		  mov eax, [esi + hoja_frec]; pongo en eax la frecuencia de la hoja
		  mov [esi + hoja_padre], ebx; pongo como padre al nodo
		  lea esi, [esi + hoja_sig]; me muevo a la siguiente hoja
		  mov [ebx + nodo_der], esi; pongo como hijo der del nodo a la hoja apuntada por esi
		  add eax, [esi + hoja_frec]; sumo las frecuencias
		  mov [ebx + nodo_frec], eax; pongo en el campo frecuencia la suma de las frecuencias
		  mov dword [ebx + nodo_padre], 0	; pongo el puntero al padre en null
		  mov [esi + hoja_padre], ebx; pongo como padre al nodo
		  lea esi, [esi + hoja_sig]; me muevo a la siguiente hoja
		  add dword ptr_agregar,16 ;apunto al lugar donde estara el siguiente nodo 
		  sub ecx, 2;le resto dos para indicar que avance dos lugares en las hojas
		  cmp ecx, 0;comparo si ya llegue a recorrer todas las hojas
		  je seguirNodos;en caso afirmativo termino el arbol uniendo nodos
armar_arbol:
		  mov ebx, esi	; pongo en ebx el puntero a la hoja actual
		  mov eax, [ebx + hoja_frec]; pongo en eax la frecuencia de la hoja
		  mov ebx, edi; pongo en ebx el puntero al nodo interno de menor frecuencia
		  cmp eax, [ebx + nodo_frec]; comparo las frecuencias de la hoja actual y el nodo actual
		  jbe compararh2n; comparo la segunda hoja con el nodo interno
		  cmp dword [ebx + nodo_sig], 0	;me fijo si el nodo existe
		  je crearPadrenh;si no existe crea un nodo con la hoja y el nodo anterior
		  lea ebx, [ebx + nodo_sig]; si existe me posiciono en este nodo
		  cmp eax, [ebx + nodo_frec] ; comparo las frecuencias de la hoja actual y del nodo actual
		  jb crearPadrenh ;crea un nodo con la hoja y el nodo anterior
		  jmp crearPadrenn;crea un nodo con los dos nodos internos
compararh2n:
		  mov eax, [ebx]; pongo en eax la frecuencia del nodo
		  lea ebx, [ebx + hoja_sig] ; avanzo a la siguiente hoja
		  mov ebx, [esi + hoja_frec] ; con ebx apunto a la frecuencia de la segunda hoja de menor frecuencia no visitada
		  cmp ebx, eax; comparo la frecuencia de la hoja con la del nodo
		  jbe crearPadrehh
		  jmp crearPadrenh 
seguirNodos:
		  cmp edx, 1
		  je armar_tabla
		  jmp crearPadrenn
crearPadrenh:
		  mov ebx, ptr_agregar	; pongo en ebx el puntero al ultimo nodo interno
		  mov [ebx + nodo_izq], esi; pongo como hijo izq del nodo a la hoja apuntada por esi
		  mov eax, [esi + hoja_frec]; pongo en eax la frecuencia de la hoja
		  mov [esi + hoja_padre], ebx; pongo como padre al nodo
		  lea esi, [esi + hoja_sig]; me muevo a la siguiente hoja
		  mov [ebx + nodo_der], edi; pongo como hijo der del nodo al nodo apuntado por edi
		  add eax, [edi + nodo_frec]; sumo las frecuencias
		  mov [ebx + nodo_frec], eax; pongo en el campo frecuencia la suma de las frecuencias
		  mov dword [ebx + nodo_padre], 0	; pongo el puntero al padre en null
		  mov [edi + nodo_padre], ebx; pongo como padre al nodo
		  lea edi, [edi + nodo_sig]; me muevo al siguiente nodo
		  add dword ptr_agregar,16 ;apunto al lugar donde estara el siguiente nodo 
		  dec ecx;le resto uno para indicar que avance un lugar en las hojas
		  dec edx;le resto uno para indicar que avance un lugar en los nodos
		  cmp ecx, 0;comparo si ya llegue a recorrer todas las hojas
		  je seguirNodos;en caso afirmativo termino el arbol uniendo nodos
		  jmp armar_arbol
crearPadrenn:
		  mov ebx, ptr_agregar	; pongo en ebx el puntero al ultimo nodo interno
		  mov [ebx + nodo_izq], edi; pongo como hijo izq del nodo al nodo apuntado por edi
		  mov eax, [edi + nodo_frec]; pongo en eax la frecuencia del nodo
		  mov [edi + nodo_padre], ebx; pongo como padre al nodo
		  lea edi, [edi + nodo_sig]; me muevo al siguiente nodo
		  mov [ebx + nodo_der], edi; pongo como hijo der del nodo al nodo apuntado por edi
		  add eax, [edi + nodo_frec]; sumo las frecuencias
		  mov [ebx + nodo_frec], eax; pongo en el campo frecuencia la suma de las frecuencias
		  mov dword [ebx + nodo_padre], 0	; pongo el puntero al padre en null
		  mov [edi + nodo_padre], ebx; pongo como padre al nodo
		  lea edi, [edi + nodo_sig]; me muevo al siguiente nodo
		  add dword ptr_agregar,16 ;apunto al lugar donde estara el siguiente nodo 
		  sub edx, 2;le resto dos para indicar que avance dos lugares en los nodos
		  cmp ecx, 0;comparo si ya llegue a recorrer todas las hojas
		  je seguirNodos;en caso afirmativo termino el arbol uniendo nodos
		  jmp armar_arbol
armar_tabla:
                  mov eax, tam;pongo en eax la cantidad de simbolos distintos
                  mov ebx, 8;pongo en ebx el tamaño de cada nodo
                  mul ebx;pongo en eax la cantidad de memoria a pedir 
                  push eax
                  call malloc
                  add esp, 4;rebalanceo la pila
                  cmp eax, 0;me fijo si me pudo dar memoria
                  jne llenar_tabla; si pudo lleno la tabla
                  jmp mem_error;sino envio un error de memoria
llenar_tabla:
		  mov tabla, eax
                  mov esi, ptr_hojas;pongo en esi el puntero a las hojas
                  mov edi, eax; pongo en edi la estructura a devolver
		  mov eax, tam;pongo en eax la cantidad de simbolos distintos
		  mov cuantosFaltan, eax
		  mov eax, esi
ag_simbolo:
                  cmp dword cuantosFaltan , 0;me fijo si ya recorri todos los simbolos
                  je borrar_arbol; en este caso libero la memoria del arbol de huffman
		  xor ebx,ebx
                  mov bl, [esi + hoja_simb];pongo en bl el simbolo de la hoja actual
                  mov [edi + tabla_simb], bl;pongo en la tabla a devolver el simbolo

                  xor ebx, ebx; limpio ebx
                  xor ecx, ecx; limpio ecx
		  mov edx, [esi + hoja_padre];pongo en edx la direccion del padre de la hoja
ciclo:
                  cmp eax, [edx + nodo_izq]; me fijo si la hoja es el hijo izquierdo
                  je left;en caso afirmativo agrego un cero en el codigo e incremento la longitud
                  inc cl;sino incremento la longitud del codigo
                  shl ebx, 1; me corro un bit para la izquierda 
                  add ebx, 1; y pongo un uno en el bit menos significarivo
seguir:
		  lea eax, [edx]
                  mov edx, [edx + nodo_padre];voy al puntero al padre
                  cmp edx, 0; y lo comparo con null
                  je setear_fila;si es null seteo la fila
                  jmp ciclo;sino sigo con el ciclo
left:
                  inc cl;incremento la longitud del codigo
                  shl ebx, 1;me corro un bit para la izquierda 
		  jmp seguir
setear_fila:
                  mov [edi + tabla_longcod], cl;pongo en longcod la longitud del codigo
		  mov cantBits, ecx
		  jmp invertir
next:
                  mov [edi + tabla_cod], ecx;pongo en cod el codigo
                  lea edi, [edi + tabla_sig]; y avanzo a la siguiente fila de la tabla 
                  dec dword cuantosFaltan; decremento eax
		  lea esi, [esi + hoja_sig]
		  lea eax, [esi]; voy a la siguiente hoja
                  jmp ag_simbolo; y voy a agregar simbolo
invertir:
		  xor ecx, ecx
cicloinv:
		  clc
		  dec dword cantBits
		  shr ebx, 1
		  jc ponerUno
		  shl ecx, 1
volver:
		  cmp dword cantBits, 0
		  jne cicloinv
		  jmp next
ponerUno:
		  shl ecx, 1
		  add ecx, 1
		  jmp volver
borrar_arbol:
		  mov esi, ptr_hojas;pongo en esi el puntero a las hojas
		  push esi
		  call free;libero la memoria de las hojas
		  add esp, 4
		  mov esi, ptr_nodos; pòngo en esi el puntero a los nodos internos
		  push esi
		  call free; libero la memoria de los nodos internos
		  add esp, 4
		  mov eax, tabla; pongo en eax la tabla de codigos
		  jmp fin
mem_error:
                  mov eax, 0	;pongo en eax un 0 para indicar error de memoria

fin:
                  pop ebx
                  pop esi
                  pop edi
		  add esp, 24
                  pop ebp
                  ret
