global dividirBloques

extern malloc

section .text

%define canal [ebp + 8]
%define i [ebp + 12]
%define j [ebp + 16]
%define prox_fila [ebp + 20]

%define resultado [ebp - 4]
%define prox_col 4

dividirBloques:
    push ebp
    mov ebp, esp
    sub esp, 4
    push edi
    push esi
    push ebx

    mov esi, canal

    mov eax, 64
    push eax
    call malloc

    mov resultado, eax
    mov edi, eax

    mov eax, prox_fila
    mul i
    lea esi, [esi + eax]

    mov eax, prox_col
    mul j
    mov ecx, 8
    mov edx, 8
cicloCol:
    cmp ecx, 0
    je cicloFila

    mov ebx, [esi + eax]
    mov [edi], ebx
    inc eax
    lea edi, [edi +1]
    dec ecx
    jmp cicloCol

cicloFila:
    cmp edx, 0
    je fin

    lea esi, [esi + prox_fila]

    mov eax, prox_col
    mul j
    dec edx
    jmp cicloCol

fin:
    mov eax, resultado
    pop ebx
    pop esi
    pop edi
    add esp, 4
    pop ebp
    ret