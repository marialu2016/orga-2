global generarDCT

extern malloc

%define const [ebp - 4]

section .text

generarDCT:
    push ebp
    mov ebp, esp
    sub esp, 4
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
    mov edx, 7
    mov dword const, 180
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

    fldz ; i = 0
    fldz ; j = 0

cicloCol:
    cmp ecx, 0
    je cicloFila
    dec ecx

    cmp edx, 7
    je i_cero

    fld1
    fadd st0, st0; st0 = 2
    fmul st0, st1; st0 = 2*j
    fld1
    faddp st1, st0; st0 = (2*j+1)
    fmul st0, st2; st0 = (2*j+1)*i
    fldpi
    fmulp st1, st0;st0 = (2*j+1)*i*pi
    fld1
    fadd st0, st0
    fadd st0, st0
    fadd st0, st0
    fadd st0, st0; st0 = 16
    fdivp st1, st0;st0 = ((2*j+1)*i*pi)/16
    ;fldpi
    ;fmulp st1, st0
    ;fild dword const
    ;fdivp st1, st0
    fcos; st0 = cos(((2*j+1)*i*pi)/16)
    fmul st0, st4; st0 = 1/2 * cos(((2*j+1)*i*pi)/16)
    jmp guardar
i_cero:
    fld st2
guardar:
     fstp dword [edi]
     lea edi, [edi + 4]
     fld1
     faddp st1, st0; st0 = j + 1
     jmp cicloCol
cicloFila:
      fld1
      faddp st2, st0 ; st1 = i + 1

      cmp edx, 0
      je fin
      dec edx

      mov ecx, 8
      fld1
      fadd st0, st0
      fadd st0, st0
      fadd st0, st0; st0 = 8
      fsubp st1, st0; st1 = st1 - 8
      jmp cicloCol
fin:
    mov eax, ebx
    pop ebx
    pop esi
    pop edi
    add esp, 4
    pop ebp
    ret