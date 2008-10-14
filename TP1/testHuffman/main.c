#include <stdio.h>
#include <stdlib.h>

typedef struct {
	char simbolo;
	int frecuencia;
} apariciones;

typedef struct {
	char simbolo;
	char longCod;
	int cod;
} codificacion;

extern void insertionSort (apariciones* tabla, int n);
extern codificacion* armarTablaCodigos( apariciones* tabla, int tam );

int main()
{
	apariciones tabla[4];
	tabla[0].simbolo = 'a';
	tabla[0].frecuencia = 2;
	tabla[1].simbolo = 'r';
	tabla[1].frecuencia = 1;
	tabla[2].simbolo = 'o';
	tabla[2].frecuencia = 1;
	tabla[3].simbolo = 'n';
	tabla[3].frecuencia = 1;

	codificacion* res;

	res = armarTablaCodigos(tabla, 4);

	return 0;
} 
