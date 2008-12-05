global decodificar

extern malloc

section .text

%define bitstream [ebp + 8]
%define offset [ebp + 12]

%define res [ebp - 4]
%define vlocal [ebp - 8]
%define ceros [ebp - 12]
%define contador [ebp - 16]

decodificar:
    push ebp
    mov ebp, esp
    sub esp, 16
    push edi
    push esi
    push ebx

    mov esi, bitstream
    mov edi, offset ; o podria ser mov esi, bitstream y luego lea esi, [esi + offset]
    mov edi, [edi]
    lea esi, [esi + edi]
    mov dword contador, 0
        
    mov eax, 64
    shl eax, 1
    push eax
    call malloc
    add esp, 4
    mov edi, eax
    mov res, eax

    xor ebx, ebx
    xor eax, eax  
    xor ecx, ecx 
    xor edx, edx 

    mov bx, [esi]
    mov [edi], bx
    lea esi, [esi + 2]
    xor ebx, ebx
    mov bl, [esi]
    mov ceros, bl
    lea esi, [esi + 1]
    add dword contador, 3
    mov ebx, 1
    ;lea edi, [edi + 2]

ciclo:
    cmp ebx, 13
    ja termine
    cmp ebx, 7
    ja post_ciclo
aqui:
    shr ebx,1
    jc preDiagAb
    shl ebx, 1
    mov ecx, ebx
    jmp diagArriba
preDiagAb:
    shl ebx, 1
    add ebx, 1
    mov edx, ebx
    jmp diagAbajo
post_ciclo:
    shr ebx,1
    jc preDiagAb2
    shl ebx, 1
    mov edx, ebx
    sub edx, 7
    mov ecx, 7
    jmp diagArriba
preDiagAb2:
    shl ebx,1
    add ebx,1
    mov ecx, ebx
    sub ecx, 7
    mov edx, 7

diagAbajo:
    mov eax, edx
    shl eax, 1
    shl ecx, 4
    add eax, ecx
    shr ecx, 4
    jmp agregar
termine:
    cmp byte ceros, 0
    jne ag_c
    mov vlocal, ebx
    xor ebx, ebx
    mov bx, [esi]
    mov [edi + eax], bx
    add dword contador, 2
    mov ebx, vlocal
    jmp fin
ag_c:
    mov word [edi + eax], 0
    dec byte ceros
    jmp fin
seguir:
    inc ecx ; me posiciono en la siguiente fila 
    dec edx ; me posiciono en la anterior columna
    ;add ecx, edx ; fila + columna 
    cmp ebx, ecx ; fila + columna <= diagActual
    jb ciclar
    ;sub ecx, edx
    cmp ecx, 7
    ja ciclar
    mov eax, ecx
    shl eax, 4
    shl edx, 1
    add eax, edx
    shr edx, 1
    jmp agregar
ciclar:
    xor ecx, ecx
    xor edx, edx
    inc ebx ; incremento la columna actual
    jmp ciclo
    
    
agregar:
    cmp byte ceros, 0
    jne ag_cero
    mov vlocal, ebx
    xor ebx, ebx
    mov bx, [esi]
    mov [edi + eax], bx
    lea esi, [esi + 2]
    xor ebx, ebx
    mov bl, [esi]
    mov ceros, bl
    lea esi, [esi + 1]
    add dword contador, 3
    mov ebx, vlocal
    jmp seguir
ag_cero:
    mov word [edi + eax], 0
    dec byte ceros
    jmp seguir

diagArriba:
    mov eax, ecx
    shl eax, 4
    shl edx, 1
    add eax, edx
    shr edx, 1
    jmp agregar2
seguir2:
    inc edx
    dec ecx
    ;add ecx, edx
    cmp ebx, edx
    jb ciclar2
    ;sub ecx, edx
    cmp edx, 7
    ja ciclar2
    mov eax, ecx
    shl eax, 4
    shl edx, 1
    add eax, edx
    shr edx, 1
    jmp agregar2
ciclar2:
    xor ecx, ecx
    xor edx, edx
    inc ebx
    jmp ciclo
    
    
agregar2:
    cmp byte ceros, 0
    jne ag_cero2
    mov vlocal, ebx
    xor ebx, ebx
    mov bx, [esi]
    mov [edi + eax], bx
    lea esi, [esi + 2]
    xor ebx, ebx
    mov bl, [esi]
    mov ceros, bl
    lea esi, [esi + 1]
    add dword contador, 3
    mov ebx, vlocal
    jmp seguir2
ag_cero2:
    mov dword [edi + eax], 0
    dec byte ceros
    jmp seguir2
    
     

fin:
    mov edi, offset
    mov ebx, contador
    mov [edi], ebx
    mov eax, res
    pop ebx
    pop esi
    pop edi
    add esp, 16
    pop ebp
    ret