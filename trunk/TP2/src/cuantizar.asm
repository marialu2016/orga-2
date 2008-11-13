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
divt:
    cmp ecx, 0
    je termine

    movups xmm0, [esi + ebx]
    movups xmm2, [edi + ebx]
    add ebx, 16
    movups xmm1, [esi + ebx]
    movups xmm3, [edi + ebx]
    add ebx, 16

    divps xmm0, xmm2
    divps xmm1, xmm3
    cvtps2dq xmm0, xmm0
    cvtps2dq xmm1, xmm1
    jmp seguir
termine:
    jmp fin
seguir:
    movups xmm4, [esi + ebx]
    movups xmm6, [edi + ebx]
    add ebx, 16
    movups xmm5, [esi + ebx]
    movups xmm7, [edi + ebx]
    add ebx, 16

    divps xmm4, xmm6
    divps xmm5, xmm7
    cvtps2dq xmm4, xmm4
    cvtps2dq xmm5, xmm5

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