global descuantizar

section .text

%define b [ebp + 8]
%define q [ebp + 12]

descuantizar:
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
divt:    
    cmp ecx, 0
    je fin

    movups xmm0, [esi + ebx]
    movups xmm2, [edi + ebx]
    add ebx, 16
    movups xmm1, [esi + ebx]
    movups xmm3, [edi + ebx]
    add ebx, 16

    mulps xmm0, xmm2
    mulps xmm1, xmm3

    movups xmm4, [esi + ebx]
    movups xmm6, [edi + ebx]
    add ebx, 16
    movups xmm5, [esi + ebx]
    movups xmm7, [edi + ebx]
    add ebx, 16

    mulps xmm4, xmm6
    mulps xmm5, xmm7

    movups [edi + eax], xmm0
    add eax, 16
    movups [edi + eax], xmm1
    add eax, 16
    movups [edi + eax], xmm4
    add eax, 16
    movups [edi + eax], xmm5
    add eax, 16

    sub ecx, 2
    jmp divt
fin:
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret