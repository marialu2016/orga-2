global descuantizar

extern malloc

section .text

%define b [ebp + 8]
%define q [ebp + 12]
%define res [ebp - 4]

%macro mult 0
    movq xmm0, [esi + ebx]
    cvtdq2ps xmm0, xmm0
    add ebx, 8
    movq xmm2, [esi + ebx]
    cvtdq2ps xmm2, xmm2
    add ebx, 8
    movlhps xmm2, xmm0
    
    movq xmm1, [esi + ebx]
    add ebx, 8
    cvtdq2ps xmm1, xmm1
    movq xmm4, [esi + ebx]
    add ebx, 8
    cvtdq2ps xmm4, xmm4
    movlhps xmm4, xmm1
    
    pxor xmm5, xmm5
    movq xmm3, [edi + edx]
    add edx, 8
    pcmpgtw xmm5, xmm2 
    punpcklwd xmm3, xmm5
    cvtdq2ps xmm3, xmm3

    pxor xmm5, xmm5
    movq xmm6, [edi + edx]
    add edx, 8
    pcmpgtw xmm5, xmm6
    punpcklwd xmm6, xmm5
    cvtdq2ps xmm6, xmm6
    
    mulps xmm2, xmm3
    mulps xmm4, xmm6
%endmacro

%macro guardar 0
    movups [eax], xmm2
    add eax, 16
    movups [eax], xmm4
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
    mov eax, res
    pop ebx
    pop esi
    pop edi
    add esp, 4
    pop ebp
    ret