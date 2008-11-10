global generarDCT

extern malloc

section .text

generarDCT:
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ebx

    mov eax, 64 ;eax=cantidad de elementos de la matriz
    shl eax, 5 ;memoria a pedir
    push eax
    call malloc
    mov edi, eax

    fld1
    fld1
    fadd st(0), st(1)
    fst st(2);st(2)=st(0)=2
    fadd st(0), st(0)
    fadd st(0), st(0) ;st(0)=8
    fdiv st(1), st(0)
    fdivp st(2), st(0)
    fsqrt
    fstp st(2)
    fsqrt
    fstp st(2) ;st(0)=raiz(1/8), st(1)=raiz(2/8)

    fldz
    fldz
cicloCol:
    fld1
    fadd st(0), st(0)
    fadd st(0), st(0)
    fadd st(0), st(0)
    fld1
    fadd st(0), st(1)
    fcomp st(1)
    fstsw ax
    sahf
    ja cicloFila
    fldz
    fcomp st(2)
    fstsw ax
    sahf
    je i_cero
    fld1
    fadd st(0), st(0)
    fmul st(0), st(1)
    fld1
    fadd st(0), st(1)
    fmul st(0), st(2)
    fldpi
    fmul st(0), st(1)
    fld1
    fadd st(0), st(0)
    fadd st(0), st(0)
    fadd st(0), st(0)
    fadd st(0), st(0)
    fdivp st(1), .st(0)
    fcos
    fmul st(0), st(4)
    jmp guardar
i_cero:
    fld st(3)
guardar:
    fstp [edi]
    lea edi, [edi + 4]
    fld1
    faddp st(1), st(0)
    jmp cicloCol
cicloFila:
    fld1
    fadd st(2), st(0)
    fld1
    fadd st(0), st(0)
    fadd st(0), st(0)
    fadd st(0), st(0)
    fld1
    fadd st(0), st(1)
    fcomp st(1)
    fstsw ax
    sahf
    ja fin
    jmp cicloCol
fin:
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret