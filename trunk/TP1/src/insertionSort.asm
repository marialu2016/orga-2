global insertionSort

section .text

%define param_tabla [ebp + 8]
%define param_n [ebp + 12]


insertionSort:
	push ebp
	mov ebp,esp
	push ebx
	push esi
	push edi
	
	mov ecx, param_n; creo un contador de la longitud del arreglo
	mov esi, param_tabla; apunta al puntero de la primera posición
ciclo:	
	cmp ecx, 0
	je fin
	dec ecx; decremento el contador de la long del arreglo
	lea esi, [esi + 8]	; avanzo una posicion
	mov edx, [esi - 4] ;en edx tengo el campo frecuencia del i-esimo elemento
	mov eax, [esi + 4]; en eax tengo el campo frecuencia del i-esimo + 1 elemento
	cmp eax, edx; comparo
	jb preswapeo

	jmp ciclo

preswapeo:
	mov eax,param_tabla
	mov edi, esi
swapeo:
	xor ebx, ebx
	xor edx, edx
	mov bl,[edi - 8]; en bl esta a[i].simbolo
	mov dl,[edi]; en dl esta a[i + 1].simbolo
	
	mov [edi], bl	;swapeo de caracteres
	mov [edi - 8], dl;swapeo de caracteres
	
	mov ebx, [edi - 4]; en ebx esta a[i].frecuencia
	mov edx, [edi + 4]; en edx esta a[i + 1].frecuencia

	mov [edi + 4], ebx	;swapeo de enteros
	mov [edi - 4], edx	;swapeo de enteros
	
	lea edi, [edi - 8]	;retrocedo una posicion
	
	cmp edi, eax; comparo los punteros, si son iguales es porque llegue al comienzo del arreglo
	je ciclo

	cmp edx, [edi - 4]; comparo los dos que siguen para ver si sigo swapenado
	jb swapeo
	jmp ciclo

fin:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret