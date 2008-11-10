#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/************************************************************************************
**                              Estructuras principales                            **
************************************************************************************/

typedef struct header{

    char bfType[2];     //angus no rompas..usamos un arreglo de 2 para el encabezado ;) para el "BM"
    long int bfSize;    //Tamano del archivo
    short int bfReserv1;
    short int bfReserv2;
    long int bfOffBits; //Offset desde el comienzo del archivo a los datos (en bytes)

} header;

typedef struct infoHeader{

    long int bfSize;    //Tamano de este header en bytes (40)
    long int biWidth;   //ancho en pixels
    long int biHeight;  //alto en pixels
    short int biPlanes; //1
    short int biBitCount;//1, 4, 8, 16, 24
    long int biCompression;
    long int biSizeImage;   //tamano de la imagen en bytes
    long int biXPelsPerM;
    long int biYPelsPerM;
    long int biClrUsed;
    long int biClrImportant;

} infoHeader;

typedef struct joc2FileHeader{

    char fType[4]; //es el string "JOC2"
    int bSize; //tamano en bits del bitstream

}joc2FileHeader;

/************************************************************************************
**                              Funciones en C                                     **
************************************************************************************/

void bmp2joc2( char* bmpin, char* joc2out );
void joc22bmp( char* joc2in, char* bmpout );
char* readbmp( char* bmpin, header* h, infoHeader* ih );
void writebmp( char* bmpout, header* h, infoHeader* ih, char* bufferImg );
char* readjoc2( char* joc2in, header* h, infoHeader* ih, joc2FileHeader* joh);
void writejoc2( char* BufferjOc2, header* h, infoHeader* ih, joc2FileHeader* joh, char* bitstream, int tamBits );

/************************************************************************************
**                              Funciones en Assembler                             **
************************************************************************************/

extern char* dividirEnBloques( char* imgCanal, int coord_i, int coord_j, int ancho );
extern float* generarDCT();
extern float* transpuesta( float* matriz );
extern void transformar( float* bloqueDe8x8, float* DCT );
/*extern*/ short int* cuantizar( float* bloqueTransf );
/*extern*/ char* codificar( short int* bloqueCuant );
/*extern*/ short int* decodificar( char* bitstream, char* ptr );
/*extern*/ float* decuantizar( short int* bloqueCuant );
/*extern*/ char* antiTransformar( float* bloqueTransf );
/*extern*/ char* unirBloques( char* bufferCanal, char* bloque, short int coord_i, short int coord_j );

/************************************************************************************
**                     Funciones para el encabezado del BMP y OC2                  **
************************************************************************************/

int esBmp( header* h );
long int tamFile( header* h );
long int tamImg( infoHeader* h );
int es24 ( infoHeader* h );
int esJoc2( joc2FileHeader* h );
long int aquiEmpieza( header* h );
long int ancho(infoHeader* h);
long long int tamImgJoc2( joc2FileHeader* h);

/************************************************************************************
**                                      MAIN                                       **
************************************************************************************/


int main()
{
    char* bmpin = "test.bmp";
    char* joc2out = "test.joc2";
    char* joc2in = "test.joc2";
    char* bmpout = "test2.bmp";

    bmp2joc2( bmpin, joc2out );
    joc22bmp( joc2in, bmpout );

    printf("vuelva prontos!\n");
    return 0;
}

/************************************************************************************
**                     Implementacion: Funciones en C                              **
************************************************************************************/

void bmp2joc2( char* bmpin, char* joc2out ){

    struct header vh;
    struct infoHeader vih;
    struct Oc2FileHeader voh;
    struct header* h = &vh;
    struct infoHeader* ih = &vih;
    struct Oc2FileHeader* oh = &voh;

    char* bufferImg;
    float* B;
    float* DCT;
    short int* mCuantizada;
    int trash;

    oh->fType[0] = 'J';
    oh->fType[1] = 'O';
    oh->fType[2] = 'C';
    oh->fType[3] = '2';

    bufferImg = readbmp( bmpin, h, ih );

    trash = (ih->biWidth) % 4;

    DCT = generarDCT();

    while(  )
    {
        B = dividirBloques();
        transformar( B, DCT );
        mCuantizada = cuantizar(  ):
        codificar( );
    }

    oh->bSize = 0;

    writeoc2( oc2out, h, ih, oh, bufferOc2, tamBitsBytes );
}

void joc22bmp( char* joc2in, char* bmpout ){

}

char* readbmp( char* bmpin, header* h, infoHeader* ih ){

    FILE* fp;
    char* bufferImg;
    int tam;

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

        tam = tamImg(ih);

        bufferImg = malloc(tam);

        if( esBmp( h ) && es24( ih ) )
        {
            fread( bufferImg, 1, tam, fp );
        }
    }

    fclose(fp);

    return bufferImg;
}

