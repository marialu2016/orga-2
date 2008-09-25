#include <stdio.h>

typedef struct {
	char simbolo;
	char longcod;
	int cod;
} codificacion;

typedef struct {
	char simbolo;
	int cant_apariciones;
} apariciones;

extern apariciones* calcularApariciones(char* bufferImg);
extern codificacion* armarTablaCodigos(apariciones* tabla);
extern char* codificar(codificacion* tabla, char* bufferImg);
extern char* decodificar(codificacion* tabla, char bitstream);

char* bmp2oc2(char* bmpin, char* oc2out);
char* oc22bmp(char* oc2in, char* bmpout);
char* readbmp(char* bmpin);
void writebmp(char* bmpin);
char* readoc2(char* oc2in);
void writeoc2(char* oc2in);

int main()
{
	return 0;
}

char* bmp2oc2(char* bmp, char* oc2)
{

}

char* oc22bmp(char* oc2, char* bmp)
{

}

char* readbmp(char* bmp)
{

}
void writebmp(char* bmp)
{

}
char* readoc2(char* oc2)
{

}
void writeoc2(char* oc2)
{

}
