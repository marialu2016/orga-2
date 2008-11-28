global transformar

extern malloc

section .text

%define b [ebp + 8]
%define dct [ebp + 12]

%define resultado [ebp - 4]

%macro cargarYconvertir 0

    movq xmm1, [edi];8 elementos de un byte cada uno(toda una fila)
    movq xmm2, [edi];8 elementos de un byte cada uno(toda una fila)
    lea edi, [edi + 8]
    pxor xmm0, xmm0
    punpcklbw xmm1, xmm0; transforma los numeros que estan en bytes a word
    punpcklbw xmm2, xmm0; transforma los numeros que estan en bytes a word
    punpcklwd xmm1, xmm0; transforma los numeros que estan en word a dword(parte alta)
    punpckhwd xmm2, xmm0; transforma los numeros que estan en word a dword(parte baja)
    cvtdq2ps xmm1, xmm1; convierte los 4 enteros dword a float
    cvtdq2ps xmm2, xmm2; convierte los 4 enteros dword a float
    ;xmm1 tiene los primeros 4 numeros de la fila
    ;xmm2 tiene los segundos 4 numeros de la fila
    ; entre xmm1 y xmm2 tengo toda la fila

%endmacro

%macro cargar 1

    movups xmm3, [%1];cargo la primera parte de la fila
    lea %1, [%1 + 16]
    movups xmm4, [%1];cargo la segunda parte de la fila
    lea %1, [%1 + 16]

%endmacro


%macro cargar2 1

    movups xmm1, [%1];cargo la primera parte de la fila
    lea %1, [%1 + 16]
    movups xmm2, [%1];cargo la segunda parte de la fila
    lea %1, [%1 + 16]

%endmacro

%macro mult1 0

    mulps xmm3, xmm1
    mulps xmm4, xmm2
    addps xmm3, xmm4
    pshufd xmm4, xmm3, 00001011b
    addps xmm3, xmm4
    pshufd xmm4, xmm3, 00000001b
    addps xmm3, xmm4
    movss [eax], xmm3
    lea eax, [eax + 4]

%endmacro

%macro mult2 0

    mulps xmm1, xmm3
    mulps xmm2, xmm4
    addps xmm1, xmm2
    pshufd xmm2, xmm1, 00001011b
    addps xmm1, xmm2
    pshufd xmm2, xmm1, 00000001b
    addps xmm1, xmm2
    movss [eax], xmm1
    lea eax, [eax + 4]

%endmacro

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


    cargar esi
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1

    mov edi, b
    cargar esi
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1


    mov edi, b
    cargar esi
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1


    mov edi, b
    cargar esi
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1


    mov edi, b
    cargar esi
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1


    mov edi, b
    cargar esi
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1


    mov edi, b
    cargar esi
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1


    mov edi, b
    cargar esi
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1
    cargarYconvertir
    mult1

    ;hasta aca tenemos DCT.transpuesta(B) apuntada por la variable resultado

    mov esi, resultado
    mov edi, dct 
    mov eax, resultado

    cargar esi
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2

    mov edi, dct 
    cargar esi
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2

    mov edi, dct 
    cargar esi
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2

    mov edi, dct 
    cargar esi
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2

    mov edi, dct 
    cargar esi
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2

    mov edi, dct 
    cargar esi
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2

    mov edi, dct 
    cargar esi
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2

    mov edi, dct 
    cargar esi
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2
    cargar2 edi
    mult2

fin:
    mov eax, resultado
    pop ebx
    pop esi
    pop edi
    add esp, 4
    pop ebp
    ret