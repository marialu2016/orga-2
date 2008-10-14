global decodificar

extern malloc

section .text

%define tabla [ebp + 8]
%define tam_tabla [ebp + 12]
%define bitstream [ebp + 16]
%define ancho [ebp + 20]
%define basura [ebp + 24]
%define tam [ebp + 28]

%define resultado [ebp - 4]
%define LoQueMeFalta [ebp - 8]
%define queTanVacio [ebp - 12]
%define bytesUtil [ebp - 16]
%define cont_tab [ebp - 20]
%define contBits [ebp - 24]

%define tabla_simb 0
%define tabla_longcod 1
%define tabla_cod 4
%define tabla_sig 8

decodificar:
	push ebp
	mov ebp, esp
	sub esp, 24
	push edi
	push esi
	push ebx

reservar_mem:
    mov eax, tam
    push eax
    call malloc
    add esp, 4
    cmp eax, 0
    je fin

    mov resultado, eax

    mov esi, bitstream
    mov edi, eax
    mov ecx, tam
    mov LoQueMeFalta, ecx
    mov ecx, ancho
    mov bytesUtil, ecx
    xor edx, edx
    xor ebx, ebx
    xor ecx, ecx

escaneoSimb:
    cmp dword LoQueMeFalta, 0
    je terminar
    mov eax, tabla
    mov bl, [esi]
    mov dword queTanVacio, 8
    dec dword LoQueMeFalta
    lea esi, [esi + 1]
    jmp cicloint

terminar:
    mov eax, resultado
fin:
	pop ebx
	pop esi
	pop edi
	add esp, 24
	pop ebp
	ret

cicloint:
    cmp dword LoQueMeFalta, 0 ; si hay basura no la leo
    je terminar
    cmp dword queTanVacio, 0
    je escaneoSimb
    mov contBits, ecx
    mov ecx, tam_tabla
    mov cont_tab, ecx
    mov ecx, contBits 
    mov eax, tabla
    dec dword queTanVacio
    shl bl, 1  ;saco un bit del buffer
    jc poner_uno
    jmp poner_cero

poner_uno:
    shl edx, 1
    add edx, 1
    inc cl
    jmp buscar

poner_cero:
    shl edx, 1
    inc cl
    jmp buscar

buscar:
    cmp dword cont_tab, 0
    je cicloint 
    dec dword cont_tab
    cmp cl, [eax + tabla_longcod]
    je cmpCod
seguir:
    lea eax, [eax + tabla_sig]
    jmp buscar
cmpCod:
	cmp edx, [eax + tabla_cod]
	jne seguir

asignar_Simb:
    xor ecx, ecx
    mov cl, [eax + tabla_simb]
    mov [edi], cl
    lea edi, [edi + 1]
    dec dword bytesUtil
    cmp dword bytesUtil, 0
    je prox_fila
    xor ecx, ecx
    xor edx, edx
    jmp cicloint

prox_fila:
	mov ecx, basura
	lea edi, [edi + ecx]
	sub LoQueMeFalta, ecx
	mov ecx, ancho
	mov bytesUtil, ecx
    	xor ecx, ecx
    	xor edx, edx
    	jmp cicloint

