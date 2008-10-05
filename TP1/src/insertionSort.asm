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
	mov ebx, param_tabla; empiezo con la primera posicion
	lea ebx, [ebx + 1]; apunto con ebx al campo frecuencia

ciclo:
	cmp ecx, 1	; si hubiera un solo elemento termino. ademas cuando el contador queda en uno elarreglo ya esta ordenado
	je fin
	mov eax, [ebx]		; uso eax para comparar [ebx] y [ebx-5]
	lea ebx, [ebx + 5]	;voy al siguiente elemento
	cmp [ebx], eax		;comparo el elemento a[i] con a[i-1]
	jb preswapeo		; si es menor los intercambio
	jmp siguiente		;sino voy al siguiente

preswapeo:
	mov edx, ebx; hago una copia del puntero actual en edx, que me servira si hago swapear
	mov eax,param_tabla
	jmp swapeo

swapeo:
	mov si, [edx - 1]	;copio el simbolo del elemento a[i]
	mov di, [edx - 6]	;copio el simbolo del elemento a[i-1]
	mov [edx - 1], di	;pongo en el simbolo del elemento a[i-1] al que estaba en a[i]
	mov [edx - 6], si	;pongo en el simbolo del elemento a[i] al que estaba en a[i-1]

	mov esi, [edx]		;pongo en esi la frecuencia del elemento a[i]
	mov edi, [edx-5]	;pongo en edi la frecuencia del elemento a[i-1]
	mov [edx], edi		;pongo en la frecuencia del elemento a[i] al que estaba en a[i-1]
	lea edx, [edx-5]	;retrocedo un elemento
	mov [edx], esi		;pongo en la frecuencia del elemento a[i-1] al que estaba en a[i]
	

	cmp edx, eax	; comparo los punteros, si son iguales es porque llegue al comienzo del arreglo
	je siguiente

	cmp esi, [edx-5]; comparo los dos que siguen para ver si sigo swapenado
	jb swapeo	; si es menor swapeo los elementos
	jmp siguiente

siguiente:
	lea ebx, [ebx + 5]	; me ubico en la siguiente posicion
	dec ecx		; decremento el contador de la long del arreglo
	jmp ciclo	
	

fin:
	mov eax, param_tabla	; devuelvo la tabla ordenada
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
