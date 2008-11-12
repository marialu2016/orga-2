global codificar

extern malloc
extern free

section .text

%define bq [ebp + 8]

%define resultado [ebp - 4]
%define ceros [ebp - 8]

codificar:
    push ebp
    mov ebp, esp
    sub esp, 8
    push edi
    push esi
    push ebx

    mov eax, 129
    push eax
    call malloc

    mov edi, eax
    mov resultado, eax
    mov esi, bq
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

    mov dx, [esi]
    mov [edi], dx
    add ebx, 2
    lea edi, [edi + 2]
    add eax, 1
    mov ecx, eax
    mov byte ceros, 0

    mov ebx, 1
    xor edx, edx
    xor ecx, ecx

ciclo:
    cmp ebx, 14
    ja fin
    cmp ebx, 7
    ja post_ciclo
aqui:
    shr ebx,1
    jc preDiagAb
    shl ebx
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
    jmp genio
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
    jmp genio
ciclar:
    xor ecx, ecx
    xor edx, edx
    inc ebx
    jmp ciclo
genio:
    cmp [esi + eax], 0
    je aumCeros

    mov dl, ceros
    mov byte [edi], ceros
    mov dx , [esi + ebx]
    mov [edi + 1], dx
    lea edi, [edi + 2]
    add dword memapedir, 1
    mov byte ceros, 0
    jmp seguir
aumCeros:
    add byte ceros, 1
    jmp seguir

diagArriba:
    mov eax, ecx
    shl eax, 4
    shl edx, 1
    add eax, edx
    shr edx, 1
    jmp genio2
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
    jmp genio2
ciclar2:
    xor ecx, ecx
    xor edx, edx
    inc ebx
    jmp ciclo
genio2:
    cmp [esi + eax], 0
    je aumCeros2

    mov dl, ceros
    mov byte [edi], ceros
    mov dx , [esi + ebx]
    mov [edi + 1], dx
    lea edi, [edi + 2]
    add dword memapedir, 1
    mov byte ceros, 0
    jmp seguir2
aumCeros2:
    add byte ceros, 1
    jmp seguir2

reservar:

fin:
    pop ebx
    pop esi
    pop edi
    add esp, 8
    pop ebp
    ret