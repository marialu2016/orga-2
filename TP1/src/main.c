#include <stdio.h>
#include <stdlib.h>

#define maxTamFile 4194304

/***********************************************************************************
**                              Estructuras principales                           **
************************************************************************************/

typedef struct {
    short int bfType;   //El string "BM"
    long int bfSize;    //Tama�o del archivo
    short int bfReserv1;
    short int bfReserv2;
    long int bfOffBits; //Offset desde el comienzo del archivo a los datos (en bytes)
} header;

typedef struct {
    long int bfSize;    //Tama�o de este header en bytes (40)
    long int biWidth;   //ancho en pixels
    long int biHeight;  //alto en pixels
    short int biPlanes; //1
    short int biBitCount;//1, 4, 8, 16, 24
    long int biCompression;
    long int biSizeImage;   //tama�o de la imagen en bytes
    long int biXPelsPerM;
    long int biYPelsPerM;
    long int biClrUsed;
    long int biClrImportant;
} infoHeader;

typedef struct {
    int fType;  //El string "OC2\0"
    char tSize; //Tama�o en bytes de la tabla de codigos
    long long int bSize;//tama�o en bits del bitstream
} Oc2FileHeader;

typedef struct {
	char simbolo;
	char longCod;
	int cod;
} codificacion;

typedef struct {
	char simbolo;
	int cant_apariciones;
} apariciones;

/**********************************************************************
**                      Funciones en assembler                       **
***********************************************************************/

extern void insertionSort (apariciones* tabla, int n);
extern apariciones* calcularApariciones( char* bufferImg, int tamImg, int ancho, int trash, &int tam );
extern codificacion* armarTablaCodigos( apariciones* tabla, int tam );
extern char* codificar( codificacion* tabla, char* bufferImg, int tamImg, int ancho, int trash, &long long int tamBitstream );
extern char* decodificar( codificacion* tabla, char* bitstream, long long tamBitstream, int trash );

/*************************************************************************
**              Funciones para el encabezado del BMP y OC2              **
**************************************************************************/

int esBmp( header h );
long int tamFile( header h );
long int tamImg( infoHeader h );
int es24 ( infoHeader h );
int esOc2( Oc2FileHeader h );
long int aquiEmpieza( header h );
long int ancho(infoHeader h);
long long int tamImgOc2( Oc2FileHeader h);

/**************************************************************************
**      Funciones Principales para el Compresor-Descompresor BMP-OC2     **
***************************************************************************/

void bmp2oc2( char* bmpin, char* oc2out );
void oc22bmp( char* oc2in, char* bmpout );
char* readbmp( char* bmpin, &header h, &infoHeader ih );
void writebmp( char* bufferBmp, header h, infoHeader ih  );
char* readoc2( char* oc2in, &header h, &infoHeader ih, &Oc2FileHeader );
void writeoc2( char* BufferOc2, header h, infoHeader ih, Oc2FileHeader oh, codificacion* tabla, char* bitstream );

/***************************************************************************
**                      Implementacion de las funciones                   **
****************************************************************************/

int main()
{
    int opcion = 0;
    char* bmpin;
    char* oc2out;
    char* oc2in;
    char* bmpout;
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
    header h;
    infoHeader ih;
    Oc2FileHeader oh;

    int tam = 0; //cantidad de simbolos distintos

    long long int tamBitstream = 0; //tamaño del bitstream

    oh.fType = 79834748;

    char* bufferImg;
    bufferImg = readbmp( bmpin, h, ih );

    trash = (ih.biWidth) % 4;

    apariciones* tabla_apariciones;
    tabla_apariciones = calcularApariciones( bufferImg, ih.biSizeImage, ih.biWidth, trash, tam);

    codificacion* tabla_codigos;
    tabla_codigos = armarTablaCodigos( tabla_apariciones, tam);

    oh.tSize = 8 * tam; //el tamaño de la tabla de codigos en bytes es la cantidad de simbolos distintos por 8 bytes que es lo que ocupa cada campo.

    char* bufferOc2;
    bufferOc2 = codificar( tabla_codigos, bufferImg, h.biSizeImage, ih.biWidth, trash, tamBitstream );

    oh.bSize = tamBitstream;

    writeoc2( oc2out, h, ih, oh, tabla_codigos, bufferOc2 );

}

