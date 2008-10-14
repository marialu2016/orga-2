#include <stdio.h>
#include <stdlib.h>

typedef struct _codificacion{
	char simbolo;
	char longCod;
	char trash1;
	char trash2;
	int cod;
} codificacion;


extern int codificar( codificacion* tabla, char* bufferImg, int tamImg, int ancho, int trash, char* bitstream);
extern char* cantBytesBstream( codificacion* tabla, char* bufferImg, int tamImg, int ancho, int trash );

int main()
{
	int i;
	codificacion cod [6];

	cod[0].simbolo = 'a';
	cod[0].longCod = 2;
	cod[0].cod = 3;
	cod[1].simbolo = 'r';
	cod[1].longCod = 3;
	cod[1].cod = 0;
	cod[2].simbolo = 'o';
	cod[2].longCod = 3;
	cod[2].cod = 1;
	cod[3].simbolo = 'n';
	cod[3].longCod = 2;
	cod[3].cod = 2;
	cod[4].simbolo = 'w';
	cod[4].longCod = 3;
	cod[4].cod = 2;
	cod[5].simbolo = 'g';
	cod[5].longCod = 3;
	cod[5].cod = 3;

	char* buffer = malloc(12);
	buffer = "aarbonwbangb";
	int basura;
	char* res;

	int tamBuff = 12;
	long long int *tamBits;
	res = cantBytesBstream( cod, buffer, tamBuff, 3, 1);
	basura = codificar(cod, buffer, tamBuff, 3, 1, res);

	for(i = 0; i < 3; i++)
	{
		printf("el resultado es: %d \n", res[i]);
	}

	printf("la basura es de :%d\n",basura  );
	return 0;
}
