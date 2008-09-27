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

char* bmp2oc2( char* bmpin, char* oc2out );
char* oc22bmp( char* oc2in, char* bmpout );
char* readbmp( char* bmpin );
void writebmp( char* bmpin );
char* readoc2( char* oc2in );
void writeoc2( char* oc2in );

int main()
{
	return 0;
}

char* bmp2oc2( char* bmpin, char* oc2out )
{

}

char* oc22bmp( char* oc2in, char* bmpout )
{

}

char* readbmp( char* bmpin )
{
    file *fp;

    fp = fopen( "imagen.bmp", "r" );

    if( fp == NULL )
    {
        printf("error al intentar abrir el archivo \n");
    }
    else
    {

    }

}
void writebmp( char* bmpout )
{

}
char* readoc2( char* oc2in )
{

}
void writeoc2( char* oc2out )
{

}
