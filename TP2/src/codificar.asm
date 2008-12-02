global codificar

extern malloc
extern free

section .text

%define bq [ebp + 8]
%define tam [ebp + 12]

%define resultado [ebp - 4]
%define ceros [ebp - 8]
%define memapedir [ebp - 12]
%define n_col [ebp - 16]

codificar:
    push ebp
    mov ebp, esp
    sub esp, 16
    push edi
    push esi
    push ebx

    mov eax, 191
    push eax
    call malloc
    add esp, 4

    mov edi, eax ;pre-bitstream
    mov resultado, eax
    mov esi, bq ;matriz cuantizada
    xor eax, eax ;lo uso para redireccionarme
    xor ebx, ebx ;contador de que diagonal estoy
    xor ecx, ecx ;contador filas 
    xor edx, edx ; contador columnas y para guardar el elemento
    mov dword memapedir, 0
    
    mov dx, [esi] ;primer elemento
    mov [edi], dx ;copio primer elemento al bitstream
    ;add ebx, 2 
    lea edi, [edi + 2]
    add dword memapedir, 2
    ;add eax, 1
    ;mov ecx, eax
    mov byte ceros, 0

    mov ebx, 1
    xor edx, edx
    xor ecx, ecx

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
    jmp genio
termine:
    mov dl, ceros
    mov [edi], dl
    add eax, 2
    mov dx , [esi + eax]
    mov [edi + 1], dx
    lea edi, [edi + 3]
    add dword memapedir, 3
    jmp reservar
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
    jmp genio
ciclar:
    xor ecx, ecx
    xor edx, edx
    inc ebx ; incremento la columna actual
    jmp ciclo
genio:
    cmp word [esi + eax], 0
    je aumCeros
    
    mov n_col, edx
    xor edx, edx
    mov dl, ceros
    mov [edi], dl
    mov dx , [esi + eax]
    mov [edi + 1], dx
    lea edi, [edi + 3]
    add dword memapedir, 3
    mov byte ceros, 0
    mov edx, n_col
    jmp seguir
aumCeros:
    add byte ceros, 1
    jmp seguir

diagArriba:
    mov eax, ecx
    shl eax, 4
    shl edx, 1
    add eax, edx
    shr edx, 1
    jmp genio2
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
    jmp genio2
ciclar2:
    xor ecx, ecx
    xor edx, edx
    inc ebx
    jmp ciclo
genio2:
    cmp word [esi + eax], 0
    je aumCeros2

    mov n_col, edx
    xor edx, edx
    mov dl, ceros
    mov [edi], dl
    mov dx , [esi + eax]
    mov [edi + 1], dx
    lea edi, [edi + 3]
    add dword memapedir, 3
    mov byte ceros, 0
    mov edx, n_col
    jmp seguir2
aumCeros2:
    add byte ceros, 1
    jmp seguir2

reservar:
    mov eax, memapedir
    push eax
    call malloc
    add esp, 4

    mov edi, eax
    mov esi, resultado
    mov ecx, memapedir
    mov edx, tam
    mov [edx], ecx
    xor edx, edx

copiar:
    mov dl, [esi]
    mov [edi], dl
    lea esi, [esi + 1]
    lea edi, [edi + 1]
    loop copiar

    mov ebx, eax
    mov esi, resultado
    push esi
    call free
    add esp, 4
    mov eax, ebx 

fin:
    pop ebx
    pop esi
    pop edi
    add esp, 16
    pop ebp
    ret