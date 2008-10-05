#include <stdio.h>
#include <stdlib.h>

/***********************************************************************************
**                              Estructuras principales                           **
************************************************************************************/

typedef struct {
    short int bfType;   //El string "BM"
    long int bfSize;    //Tamaño del archivo
    short int bfReserv1;
    short int bfReserv2;
    long int bfOffBits; //Offset desde el comienzo del archivo a los datos (en bytes)
} header;

typedef struct {
    long int bfSize;    //Tamaño de este header en bytes (40)
    long int biWidth;   //ancho en pixels
    long int biHeight;  //alto en pixels
    short int biPlanes; //1
    short int biBitCount;//1, 4, 8, 16, 24
    long int biCompression;
    long int biSizeImage;   //tamaño de la imagen en bytes
    long int biXPelsPerM;
    long int biYPelsPerM;
    long int biClrUsed;
    long int biClrImportant;
} infoHeader;

typedef struct {
    int fType;  //El string "OC2\0"
    char tSize; //Tamaño en bytes de la tabla de codigos
    long long int bSize;//tamaño en bits del bitstream
} Oc2FileHeader;

typedef struct {
	char simbolo;
	char longCod;
	char cod;
} codificacion;

typedef struct {
	char simbolo;
	int cant_apariciones;
} apariciones;

/**********************************************************************
**                      Funciones en assembler                       **
***********************************************************************/

extern void insertionSort (apariciones* tabla, int n);
extern apariciones* calcularApariciones( char* bufferImg );
extern codificacion* armarTablaCodigos( apariciones* tabla );
extern char* codificar( codificacion* tabla, char* bufferImg );
extern char* decodificar( codificacion* tabla, char* bitstream );

/*************************************************************************
**              Funciones para el encabezado del BMP y OC2              **
**************************************************************************/

int esBmp( header h );
int tamFile( header h );
int tamImg( infoHeader h );
int es24 ( infoHeader h );
int esOc2( Oc2FileHeader h );
int aquiEmpieza( header h );
int ancho(infoHeader h);
int tamImgOc2( Oc2FileHeader h);

/**************************************************************************
**      Funciones Principales para el Compresor-Descompresor BMP-OC2     **
***************************************************************************/

void bmp2oc2( char* bmpin, char* oc2out );
void oc22bmp( char* oc2in, char* bmpout );
char* readbmp( char* bmpin );
void writebmp( char* bufferBmp );
char* readoc2( char* oc2in );
void writeoc2( char* BufferOc2 );

/***************************************************************************
**                      Implementacion de las funciones                   **
****************************************************************************/

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

char* readbmp( char* bmpin, int tambuffer )
{
    /*readbmp: levanta las estructuras del encabezado del archivo .bmp (header e infoHeader)
    y copia los datos de la imagen en un buffer.*/

    file *fp;
    char* bufferImg;
    header h;
    infoHeader ih;

    fp = fopen( bmpin, "r" );

    if( fp == NULL )
    {
        printf("error al intentar abrir la imagen \n");
    }
    else
    {
        fread( h, 14, 1, fp );
        fread( ih, 40, 1, fp );


        if( esBmp( h ) )
        {
            fread( bufferImg, tambuffer, 1, fp );
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

int esBmp( header h )
{
    short int str_bm = 6677;
    int res;
    res = ( h.bfType == str_bm );
    return res;
}
int tamFile( header h )
{

}
int tamImg( infoHeader h )
{

}
int es24 ( infoHeader h )
{

}
int esOc2( Oc2FileHeader h )
{

}
int aquiEmpieza( header h )
{

}
int ancho(infoHeader h)
{

}
int tamImgOc2( Oc2FileHeader h)
{

}
