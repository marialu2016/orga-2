global antiTransformar

extern transpuesta
extern malloc
extern free

section .text

%define b [ebp + 8]
%define dct [ebp + 12]

%define pre_res [ebp - 4]
%define resultado [ebp - 8]

%macro cargar 0
    movups xmm1, [esi + edx]
    add edx, 16
    movups xmm2, [esi + edx]
    add edx, 16
%endmacro

%macro cargar2 0
    movups xmm3, [edi + ebx]
    add ebx, 16
    movups xmm4, [edi + ebx]
    add ebx, 16
%endmacro

%macro mult 0
    mulps xmm3, xmm1
    mulps xmm4, xmm2
    addps xmm3, xmm4
    shufps xmm4, xmm3, 10110000b
    addps xmm3, xmm4
    shufps xmm4, xmm3, 01000000b
    addps xmm3, xmm4

    movss [eax], xmm3
    lea eax, [eax + 4]
%endmacro

%macro mult2 0
    mulps xmm3, xmm1
    mulps xmm4, xmm2
    addps xmm3, xmm4
    shufps xmm4, xmm3, 10110000b
    addps xmm3, xmm4
    shufps xmm4, xmm3, 01000000b
    addps xmm3, xmm4

    cvtps2dq xmm3, xmm3
    packssdw xmm3, xmm3
    packsswb xmm3, xmm3
    
    movd ecx, xmm3
    mov [eax], cl 
    lea eax, [eax + 1]
%endmacro

antiTransformar:
    push ebp
    mov ebp, esp
    sub esp, 8
    push edi
    push esi
    push ebx

    mov eax, 256
    push eax
    call malloc
    add esp, 4
    mov pre_res, eax

    mov esi, dct
    mov edi, b
    
    xor edx, edx
    xor ecx, ecx
    xor ebx, ebx

    cargar
    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    xor ebx, ebx
    cargar
    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    xor ebx, ebx
    cargar
    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    xor ebx, ebx
    cargar
    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    xor ebx, ebx
    cargar
    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    xor ebx, ebx
    cargar
    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    xor ebx, ebx
    cargar
    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    xor ebx, ebx
    cargar
    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult

    cargar2
    mult


    mov esi, pre_res 
    mov edi, dct
    ;push edi
    ;call transpuesta
    ;add esp, 8
    ;mov edi, eax
    
    mov eax, 64
    push eax
    call malloc
    add esp, 4
    mov resultado, eax

    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx


    cargar
    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    xor ebx, ebx
    cargar
    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    xor ebx, ebx
    cargar
    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    xor ebx, ebx
    cargar
    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    xor ebx, ebx
    cargar
    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    xor ebx, ebx
    cargar
    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    xor ebx, ebx
    cargar
    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    xor ebx, ebx
    cargar
    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2

    cargar2
    mult2


    ;mov eax, resultado
    ;push eax 
    ;call transpuesta 
    ;add esp, 4
    ;mov edi, eax

    mov eax, pre_res
    push eax
    call free
    add esp, 4
    mov eax, resultado
    
fin:
    pop ebx
    pop esi
    pop edi
    add esp, 8
    pop ebp
    ret