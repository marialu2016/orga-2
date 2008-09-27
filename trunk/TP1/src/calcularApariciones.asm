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
                    
                    mov esi, buffer	;pongo en esi la direccion del buffer con los datos de la imagen

                    mov eax, 1024	;pongo en eax la cantidad de memoria que voy a pedir
                    push eax
                    call malloc
                    add esp, 4	;balanceo la pila
                    cmp eax,0	;me fijo si pudo darme la memoria
                    jne mem_ok
                    jmp mem_error
mem_ok:
                    mov edi, eax	;copio el puntero a la memoria que me dio malloc en edi
                    xor ebx, ebx
                    mov ecx, 256
inicializar:
                    mov [eax], ebx
                    lea eax, [eax + 4]
                    loop inicializar
                    
                    lea ebx, [esi + img_size]
                    mov ecx, [ebx]
                    
                    lea ebx [esi + img_begin]
                    mov edx, [ebx]
                    
                    lea esi, [esi + edx]
                    xor ebx, ebx
                    cld
ciclo:
                    lodsb
                    lea edx, [edi + al]
                    mov eax, [edx]
                    cmp eax, 0
                    je agregar_simbolo
                    mov eax, 1
                    add [edx], eax
                    loop ciclo
                    
                    mov eax, ebx
                    mul dword 5
                    push eax
                    call malloc
                    add esp, 4
                    cmp eax, 0
                    jne guardar
                    jmp mem_error
                    
guardar:
                    xor cl, cl
                    mov esi, edi; pongo la estructura auxiliar en esi
                    mov edi, eax; pongo la estructura a devolver en edi
                    mov edx, esi
                    mov eax, edi
ciclo_2:
                    mov ebx, [esi]
                    cmp ebx, 0
                    je sigo
                    mov [eax], cl
                    lea eax, [eax + 1]
                    mov [eax], ebx
                    lea eax, [eax + 4]
sigo:
                    lea edx, [edx + 4]
                    inc cl
                    cmp cl, 255
                    jb ciclo_2
                    mov eax, edi
                    mov edi, esi
                    push edi
                    call free
                    add esp, 4
                    jmp fin
agregar_simbolo:
                    mov [edx], 1
                    inc ebx

mem_error:
                    mov eax, -1
                    jmp fin

fin:
                    pop ebx
                    pop esi
                    pop edi
                    pop ebp
                    ret
