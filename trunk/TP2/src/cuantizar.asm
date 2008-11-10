global cuantizar

section .text

%define b [ebp + 8]
%define q [ebp + 12]

cuantizar:
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ebx

    mov esi, q
    mov edi, b
    
    mov ecx, 8
    xor ebx, ebx
    xor eax, eax
div:    
    cmp ecx, 0
    je fin

    movaps xmm0, [esi + ebx]
    movaps xmm2, [edi + ebx]
    add ebx, 16
    movaps xmm1, [esi + ebx]
    movaps xmm3, [edi + ebx]
    add ebx, 16

    divps xmm0, xmm2
    divps xmm1, xmm3
    cvtps2dq xmm0, xmm0
    cvtps2dq xmm1, xmm1

    movaps xmm4, [esi + ebx]
    movaps xmm6, [edi + ebx]
    add ebx, 16
    movaps xmm5, [esi + ebx]
    movaps xmm7, [edi + ebx]
    add ebx, 16

    divps xmm4, xmm6
    divps xmm5, xmm7
    cvtps2dq xmm4, xmm4
    cvtps2dq xmm5, xmm5

    movaps [edi + eax], xmm0
    add eax, 16
    movaps [edi + eax], xmm1
    add eax, 16
    movaps [edi + eax], xmm4
    add eax, 16
    movaps [edi + eax], xmm5
    add eax, 16
    sub ecx, 2
    jmp div
fin:
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret