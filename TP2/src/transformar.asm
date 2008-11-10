global transformar

extern transpuesta
extern malloc
extern free

section .text

%define dct [ebp + 8]
%define b [ebp + 12]

%define resultado [ebp - 4]

transformar:
    push ebp
    mov ebp, esp
    sub esp, 4
    push edi
    push esi
    push ebx

    mov eax, 256
    push eax
    call malloc
    add esp, 4
    mov resultado, eax

    mov esi, dct
    mov edi, b
    mov ecx, 8
    mov edx, 8
    xor ebx, ebx

cicloCol:
    cmp ecx, 0
    je mult1

    movaps xmm1, [esi]
    movaps xmm2, [esi + 16]
    movaps xmm3, [edi + ebx]
    add ebx, 16
    movaps xmm4, [edi + ebx]
    add ebx, 16
    mulps xmm3, xmm1
    mulps xmm4, xmm2
    addps xmm3, xmm4
    shufps xmm4, xmm3, 10110000
    addps xmm3, xmm4
    shufps xmm4, xmm3, 01000000
    addps xmm3, xmm4
    movss [eax], xmm3
    lea eax, [eax + 4]

    movaps xmm5, [edi + ebx]
    add ebx, 16
    movaps xmm6, [edi + ebx]
    add ebx, 16
    mulps xmm5, xmm1
    mulps xmm6, xmm2
    addps xmm5, xmm6
    shufps xmm6, xmm5, 10110000
    addps xmm5, xmm6
    shufps xmm6, xmm5, 01000000
    addps xmm5, xmm6
    movss [eax], xmm5
    lea eax, [eax + 4]

    sub ecx, 2

mult1:
    cmp edx, 0
    je seguir
    dec edx
    lea esi, [esi + 32]
    xor ebx, ebx
    jmp cicloCol

seguir:
    mov esi, resultado
    mov edi, dct
    mov eax, b
    mov ecx, 8
    mov edx,8

cicloCol2:
    cmp ecx, 0
    je mult2

    movaps xmm1, [esi]
    movaps xmm2, [esi + 16]
    movaps xmm3, [edi + ebx]
    add ebx, 16
    movaps xmm4, [edi + ebx]
    add ebx, 16
    mulps xmm3, xmm1
    mulps xmm4, xmm2
    addps xmm3, xmm4
    shufps xmm4, xmm3, 10110000
    addps xmm3, xmm4
    shufps xmm4, xmm3, 01000000
    addps xmm3, xmm4
    movss [eax], xmm3
    lea eax, [eax + 4]

    movaps xmm5, [edi + ebx]
    add ebx, 16
    movaps xmm6, [edi + ebx]
    add ebx, 16
    mulps xmm5, xmm1
    mulps xmm6, xmm2
    addps xmm5, xmm6
    shufps xmm6, xmm5, 10110000
    addps xmm5, xmm6
    shufps xmm6, xmm5, 01000000
    addps xmm5, xmm6
    movss [eax], xmm5
    lea eax, [eax + 4]

    sub ecx, 2

mult2:
    cmp edx, 0
    je terminar
    dec edx
    lea esi, [esi + 32]
    xor ebx, ebx
    jmp cicloCol2

terminar:
	mov eax, resultado
	push eax
	call free
    
fin:
    pop ebx
    pop esi
    pop edi
    add esp, 4
    pop ebp
    ret