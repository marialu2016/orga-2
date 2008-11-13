global decodificar

extern malloc

section .text

%define bitstream [ebp + 8]
%define offset [ebp + 12]

%define res [ebp - 4]
%define vlocal [ebp - 8]
%define ceros [ebp - 12]

decodificar:
    push ebp
    mov ebp, esp
    sub esp, 4
    push edi
    push esi
    push ebx

    mov esi, offset ; o podria ser mov esi, bitstream y luego lea esi, [esi + offset]
    
    mov eax, 64
    shl eax, 1
    call malloc
    add esp, 12
    mov edi, eax
    mov res, eax

    xor ebx, ebx
    xor eax, eax   
    xor edx, edx 

    mov bl, [esi]
    mov [edi], bx
    lea edi, [edi + 2]
    lea esi, [esi + 1]
    mov bl, [esi]
    mov ceros, ebx
    lea esi, [esi + 1]

ciclo:
    cmp ebx, 14
    ja termine
    cmp ebx, 7
    ja post_ciclo
aqui:
    shr ebx,1
    jc preDiagAb
    shl ebx, 1
    mov ecx, ebx
    jmp diagArriba
preDiagAb:
    shl ebx, 1
    add ebx, 1
    mov edx, ebx
    jmp diagAbajo
post_ciclo:
    shr ebx,1
    jc preDiagAb2
    mov edx, ebx
    sub edx, 7
    mov ecx, ebx
    sub ecx, edx
    jmp diagArriba
preDiagAb2:
    mov ecx, ebx
    sub ecx, 7
    mov edx, ebx
    sub edx, ecx

diagAbajo:
    mov eax, edx
    shl edx, 1
    shl ecx, 4
    add eax, ecx
    shr ecx, 4
    jmp agregar
termine:
    jmp fin
seguir:
    inc ecx
    dec edx
    add ecx, edx
    cmp ebx, ecx
    ja ciclar
    sub ecx, edx
    cmp ecx, 7
    ja ciclar
    mov eax, ecx
    shl eax, 4
    shl edx, 1
    add eax, edx
    shr edx, 1
    jmp agregar
ciclar:
    xor ecx, ecx
    xor edx, edx
    inc ebx
    jmp ciclo
agregar:
    cmp byte ceros, 0
    jne ag_cero
    mov vlocal, ebx
    xor ebx, ebx
    mov bl, [esi]
    mov [edi + eax], bx
    lea esi, [esi + 1]
    mov bl, [esi]
    mov ceros, ebx
    lea esi, [esi + 1]
    jmp seguir
ag_cero:
    mov dword [edi + eax], 0
    jmp seguir

diagArriba:
    mov eax, ecx
    shl eax, 4
    shl edx, 1
    add eax, edx
    shr edx, 1
    jmp agregar2
seguir2:
    inc edx
    dec ecx
    add ecx, edx
    cmp ebx, ecx
    ja ciclar2
    sub ecx, edx
    cmp edx, 7
    ja ciclar
    mov eax, ecx
    shl eax, 4
    shl edx, 1
    add eax, edx
    shr edx, 1
    jmp agregar2
ciclar2:
    xor ecx, ecx
    xor edx, edx
    inc ebx
    jmp ciclo
agregar2:
    cmp byte ceros, 0
    jne ag_cero2
    mov vlocal, ebx
    xor ebx, ebx
    mov bl, [esi]
    mov [edi + eax], bx
    lea esi, [esi + 1]
    mov bl, [esi]
    mov ceros, ebx
    lea esi, [esi + 1]
    jmp seguir2
ag_cero2:
    mov dword [edi + eax], 0
    jmp seguir2
    
     

fin:
    mov eax, res
    pop ebx
    pop esi
    pop edi
    add esp, 12
    pop ebp
    ret