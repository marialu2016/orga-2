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
	lea ebx, [ebx+1]; me muevo a la frecuencia de dicha posicion
	mov eax, [ebx]; guardo la frecuencia en eax
	dec ecx
	

ciclo:
	cmp ecx, 0;
	je fin
	lea ebx,[ebx+5]; me muevo a la posicion siguiente
	cmp [ebx],eax; comparo el iesimo con el mínimo hasta el momento
	jb swapeo
	dec ecx
	jmp ciclo

swapeo:
	mov ebx
	
fin:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
