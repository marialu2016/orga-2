global descuantizar

extern malloc

section .text

%define b [ebp + 8]
%define q [ebp + 12]
%define res [ebp - 4]

%macro mult 0
    movq xmm0, [esi + ebx]
    add ebx, 8
    movq xmm2, [esi + ebx]
    add ebx, 8
    pshufd xmm0, xmm0, 01001111b 
    addps xmm0, xmm2
    cvtdq2ps xmm0, xmm0

    movq xmm1, [esi + ebx]
    add ebx, 8
    movq xmm3, [esi + ebx]
    add ebx, 8
    pshufd xmm1, xmm1, 01001111b
    addps xmm1, xmm3
    cvtdq2ps xmm1, xmm1

    pxor xmm4, xmm4
    movq xmm2, [edi + edx]
    add edx, 8
    punpcklwd xmm2, xmm4
    movq xmm3, [edi + edx]
    add edx, 8
    punpcklwd xmm3, xmm4
    cvtdq2ps xmm2, xmm2
    cvtdq2ps xmm3, xmm3

    mulps xmm0, xmm2
    mulps xmm1, xmm3
%endmacro

%macro guardar 0
    movups [eax], xmm0
    add eax, 16
    movups [eax], xmm1
    add eax, 16
%endmacro

descuantizar:
    push ebp
    mov ebp, esp
    sub esp, 4
    push edi
    push esi
    push ebx
    
    mov eax, 64
    shl eax, 2
    push eax
    call malloc
    add esp, 4
    mov res, eax

    mov esi, q
    mov edi, b
    
    xor ecx, ecx
    xor ebx, ebx
    xor eax, eax
    xor edx, edx

    mult
    guardar

    mult
    guardar

    mult
    guardar

    mult
    guardar

    mult
    guardar

    mult
    guardar

    mult
    guardar

    mult
    guardar

fin:
    pop ebx
    pop esi
    pop edi
    add esp, 4
    pop ebp
    ret