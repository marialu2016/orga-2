global cuantizar

extern malloc

section .text

%define b [ebp + 8]
%define q [ebp + 12]
%define res [ebp - 4]

%macro cargar 0
    movq xmm0, [esi + edx]
    add edx, 8
    cvtdq2ps xmm0, xmm0
    movq xmm4, [esi + edx]
    add edx, 8
    cvtdq2ps xmm4, xmm4
    movlhps xmm4, xmm0
    pshufd xmm4, xmm4, 01001110b
    
    movq xmm1, [esi + edx]
    add edx, 8
    cvtdq2ps xmm1, xmm1
    movq xmm5, [esi + edx]
    add edx, 8
    cvtdq2ps xmm5, xmm5
    movlhps xmm5, xmm1
    pshufd xmm5, xmm5, 01001110b
    
    
    movups xmm2, [edi + ebx]
    add ebx, 16

    movups xmm3, [edi + ebx]
    add ebx, 16
    
%endmacro

%macro dividir 0
    divps xmm2, xmm4
    divps xmm3, xmm5
%endmacro

%macro guardar 0

    cvtps2dq xmm2, xmm2
    cvtps2dq xmm3, xmm3
    pxor xmm4, xmm4
    pxor xmm5, xmm5
    packssdw xmm2, xmm4
    packssdw xmm3, xmm5

    movq [eax + ecx], xmm2
    add ecx, 8
    movq [eax + ecx], xmm3
    add ecx, 8
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

fin:
    mov eax, res
    pop ebx
    pop esi
    pop edi
    add esp, 4
    pop ebp
    ret