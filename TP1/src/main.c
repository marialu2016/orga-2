#include <stdio.h>
#include <stdlib.h>

#define maxTamFile 4194304

/***********************************************************************************
**                              Estructuras principales                           **
************************************************************************************/

typedef struct header{
    //short int bfType;   //El string "BM"
    char bfType[2];
    long int bfSize;    //Tama�o del archivo
    short int bfReserv1;
    short int bfReserv2;
    long int bfOffBits; //Offset desde el comienzo del archivo a los datos (en bytes)
} header;

typedef struct infoHeader{
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

typedef struct Oc2FileHeader{
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
extern int tamTabla( char* bufferImg, int tamImg, int ancho, int trash );
extern apariciones* calcularApariciones( char* bufferImg, int tamImg, int ancho, int trash);
extern codificacion* armarTablaCodigos( apariciones* tabla, int tam );
extern char* cantBytesBstream( codificacion* tabla, char* bufferImg, int tamImg, int ancho, int trash );
extern int codificar( codificacion* tabla, char* bufferImg, int tamImg, int ancho, int trash, char* bitstream);
extern char* decodificar( codificacion* tabla, int tam_tabla,char* bitstream, int ancho, int basura, int tam );

/*************************************************************************
**              Funciones para el encabezado del BMP y OC2              **
**************************************************************************/

int esBmp( header* h );
long int tamFile( header* h );
long int tamImg( infoHeader* h );
int es24 ( infoHeader* h );
int esOc2( Oc2FileHeader* h );
long int aquiEmpieza( header* h );
long int ancho(infoHeader* h);
long long int tamImgOc2( Oc2FileHeader* h);

/**************************************************************************
**      Funciones Principales para el Compresor-Descompresor BMP-OC2     **
***************************************************************************/

void bmp2oc2( char* bmpin, char* oc2out );
void oc22bmp( char* oc2in, char* bmpout );
char* readbmp( char* bmpin, header* h, infoHeader* ih );
void writebmp( char* bufferBmp, header* h, infoHeader* ih, char* bufferImg );
char* readoc2( char* oc2in, header* h, infoHeader* ih, Oc2FileHeader* oh, codificacion* tabla );
void writeoc2( char* BufferOc2, header* h, infoHeader* ih, Oc2FileHeader* oh, codificacion* tabla, int tam, char* bitstream, int tamBits );

/***************************************************************************
**                      Implementacion de las funciones                   **
****************************************************************************/

int main()
{
    int opcion = 0;
    /*char* bmpin = "simpson.bmp";
    char* oc2out= "simpson.oc2";
    char* oc2in= "simpson.oc2";
    char* bmpout="simpson2.bmp";*/
    char* bmpin = "hola.bmp";
    char* oc2out= "hola.oc2";
    char* oc2in= "hola.oc2";
    char* bmpout="hola2.bmp";

//bmpout = readbmp(bmpin, h, ih);
bmp2oc2(bmpin, oc2out);
oc22bmp(oc2in, bmpout);
    printf( "Compresor-Descompresor de archivos Bmp-Oc2 \n\n" );
    printf( "1) Comprimir archivo Bmp. \n" );
    printf( "2) Descomprimir archivo Oc2. \n" );
    printf( "3) salir \n\n" );

    /*while( opcion != 3 )
    {
        printf( "Ingrese una opcion: \n" );
        opcion = getchar();

        switch( opcion )
        {
            case '1':
                    printf("Por favor, ingrese el nombre del archivo .bmp a comprimir:\n");
                    scanf("%s", bmpin);
                    printf("\n Por favor, ingrese el nombre del archivo .oc2 a crear:\n");
                    scanf("%s", oc2out);
                    bmp2oc2(bmpin, oc2out);
                    printf("\n El archivo %s ha sido comprimido con exito.\n", bmpin);
                    break;
            case '2':
                    printf("Por favor, ingrese el nombre del archivo .oc2 a descomprimir:\n");
                    scanf("%s", oc2in);
                    printf("\n Por favor, ingrese el nombre del archivo .bmp a crear:\n");
                    scanf("%s", bmpout);
                    oc22bmp(oc2in, bmpout);
                    printf("\n El archivo %s ha sido descomprimido con exito.\n", oc2in);
                    break;
            case '3':
                    break;
            default:
                    printf("Por favor, ingrese una opcion valida.\n");
                    break;
        }
    }

    printf("\n Vuelva prontos!\n");*/

	return 0;
}

void bmp2oc2( char* bmpin, char* oc2out )
{
    /*bmp2oc2: programa principal para comprimir.*/
struct header vh;
struct infoHeader vih;
struct Oc2FileHeader voh;
struct header* h = &vh;
struct infoHeader* ih = &vih;
struct Oc2FileHeader* oh = &voh;
    /*header* h =   malloc( sizeof( h ) );
    infoHeader* ih =  malloc( sizeof( infoHeader ) );
    Oc2FileHeader* oh =  malloc( sizeof( Oc2FileHeader ) );*/
    char* bufferImg;
    int basura;
    int trash;
    int tam;
    apariciones* tabla_apariciones;

    int bBstream;
    oh->fType = 79834748;

    bufferImg = readbmp( bmpin, h, ih );

    trash = (ih->biWidth) % 4;

    tam = tamTabla( bufferImg, ih->biSizeImage, ih->biWidth, trash );

    tabla_apariciones = calcularApariciones( bufferImg, ih->biSizeImage, ih->biWidth, trash);

    codificacion* tabla_codigos;
    tabla_codigos = armarTablaCodigos( tabla_apariciones, tam);

    oh->tSize = 8 * tam; //el tamaño de la tabla de codigos en bytes es la cantidad de simbolos distintos por 8 bytes que es lo que ocupa cada campo.

    char* bufferOc2;

    bufferOc2 = cantBytesBstream( tabla_codigos, bufferImg, ih->biSizeImage, ih->biWidth, trash );

    basura = codificar( tabla_codigos, bufferImg, ih->biSizeImage, ih->biWidth, trash, bufferOc2);

    int tamBits = sizeof( bufferOc2 );

    oh->bSize = (sizeof(bufferOc2) * 8) - basura;

    writeoc2( oc2out, h, ih, oh, tabla_codigos, oh->tSize, bufferOc2, tamBits );
}

void oc22bmp( char* oc2in, char* bmpout )
{
    /*oc22bmp: programa principal para descomprimir.*/
    char* bitstream;
    char* bufferBmp;

struct header vh;
struct infoHeader vih;
struct Oc2FileHeader voh;
struct header* h = &vh;
struct infoHeader* ih = &vih;
struct Oc2FileHeader* oh = &voh;
    codificacion* tabla_codigos;
    int trash;

    bitstream = readoc2( oc2in, h, ih, oh, tabla_codigos );
    trash = (ih->biWidth) % 4;
    bufferBmp = decodificar( tabla_codigos,oh->tSize ,bitstream,ih->biWidth, trash, ih->biSizeImage );

    writebmp( bmpout, h, ih, bufferBmp );
}


char* readbmp( char* bmpin, header* h, infoHeader* ih )
{
    /*readbmp: levanta las estructuras del encabezado del archivo .bmp (header e infoHeader)
    y copia los datos de la imagen en un buffer.*/

    FILE* fp;
    char* bufferImg;
    fp = fopen(bmpin, "r" );

    if( fp == NULL )
    {
        printf("error al intentar abrir la imagen \n");
    }
    else
    {
	/*Cargo el header*/
	fread( &(h->bfType), 2, 1, fp );
	fread( &(h->bfSize), 4, 1, fp );
	fread( &(h->bfReserv1), 2, 1, fp );
	fread( &(h->bfReserv2), 2, 1, fp );
	fread( &(h->bfOffBits), 4, 1, fp );



	/*Cargo el infoHeader*/
	fread( &(ih->bfSize), 4, 1, fp );
	fread( &(ih->biWidth), 4, 1, fp);
	fread( &(ih->biHeight), 4, 1, fp);
	fread( &(ih->biPlanes), 2, 1, fp);
	fread( &(ih->biBitCount), 2, 1, fp);
	fread( &(ih->biCompression), 4, 1, fp);
	fread( &(ih->biSizeImage), 4, 1, fp);
	fread( &(ih->biXPelsPerM), 4, 1, fp);
	fread( &(ih->biYPelsPerM), 4, 1, fp);
	fread( &(ih->biClrUsed), 4, 1, fp);
	fread( &(ih->biClrImportant), 4, 1, fp);
/*
    printf("el valor de bfType es: %s \n", h->bfType);
    printf("el valor de bfSize es: %d \n", h->bfSize);
    printf("el valor de bfReserv1 es: %hd \n", h->bfReserv1);
    printf("el valor de bfReserv2 es: %hd \n", h->bfReserv2);
    printf("el valor de bfOffBits es: %d \n\n", h->bfOffBits);
    printf("el valor de bfSize es: %d \n", ih->bfSize);

    printf("el valor de biWidth es: %d \n", ih->biWidth);

    printf("el valor de biHeight es: %d \n", ih->biHeight);

    printf("el valor de biPlanes es: %hd \n", ih->biPlanes);

    printf("el valor de biBitCount es: %hd \n", ih->biBitCount);

    printf("el valor de biCompression es: %d \n", ih->biCompression);

    printf("el valor de biSizeImage es: %d \n", ih->biSizeImage);

    printf("el valor de biXPelsPerM es: %d \n", ih->biXPelsPerM);

    printf("el valor de biYPelsPerM es: %d \n", ih->biYPelsPerM);

    printf("el valor de biClrUsed es: %d \n", ih->biClrUsed);

    printf("el valor de biClrImportant es: %d \n", ih->biClrImportant);
*/
	int tam = tamImg(ih);
	bufferImg = malloc(tam);

        if( esBmp( h ) && es24( ih ) && ( tamFile( h ) <= maxTamFile ) )
        {
            fread( bufferImg, 1, tam, fp );
        }
    }

    fclose(fp);

    return bufferImg;
}

void writebmp( char* bmpout, header* h, infoHeader* ih, char* bufferImg )
{
    /*writebmp: escribe el header y el infoHeader y copia los datos (ya descomprimidos) de
    la imagen que estan en un buffer en el archivo .bmp.*/
    FILE *fp;

    fp = fopen( bmpout, "w" );

    if( fp == NULL )
    {
        printf("error al intentar abrir la imagen \n");
    }
    else
    {
        fwrite( &(h->bfType), 2, 1, fp );
	fwrite( &(h->bfSize), 4, 1, fp );
	fwrite( &(h->bfReserv1), 2, 1, fp );
	fwrite( &(h->bfReserv2), 2, 1, fp );
	fwrite( &(h->bfOffBits), 4, 1, fp );

	fwrite( &(ih->bfSize), 4, 1, fp );
	fwrite( &(ih->biWidth), 4, 1, fp );
	fwrite( &(ih->biHeight), 4, 1, fp );
	fwrite( &(ih->biPlanes), 4, 1, fp );
	fwrite( &(ih->biBitCount), 4, 1, fp );
	fwrite( &(ih->biCompression), 4, 1, fp );
	fwrite( &(ih->biSizeImage), 4, 1, fp );
	fwrite( &(ih->biXPelsPerM), 4, 1, fp );
	fwrite( &(ih->biYPelsPerM), 4, 1, fp );
	fwrite( &(ih->biClrUsed), 4, 1, fp );
	fwrite( &(ih->biClrImportant), 4, 1, fp );

        fwrite( bufferImg, 1, tamImg( ih ), fp );
    }
    fclose(fp);
}
char* readoc2( char* oc2in, header* h, infoHeader* ih, Oc2FileHeader* oh, codificacion* tabla )
{
    /*readoc2: levanta las estructuras del encabezado del archivo .oc2 (header del .oc2,
    header e infoHeader del .bmp y tabla de codigos) y copia el bitstream de los datos
    comprimidos a un buffer.*/
    FILE *fp;
    char* bitstream;

    fp = fopen( oc2in, "r" );

    if( fp == NULL )
    {
        printf("error al intentar abrir la imagen \n");
    }
    else
    {
		/*Cargo el header*/
		fread( &(h->bfType), 2, 1, fp );
		fread( &(h->bfSize), 4, 1, fp );
		fread( &(h->bfReserv1), 2, 1, fp );
		fread( &(h->bfReserv2), 2, 1, fp );
		fread( &(h->bfOffBits), 4, 1, fp );
	
		/*Cargo el infoHeader*/
		fread( &(ih->bfSize), 4, 1, fp );
		fread( &(ih->biWidth), 4, 1, fp);
		fread( &(ih->biHeight), 4, 1, fp);
		fread( &(ih->biPlanes), 2, 1, fp);
		fread( &(ih->biBitCount), 2, 1, fp);
		fread( &(ih->biCompression), 4, 1, fp);
		fread( &(ih->biSizeImage), 4, 1, fp);
		fread( &(ih->biXPelsPerM), 4, 1, fp);
		fread( &(ih->biYPelsPerM), 4, 1, fp);
		fread( &(ih->biClrUsed), 4, 1, fp);
		fread( &(ih->biClrImportant), 4, 1, fp);

		fread( &(oh->fType), 4, 1, fp );
		fread( &(oh->tSize), 4, 1, fp );
		fread( &(oh->bSize), 4, 1, fp );
        if( esOc2( oh ) )
        {
		fread( tabla, 8, oh->tSize, fp );

		long long int tamBits = (oh->bSize / 8) + 1;
		fread( bitstream, 1, tamBits, fp );
        }
    }
    fclose(fp);

    return bitstream;
}
void writeoc2( char* oc2out, header* h, infoHeader* ih, Oc2FileHeader* oh, codificacion* tabla,int tam, char* bitstream,int tamBits )
{
    /*writeoc2: escribe el header del .oc2, el header e infoHeader del .bmp y la tabla de
    codigos, y copia el bitstream de los datos comprimidos que esta en un buffer en el
    archivo .bmp.oc2.*/
    FILE* fp;

    fp = fopen( oc2out, "w" );

    if( fp == NULL )
    {
        printf("error al intentar abrir la imagen \n");
    }
    else
    {
        fwrite( &(h->bfType), 2, 1, fp );
	fwrite( &(h->bfSize), 4, 1, fp );
	fwrite( &(h->bfReserv1), 2, 1, fp );
	fwrite( &(h->bfReserv2), 2, 1, fp );
	fwrite( &(h->bfOffBits), 4, 1, fp );

	fwrite( &(ih->bfSize), 4, 1, fp );
	fwrite( &(ih->biWidth), 4, 1, fp );
	fwrite( &(ih->biHeight), 4, 1, fp );
	fwrite( &(ih->biPlanes), 4, 1, fp );
	fwrite( &(ih->biBitCount), 4, 1, fp );
	fwrite( &(ih->biCompression), 4, 1, fp );
	fwrite( &(ih->biSizeImage), 4, 1, fp );
	fwrite( &(ih->biXPelsPerM), 4, 1, fp );
	fwrite( &(ih->biYPelsPerM), 4, 1, fp );
	fwrite( &(ih->biClrUsed), 4, 1, fp );
	fwrite( &(ih->biClrImportant), 4, 1, fp );

	fwrite( &(oh->fType), 4, 1, fp );
	fwrite( &(oh->tSize), 4, 1, fp );
	fwrite( &(oh->bSize), 4, 1, fp );

	fwrite( tabla, 8, tam, fp );

	fwrite( bitstream, 1, tamBits, fp );

    }
    fclose(fp);
}

/************************************************************************************
**                      Funciones de lectura de encabezados                        **
*************************************************************************************/

int esBmp( header* h )
{
    int res;
    //short int str_bm = 6677;
    //short int str = h->bfType;
    char* t;
    t = h->bfType;
    res = ( (t[0] == 'B') &&  (t[1]  == 'M') );
    //res = ( str == str_bm );
    return res;
}

long int tamFile( header* h )
{
    long int tam = h->bfSize;
    return tam;
}

long int tamImg( infoHeader* h )
{
    return h->biSizeImage;
}

int es24 ( infoHeader* h )
{
    return ( h->biBitCount == 24 );
}

int esOc2( Oc2FileHeader* h )
{
    int str_oc2 = 79834748;
    int res;
    res = ( h->fType == str_oc2 );
    return res;
}

long int aquiEmpieza( header* h )
{
    return h->bfOffBits;
}

long int ancho(infoHeader* h)
{
    return h->biWidth;
}

long long int tamImgOc2( Oc2FileHeader* h)
{
    return h->bSize;
}
