global codificar

extern malloc
extern free

section .text

%define bq [ebp + 8]

%define resultado [ebp - 4]
%define ceros [ebp - 8]

codificar:
    push ebp
    mov ebp, esp
    sub esp, 8
    push edi
    push esi
    push ebx

    mov eax, 129
    push eax
    call malloc

    mov edi, eax
    mov resultado, eax
    mov esi, bq
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

    mov dx, [esi]
    mov [edi], dx
    add ebx, 2
    lea edi, [edi + 2]
    add eax, 1
    mov ecx, eax
    mov byte ceros, 0

ciclo:
    cmp eax, 7
    je ciclo2
    cmp word [esi + ebx], 0
    jne agregarAv
    add byte ceros, 1
avanzar:
    add ebx, 28
    cmp word [esi + ebx], 0
    jne agregarAv
    add byte ceros, 1
    loop avanzar

    add eax, 1
    mov ecx, eax
    add ebx, 16
    cmp word [esi + ebx], 0
    jne agregarAt
    add byte ceros, 1

atrasar:
    sub ebx, 28
    cmp word [esi + ebx], 0
    jne agregarAt
    add byte ceros, 1
    loop atrasar

    add eax, 1
    mov ecx, eax
    cmp word [esi + ebx], 0
    jne agregarC
    add byte ceros, 1
    add ebx, 2
    jmp ciclo

agregaAv:
    mov dl, ceros
    mov byte [edi], ceros
    mov dx , [esi + ebx]
    mov [edi + 1], dx
    lea edi, [edi + 2]
    add dword memapedir, 1
    jmp avanzar
   
agregarAt:
    mov dl, ceros
    mov byte [edi], ceros
    mov dx , [esi + ebx]
    mov [edi + 1], dx
    lea edi, [edi + 2]
    add dword memapedir, 1
    jmp atrasar

agregarC:
    mov dl, ceros
    mov byte [edi], ceros
    mov dx , [esi + ebx]
    mov [edi + 1], dx
    lea edi, [edi + 2]
    add dword memapedir, 1
    add ebx, 2
    jmp ciclo

ciclo2:
    cmp eax, 0
    je reservar
    cmp word [esi + ebx], 0
    jne agregarAt2
    add byte ceros, 1
atrasar2:
    sub ebx, 28
    cmp word [esi + ebx], 0
    jne agregarAt2
    add byte ceros, 1
    loop atrasar2

    sub eax, 1
    mov ecx, eax
    add ebx, 2
    cmp word [esi + ebx], 0
    jne agregarAv2
    add byte ceros, 1

avanzar2:
    add ebx, 28
    cmp word [esi + ebx], 0
    jne agregarAv2
    add byte ceros, 1
    loop avanzar2

    sub eax, 1
    mov ecx, eax
    add ebx, 16
    jmp ciclo2

agregaAv2:
    mov dl, ceros
    mov byte [edi], ceros
    mov dx , [esi + ebx]
    mov [edi + 1], dx
    lea edi, [edi + 2]
    add dword memapedir, 1
    jmp avanzar
   
agregarAt2:
    mov dl, ceros
    mov byte [edi], ceros
    mov dx , [esi + ebx]
    mov [edi + 1], dx
    lea edi, [edi + 2]
    add dword memapedir, 1
    jmp atrasar

reservar:
    
    
    
fin:
    pop ebx
    pop esi
    pop edi
    add esp, 8
    pop ebp
    ret