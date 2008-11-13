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
    shl eax, 2 ;memoria a pedir
    push eax
    call malloc
    add esp, 4
    mov edi, eax
    mov ebx, eax
    mov ecx, 8
    mov edx, 8
    finit
    fld1
    fld1
    fadd st0, st1
    fst st2;st(2)=st(0)=2
    fadd st0, st0
    fadd st0, st0 ;st(0)=8
    fdiv st1, st0
    fdivp st2, st0
    fsqrt
    fstp st2
    fsqrt
    fstp st2 ;st(0)=raiz(1/8), st(1)=raiz(2/8)

    fldz
    fldz
cicloCol:
;     fld1
;     fadd st0, st1;st0 = 9 y st1 = 8
;     fcomp st1
;     fstsw ax
;     sahf
;     ja cicloFila
;     fldz
;     fcomp st2
;     fstsw ax
;     sahf
    cmp ecx, 0
    je cicloFila
    dec ecx
    cmp edx, 8
    je i_cero
    fld1
    fadd st0, st0
    fmul st0, st1
    fld1
    faddp st1, st0
    fmul st0, st2
    fldpi
    fmulp st1, st0
    fld1
    fadd st0, st0
    fadd st0, st0
    fadd st0, st0
    fadd st0, st0
    fdivp st1, st0
    fcos
    fmul st0, st4
    jmp guardar
i_cero:
    fld st2
guardar:
    fstp dword [edi]
    lea edi, [edi + 4]
     fld1
     faddp st1, st0
    jmp cicloCol
cicloFila:
      fld1
      faddp st2, st0
;     fld1
;     fadd st0, st0
;     fadd st0, st0
;     fadd st0, st0
;     fld1
;     fadd st0, st1
;     fcomp st1
;     fstsw ax
;     sahf
;     ja fin
    cmp edx, 0
    je fin
    dec edx
    mov ecx, 8
     fld1
     fadd st0, st0
     fadd st0, st0
     fadd st0, st0
     fsubrp st1, st0
    jmp cicloCol
fin:
    mov eax, ebx
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret