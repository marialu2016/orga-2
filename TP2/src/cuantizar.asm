global cuantizar

extern malloc

section .text

%define b [ebp + 8]
%define q [ebp + 12]
%define res [ebp - 4]

%macro cargar 0
    movq xmm0, [esi + edx]
    add edx, 8
    movq xmm4, [esi + edx]
    add edx, 8
    pshufd xmm0, xmm0, 01001111b
    addd xmm0, xmm4

    movq xmm1, [esi + edx]
    add edx, 8
    movq xmm5, [esi + edx]
    add edx, 8
    pshufd xmm1, xmm1, 01001111b
    addd xmm1, xmm5

    cvtdq2ps xmm0, xmm0
    cvtdq2ps xmm1, xmm1;
%endmacro

%macro dividir 0

    movups xmm2, [edi + ebx]
    add ebx, 16

    movups xmm3, [edi + ebx]
    add ebx, 16

    divps xmm2, xmm0
    divps xmm3, xmm1
%endmacro

%macro guardar 0

    cvtps2dq xmm2, xmm2
    cvtps2dq xmm3, xmm3
    pxor xmm4, xmm4
    pxor xmm5, xmm5
    packssdw xmm2, xmm4
    packssdw xmm3, xmm5

    movq [eax + edx], xmm2
    add edx, 8
    movq [eax + edx], xmm3
    add edx, 8
%endmacro

cuantizar:
    push ebp
    mov ebp, esp
    sub esp, 4
    push edi
    push esi
    push ebx

    mov eax, 128
    push eax
    call malloc
    add esp, 4
    mov res, eax

    mov esi, q
    mov edi, b
    xor ecx, ecx
    xor edx, edx
    xor ebx, ebx

    cargar
    dividir
    guardar

    cargar
    dividir
    guardar

    cargar
    dividir
    guardar

    cargar
    dividir
    guardar

    dividir
    guardar

    cargar
    dividir
    guardar

    cargar
    dividir
    guardar

    cargar
    dividir
    guardar

fin:
    mov eax, res
    pop ebx
    pop esi
    pop edi
    add esp, 4
    pop ebp
    ret