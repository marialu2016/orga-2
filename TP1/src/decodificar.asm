﻿global decodificar

extern malloc

section .text

%define tabla [ebp + 8]
%define bitstream [ebp + 12]
%define tamBitst [ebp + 16]
;%define basura [ebp + 20]

%define resultado [ebp - 4]
%define LoQueMeFalta [ebp - 8]
%define queTanVacio [ebp - 12]

%define tabla_simb 0
%define tabla_longcod 1
%define tabla_cod 4
%define tabla_sig 8

decodificar:
	push ebp
	mov ebp, esp
	sub esp, 12
	push edi
	push esi
	push ebx

    mov esi, bitstream
    mov ecx, tamBitst
    mov LoQueMeFalta, ecx
    ;mov ecx, basura
    ;sub LoQueMeFalta, ecx   ; LoQueMeFalta es el tamaño del bitstream menos la basura
    xor edx, edx
    xor ecx, ecx
    xor eax, eax

;primero recorro para saber cuanta memoria tengo que pedir

escaneo_long:
    cmp dword LoQueMeFalta, 0
    jbe reservar_mem
    mov edi, tabla
    mov ebx, [esi]  ;pongo en ebx los primeros 4 bytes del bitstream
    mov dword queTanVacio, 32
    lea esi, [esi + 4];

ciclo:
    cmp dword LoQueMeFalta, 0 ; si hay basura no la leo
    je reservar_mem
    cmp dword queTanVacio, 0
    je escaneo_long
    shl ebx, 1  ;saco un bit del buffer
    jc ponerUno
    jmp ponerCero


ponerUno:
    shl edx, 1
    add edx, 1
    inc ecx
    dec dword LoQueMeFalta
    jmp buscar

ponerCero:
    shl edx, 1
    inc ecx
    dec dword LoQueMeFalta
    jmp buscar

buscar:
    cmp ecx, [edi + tabla_longcod]
    je cmpCod
    
seguir:
    lea edi, [edi + tabla_sig]
    jmp buscar

cmpCod:
	cmp edx, [edi + tabla_cod]
	jne seguir
	
sum_mem:
	xor edx, edx
	xor ecx, ecx
    inc eax
    jmp ciclo

reservar_mem:
    push eax
    call malloc
    add esp, 4
    cmp eax, 0
    je fin
    mov resultado, eax

    mov esi, bitstream
    mov edi, eax
    mov ecx, tamBitst
    mov LoQueMeFalta, ecx
    ;mov ecx, basura
    ;sub LoQueMeFalta, ecx   ; LoQueMeFalta es el tamaño del bitstream menos la basura

escaneoSimb:
    cmp dword LoQueMeFalta, 0
    je terminar
    mov eax, tabla
    mov ebx, [esi]  ;pongo en ebx los primeros 4 bytes del bitstream
    mov dword queTanVacio, 32
    lea esi, [esi + 4];
    
cicloint:
    cmp dword LoQueMeFalta, 0 ; si hay basura no la leo
    je terminar
    cmp dword queTanVacion, 0
    je escaneoSimb
    shl ebx, 1  ;saco un bit del buffer
    jc poner_uno
    jmp poner_cero

poner_uno:
    shl edx, 1
    add edx, 1
    inc ecx
    dec dword LoQueMeFalta
    jmp buscar2

poner_cero:
    shl edx, 1
    inc ecx
    dec dword LoQueMeFalta
    jmp buscar2

buscar2:
    cmp ecx, [eax + tabla_longcod]
    je cmpCod2
aqui:
    lea eax, [eax + tabla_sig]
    jmp buscar
cmpCod2:
	cmp edx, [eax + tabla_cod]
	jne aqui

asignar_Simb:
    xor ecx, ecx
    mov cl, [eax + tabla_simb]
    mov [edi], cl
    lea edi, [edi + 1]
    xor ecx, ecx
    xor edx, edx
    jmp cicloint

terminar:
    mov eax, resultado

fin:
	pop ebx
	pop esi
	pop edi
	add esp, 12
	pop ebp
	ret