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

ciclo:
	mov eax, [ebx]; uso eax para comparar [ebx] y [ebx-5]
	lea ebx, [ebx + 5]
	cmp [ebx], eax
	jb swapeo

	dec ecx; decremento el contador de la long del arreglo
	cmp ecx, 0
	je fin
	jmp ciclo

preswapeo:
	mov edx, ebx; hago una copia del puntero actual en eax, que me servira si hago swapear
	mov eax,param_tabla
	lea eax,[eax+1]
	jmp swapeo

swapeo:
	mov esi, [edx]; en esi esta a[i]
	mov edi, [edx-5]; en edi esta a[i-1]
	mov [edx], edi
	lea edx, [edx-5]
	mov [edx], esi; hasta aqui logre swapear con esi y edi
	

	cmp edx, eax; comparo los punteros, si son iguales es porque llegue al comienzo del arreglo
	je ciclo

	cmp esi, [edx-5]; comparo los dos que siguen para ver si sigo swapenado
	jb swapeo
	jmp ciclo
	

fin:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
