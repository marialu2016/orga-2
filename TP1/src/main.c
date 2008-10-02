#include <stdio.h>
#include <stdlib.h>

typedef struct {
	char simbolo;
	char longcod;
	char cod;
} codificacion;

typedef struct {
	char simbolo;
	int cant_apariciones;
} apariciones;

extern int esBmp( char* headerImg );
extern int tamImg( char* headerImg );
extern int es24 (char* headerImg );
extern int esOc2( char*bufferImg );
extern int aquiEmpieza(char* headerImg);
extern int ancho(char* headerImg);
extern void insertionSort (apariciones* tabla, int n);
extern int tamImgOc2( char* bufferImg );
extern apariciones* calcularApariciones( char* bufferImg );
extern codificacion* armarTablaCodigos( apariciones* tabla );
extern char* codificar( codificacion* tabla, char* bufferImg );
extern char* decodificar( codificacion* tabla, char* bitstream );

void bmp2oc2( char* bmpin, char* oc2out );
void oc22bmp( char* oc2in, char* bmpout );
char* readbmp( char* bmpin );
void writebmp( char* bufferBmp );
char* readoc2( char* oc2in );
void writeoc2( char* BufferOc2 );

int main()
{
    int opcion = 0;

    printf( "Compresor-Descompresor de archivos Bmp-Oc2 \n\n" );
    printf( "1) Comprimir archivo Bmp. \n" );
    printf( "2) Descomprimir archivo Oc2. \n" );
    printf( "3) salir \n\n" );

    while( opcion != 3 )
    {
        printf( "Ingrese una opcion: \n" );
        opcion = getc( stdin );

        switch( opcion )
        {
            case 1:
                    printf("Por favor, ingrese el nombre del archivo .bmp a comprimir:\n");
                    scanf("%s", bmpin);
                    printf("\n Por favor, ingrese el nombre del archivo .oc2 a crear:\n");
                    scanf("%s", oc2out);
                    bmp2oc2(bmpin, oc2out);
                    printf("\n El archivo %s ha sido comprimido con exito.\n", bmpin);
                    break;
            case 2:
                    printf("Por favor, ingrese el nombre del archivo .oc2 a descomprimir:\n");
                    scanf("%s", oc2in);
                    printf("\n Por favor, ingrese el nombre del archivo .bmp a crear:\n");
                    scanf("%s", bmpout);
                    oc22bmp(oc2in, bmpout);
                    printf("\n El archivo %s ha sido descomprimido con exito.\n", oc2in);
                    break;
            case 3:
                    break;
            default:
                    printf("Por favor, ingrese una opcion valida.\n");
                    break;
        }
    }

    printf("\n Vuelva prontos!\n");

	return 0;
}

void bmp2oc2( char* bmpin, char* oc2out )
{
    /*bmp2oc2: programa principal para comprimir.*/
    char* bufferImg;
    bufferImg = readbmp(bmpin);

    apariciones* tabla_apariciones;
    tabla_apariciones = calcularApariciones( bufferImg );

    codificacion* tabla_codigos;
    tabla_codigos = armarTablaCodigos( tabla_apariciones, tam );

    char* bufferOc2;
    bufferOc2 = codificar( tabla_codigos, bufferImg );

    writeoc2( bufferOc2, oc2out );

}

void oc22bmp( char* oc2in, char* bmpout )
{
    /*oc22bmp: programa principal para descomprimir.*/
    char* bufferOc2;
    bufferOc2 = readoc2( oc2in );

    char* bitstream;

    codificacion* tabla_codigos;

    char* bufferBmp;
    bufferBmp = decodificar( tabla_codigos, bitstream )

    writebmp( bufferBmp, bmpout );
}

char* readbmp( char* bmpin )
{
    /*readbmp: levanta las estructuras del encabezado del archivo .bmp (header e infoHeader)
    y copia los datos de la imagen en un buffer.*/

    file *fp;

    fp = fopen( bmpin, "r" );

    if( fp == NULL )
    {
        printf("error al intentar abrir la imagen \n");
    }
    else
    {
        char* bufferImg;
        fread( bufferImg, 6, 1, fp );

        if( esBmp( bufferImg ) )
        {
            tam = tamImg( bufferImg );
            fread( bufferImg, tamImg, 1, fp );
        }
    }
    fclose(fp);

    return bufferImg;
}
void writebmp( char* bufferBmp, char* bmpout )
{
    /*writebmp: escribe el header y el infoHeader y copia los datos (ya descomprimidos) de
    la imagen que estan en un buffer en el archivo .bmp.*/
    file *fp;

    fp = fopen( bmpout, "w" );

    if( fp == NULL )
    {
        printf("error al intentar abrir la imagen \n");
    }
    else
    {
        fwrite( bufferBmp, sizeof(bufferBmp), 1, fp );
    }
    fclose(fp);
}
char* readoc2( char* oc2in )
{
    /*readoc2: levanta las estructuras del encabezado del archivo .oc2 (header del .oc2,
    header e infoHeader del .bmp y tabla de codigos) y copia el bitstream de los datos
    comprimidos a un buffer.*/
    file *fp;

    fp = fopen( oc2in, "r" );

    if( fp == NULL )
    {
        printf("error al intentar abrir la imagen \n");
    }
    else
    {
        char* bufferImg;
        fread( bufferImg, 13, 1, fp );

        if( esOc2( bufferImg ) )
        {
            tam = tamImgOc2( bufferImg );
            fread( bufferImg, tamImg, 1, fp );
        }
    }
    fclose(fp);

    return bufferImg;
}
void writeoc2( char* bufferOc2, char* oc2out )
{
    /*writeoc2: escribe el header del .oc2, el header e infoHeader del .bmp y la tabla de
    codigos, y copia el bitstream de los datos comprimidos que esta en un buffer en el
    archivo .bmp.oc2.*/
    file *fp;

    fp = fopen( oc2out, "w" );

    if( fp == NULL )
    {
        printf("error al intentar abrir la imagen \n");
    }
    else
    {
        fwrite( BufferOc2, sizeof(BufferOc2), 1, fp );
    }
    fclose(fp);
}
