global armarTablaCodigos

extern malloc
extern free

section .text

%define t_apariciones [ebp + 8]
%define tam_tabla [ebp - 4]
%define izq [ebp - 8]
%define der [ebp - 12]
%define base [ebp - 16]
%define r_der [ebp - 20]
%define img_size

armarTablaCodigos:
                  push ebp
                  mov ebp, esp
                  sub esp, 20
                  push edi
                  push esi
                  push ebx

                  mov esi, t_apariciones
                  mov eax, [esi]; pongo en eax la cantidad de simbolos que tendra la tabla
                  mov tam, eax; guardo una copia de la cantidad de simbolos que tendra la tabla
                  mov ebx, 9
                  mul ebx
                  push eax
                  call malloc
                  add esp, 4
                  cmp eax, 0
                  jne inicializar
                  jmp mem_error
inicializar:
                  mov base, eax
                  mov edi, eax
                  mov ecx, tam
                  lea esi, [esi + 4]
ciclo_I:
                  mov dl, [esi]
                  mov [eax], dl
                  lea eax, [eax + 1]
                  lea esi, [esi + 1]
                  mov edx, [esi]
                  mov [eax], edx
                  lea eax, [eax + 4]
                  lea esi, [esi + 4]
                  mov edx, 0
                  mov [eax], edx
                  lea eax, [eax + 4]
                  loop ciclo_I

                  xor edx, edx
                  mov r_der, edx
armar_arbol:
                  mov eax, img_size
                  mov esi, base
                  mov edi, esi
                  xor ecx, ecx
buscar_min:
                  lea esi, [esi + 5]
                  mov edx, [esi]
                  cmp edx, 0
                  jne subo ; si el nodo que estoy visitando ya es hijo de otro nodo, tengo que subir a ver si el padre tine frecuencia minima
                  mov esi, edi
                  lea esi, [esi + 1]
                  mov ebx, [esi]
                  cmp ebx, eax
                  ja sigo ; si el simbolo que estoy visitando no tiene frecuencia mas chica que el minimo hasta el momento sigo con el proximo
                  lea esi, [esi + 8]
                  mov edx, 1
                  cmp r_der, edx
                  je rama_der
sub_min:
                  mov izq, edi
prox:
                  mov edi, esi
                  mov eax, ebx
                  inc ecx
                  cmp eax, img_size
                  je armar_tabla
                  cmp ecx, tam
                  jae armar_arbol
                  jmp buscar_min
rama_der:
                  mov der, edi
                  mov edi, esi
                  mov eax, ebx
                  inc ecx
                  cmp ecx, tam
                  jae sub_arbol
                  jmp buscar_min
sigo:
                  lea esi,[esi + 8]
                  jmp prox
subo:
                  lea edx, [edx + 12]
                  mov ebx, edx
                  mov edx, [ebx]
                  cmp edx, 0
                  jne subo
                  lea esi, [esi + 4]
                  lea edx, [edx - 4]
                  mov ebx, [edx]
                  cmp ebx, eax
                  jb sub_min
                  jmp prox
sub_arbol:
                  mov eax, 16
                  push eax
                  call malloc
                  add esp, 4
                  cmp eax, 0
                  jne crear_nodo
                  jmp mem_error
crear_nodo:
                  mov edx, izq
                  mov [eax], edx
                  lea edi, [eax + 4]
                  mov edx, der
                  mov [edi], edx
                  lea edi, [edi + 4]
                  
                  mov edx, izq
                  lea edx, [edx + 1]
                  mov ebx, [edx]
                  lea edx, [edx + 4]
                  mov [edx], eax
                  
                  mov edx, der
                  lea edx, [edx + 1]
                  mov ecx, [edx]
                  lea edx, [edx + 4]
                  mov [edx], eax
                  
                  add ebx, ecx
                  mov [edi], ebx
                  lea edi, [edi + 4]
                  mov ebx, 0
                  mov [edi], ebx

                  mov ebx, 1
                  mov r_der, ebx
                  jmp armar_arbol
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

mem_error:
                  mov eax, -1
                  jmp fin
fin:
                  pop ebx
                  pop esi
                  pop edi
                  pop ebp
                  ret
