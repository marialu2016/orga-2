global transpuesta

extern malloc

section .text

%define matriz [ebp + 8]

%define resultado [ebp - 4]
%define desp [ebp - 8]

%define prox_fila 32
%define prox_col 4

transpuesta:
    push ebp
    mov ebp, esp
    sub esp, 8
    push edi
    push esi
    push ebx

    mov esi, matriz
    mov eax, 256
    push eax
    call malloc

    mov resultado, eax
    mov edi, eax
    mov ecx, 8
    mov edx, 8
cicloCol:
    cmp edx, 0
    je cicloFila
    mov eax, 8
    sub eax, edx
    shl eax, 2
    mov ebx, [esi +  eax]
    shl eax, 3
    mov desp, eax
    mov eax, 8
    sub eax, ecx
    shl eax, 2
    add eax, desp
    mov [edi + eax], ebx
    dec edx
    jmp cicloCol

cicloFila:
    cmp ecx, 0
    je fin
    dec ecx
    mov edx, 8
    lea esi, [esi + prox_fila]
    jmp cicloCol
fin:
    mov eax, resultado
    pop ebx
    pop esi
    pop edi
    add esp, 8
    pop ebp
    ret