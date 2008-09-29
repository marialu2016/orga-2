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
                  mov eax, tam
                  mov edx, eax
                  mov ebx, 3
                  mul ebx
                  push eax
                  call malloc
                  add esp, 4
                  cmp eax, 0
                  jne llenar_tabla
                  jmp mem_error
llenar_tabla:
                  mov esi, base
                  mov edi, eax
ag_simbolo:
                  cmp edx, 0
                  je borrar_arbol
                  
                  mov bl, [esi]
                  mov [edi], bl
                  lea edi, [edi + 1]

                  xor ebx, ebx
                  xor ecx, ecx
ciclo:
                  mov edx, esi
                  lea edx, [edx + 5]
                  lea edx, [edx]
                  cmp [edx], esi
                  je left
                  inc cl
                  shl bl, 1
                  add bl, 1
seguir:
                  lea edx, [edx + 12]
                  cmp [edx], 0
                  je setear_fila
                  jmp ciclo
left:
                  inc cl
                  shl bl, 1
setear_fila:
                  mov [edi], cl
                  lea edi, [edi + 1]
                  mov [edi], bl
                  lea edi, [edi + 1]
                  dec edx
                  jmp ag_simbolo
borrar_arbol:
                  mov eax, edi; guardo la dirreccion de la tabla a devolver

mem_error:
                  mov eax, -1
                  jmp fin
fin:
                  pop ebx
                  pop esi
                  pop edi
                  pop ebp
                  ret