void writebmp( char* bmpout, header* h, infoHeader* ih, char* bufferImg ){

    /*writebmp: escribe el header y el infoHeader y copia los datos (ya descomprimidos) de
    la imagen que estan en un buffer en el archivo .bmp.*/

    FILE *fp;

    fp = fopen( bmpout, "w" );

    if( fp == NULL )
    {
        printf( "error al intentar abrir la imagen \n" );
    }
    else
    {

        /*Guardo el header del BMP*/

        fwrite( &(h->bfType), 2, 1, fp );
        fwrite( &(h->bfSize), 4, 1, fp );
        fwrite( &(h->bfReserv1), 2, 1, fp );
        fwrite( &(h->bfReserv2), 2, 1, fp );
        fwrite( &(h->bfOffBits), 4, 1, fp );

        /*Guardo el infoHeader del BMP*/

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

        /*Guardo el buffer con los datos de la imagen del BMP*/

        fwrite( bufferImg, 1, tamImg( ih ), fp );
    }

    fclose(fp);
}

char* readjoc2( char* joc2in, header* h, infoHeader* ih, joc2FileHeader* joh){

    /*readjoc2: levanta las estructuras del encabezado del archivo .oc2 (header del .oc2,
    header e infoHeader del .bmp) y copia el bitstream de los datos
    comprimidos a un buffer.*/

    FILE *fp;
    char* bitstream;
    long long int tamBits;

    fp = fopen( joc2in, "r" );

    if( fp == NULL )
    {
        printf( "error al intentar abrir la imagen \n" );
    }
    else
    {

                /*cargo el joc2FileHeader*/

                fread( &(joh->fType), 4, 1, fp );
                fread( &(joh->bSize), 8, 1, fp );

                /*Cargo el header*/

                fread( &(h->bfType), 2, 1, fp );
                fread( &(h->bfSize), 4, 1, fp );
                fread( &(h->bfReserv1), 2, 1, fp );
                fread( &(h->bfReserv2), 2, 1, fp );
                fread( &(h->bfOffBits), 4, 1, fp );

                /*Cargo el infoHeader*/

                fread( &( ih->bfSize), 4, 1, fp );
                fread( &( ih->biWidth), 4, 1, fp );
                fread( &( ih->biHeight), 4, 1, fp );
                fread( &( ih->biPlanes), 2, 1, fp );
                fread( &( ih->biBitCount), 2, 1, fp );
                fread( &( ih->biCompression), 4, 1, fp );
                fread( &( ih->biSizeImage), 4, 1, fp );
                fread( &( ih->biXPelsPerM), 4, 1, fp );
                fread( &( ih->biYPelsPerM), 4, 1, fp );
                fread( &( ih->biClrUsed), 4, 1, fp );
                fread( &( ih->biClrImportant), 4, 1, fp );

                if( esJoc2( joh ) )
                {
                    /*transformo el tamaño que esta en Bytes a bits*/

                    tamBits = ( joh->bSize / 8 ) + 1;

                    /*reservo memoria para el bitstream*/

                    bitstream = malloc( tamBits );

                    /*Cargo el bitstream*/

                    fread( bitstream, 1, tamBits, fp );
                }
    }

    fclose(fp);

    return bitstream;

}

void writejoc2( char* joc2out, header* h, infoHeader* ih, joc2FileHeader* joh, char* bitstream, int tamBits ){

    /*writejoc2: escribe el header del .joc2, el header y el infoHeader del .bmp y copia el bitstream
    comprimido que esta en el buffer en el archivo .joc2*/

    FILE* fp;

    fp = fopen( joc2out, "w" );

    if( fp == NULL )
    {
            printf( "error al intentar abrir el archivo\n" );
    }
    else
    {
            /*escribo el joc3FlileHeader de joc2*/

            fwrite( &(joh->fType), 4, 1, fp );
            fwrite( &(joh->bSize), 8, 1, fp );

            /*escribo el header del BMP*/

            fwrite( &(h->bfType), 2, 1, fp );
            fwrite( &(h->bfSize), 4, 1, fp );
            fwrite( &(h->bfReserv1), 2, 1, fp );
            fwrite( &(h->bfReserv2), 2, 1, fp );
            fwrite( &(h->bfOffBits), 4, 1, fp );

            /*escribo el infoHeader del BMP*/

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

            /*escribo el bitstram*/

            fwrite( bitstream, 1, tamBits, fp );
    }

    fclose(fp);
}


/************************************************************************************
**             Implementacion: Funciones para el encabezado del BMP y JOC2         **
************************************************************************************/


int esBmp( header* h ){

    int res;
    char* t;

    t = h->bfType;

    return ( (t[0] == 'B') &&  (t[1]  == 'M') ) ;
}

long int tamFile( header* h ){
    return h->bfSize;
}

long int tamImg( infoHeader* h ){
    return h->biSizeImage;
}

int es24 ( infoHeader* h ){
    return (h->biBitCount == 24);
}

int esJoc2( joc2FileHeader* h ){

    char* joc2 = "JOC2";

    return strcmp( h->fType, joc2 );
}

long int aquiEmpieza( header* h ){
    return h->bfOffBits;
}

long int ancho(infoHeader* h ){
    return h->biWidth;
}

long long int tamImgJoc2( joc2FileHeader* h ){
    return h->bSize;
}