void oc22bmp( char* oc2in, char* bmpout )
{
    /*oc22bmp: programa principal para descomprimir.*/
    char* bitstream;
    char* bufferBmp;
    header h;
    infoHeader ih;
    Oc2FileHeader oh;
    codificacion* tabla_codigos;

    bitstream = readoc2( oc2in, h, ih, oh, tabla_codigos );

    bufferBmp = decodificar( tabla_codigos, bitstream, oh.bSize, trash );

    writebmp( bmpout, h, ih, bufferBmp );
}

char* readbmp( char* bmpin, &header h, &infoHeader ih )
{
    /*readbmp: levanta las estructuras del encabezado del archivo .bmp (header e infoHeader)
    y copia los datos de la imagen en un buffer.*/

    file *fp;
    char* bufferImg;

    fp = fopen( bmpin, "r" );

    if( fp == NULL )
    {
        printf("error al intentar abrir la imagen \n");
    }
    else
    {
        fread( h, 14, 1, fp );
        fread( ih, 40, 1, fp );


        if( esBmp( h ) && es24( ih ) && ( tamFile( ih ) <= maxTamFile ) )
        {
            fread( bufferImg, ih.biSizeImage, 1, fp );
        }
    }
    fclose(fp);

    return bufferImg;
}
void writebmp( char* bmpout, header h, infoHeader ih )
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
        fwrite( h, 14, 1, fp );
        fwrite( ih, 40, 1, fp );
        fwrite( bufferBmp, tamImg( ih ), 1, fp );
    }
    fclose(fp);
}
char* readoc2( char* oc2in, &header h, &infoHeader ih, &Oc2FileHeader oh, &codificacion* tabla )
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

        fread( oh, 13, 1, fp );

        if( esOc2( oh ) )
        {
            fread( h, 14, 1, fp );
            fread( ih, 40, 1, fp );
            fread(tabla, oh.tSize, 1, fp);
            int tamImg = ( tamImgOc2( oh ) / 8 );//divido el tamaño del bitstream por 8 para tenerlo en bytes.
            fread( bufferImg, tamImg, 1, fp );
        }
    }
    fclose(fp);

    return bufferImg;
}
void writeoc2( char* oc2out, header h, infoHeader ih, Oc2FileHeader oh, codificacion* tabla, char* bitstream )
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
        fwrite( h, 14, 1, fp );
        fwrite( ih, 40, 1, fp );
        fwrite( oh, 16, 1, fp );
        fwrite( tabla, oh.tSize, 1, fp );
        int tamBitstream = ( ( oh.bSize ) / 8 );// paso la cantidad de bits a bytes ya que va a ser multiplo de 8
        fwrite( bitstream, tamBitstream, 1, fp );
    }
    fclose(fp);
}

/************************************************************************************
**                      Funciones de lectura de encabezados                        **
*************************************************************************************/

int esBmp( header h )
{
    short int str_bm = 6677;
    int res;
    res = ( h.bfType == str_bm );
    return res;
}
long int tamFile( header h )
{
    return h.bfSize;
}
long int tamImg( infoHeader h )
{
    return h.biSizeImage;
}
int es24 ( infoHeader h )
{
    return ( h.biBitCount == 24 );
}
int esOc2( Oc2FileHeader h )
{
    int str_oc2 = 79834748;
    int res;
    res = ( h.fType == str_oc2 );
    return res;
}
long int aquiEmpieza( header h )
{
    return h.bfOffBits;
}
long int ancho(infoHeader h)
{
    return h.biWidth;
}
long long int tamImgOc2( Oc2FileHeader h)
{
    return h.bSize;
}
