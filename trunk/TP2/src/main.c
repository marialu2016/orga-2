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
    int bSize; //tamano en bytes del bitstream

} joc2FileHeader;

/************************************************************************************
**                              Funciones en C                                     **
************************************************************************************/

void bmp2joc2( char* bmpin, char* joc2out );
void joc22bmp( char* joc2in, char* bmpout );
int* generarQ();
char* readbmp( char* bmpin, header* h, infoHeader* ih );
void writebmp( char* bmpout, header* h, infoHeader* ih, char* bufferImg );
char* readjoc2( char* joc2in, header* h, infoHeader* ih, joc2FileHeader* joh);
void writejoc2( char* BufferjOc2, header* h, infoHeader* ih, joc2FileHeader* joh, char* bR, char* bG, char* bB, int tamR, int tamG, int tamB );

/************************************************************************************
**                              Funciones en Assembler                             **
************************************************************************************/

extern char* dividirBloques( char* imgCanal, int coord_i, int coord_j, int ancho );
extern float* generarDCT();
extern float* traspuesta( float* matriz );
extern void transformar( float* bloqueDe8x8, float* DCT );
extern short int* cuantizar( float* bloqueTransf, int* q);
extern char* codificar( short int* bloqueCuant, int* tam );
extern short int* decodificar( char* bitstream, int* offset );
extern float* decuantizar( short int* bloqueCuant, int* q );
extern void antiTransformar( float* bloqueTransf, float* DCT );
extern void unirBloques( char* bufferCanal, char* bloque, int coord_i, int coord_j, int ancho );

/************************************************************************************
**                     Funciones para el encabezado del BMP y OC2                  **
************************************************************************************/

int esBmp( header* h );
long int tamFile( header* h );
long int tamImg( infoHeader* h );
int es24( infoHeader* h );
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
    //joc22bmp( joc2in, bmpout );

    printf("vuelva prontos!\n");
    return 0;
}

/************************************************************************************
**                     Implementacion: Funciones en C                              **
************************************************************************************/

void bmp2joc2( char* bmpin, char* joc2out ){

    /*bmp2joc2: programa principal para comprimir.*/

    struct header vh;
    struct infoHeader vih;
    struct joc2FileHeader vjoh;
    struct header* h = &vh;
    struct infoHeader* ih = &vih;
    struct joc2FileHeader* joh = &vjoh;
    struct bufferRGB bf;
    struct bufferRGB* bRGB = &bf;

    char* bufferImg;
    char* bufferJoc2;
    char* bR = NULL;
    char* bG = NULL;
    char* bB = NULL;
    char* bitstreamR = NULL;
    char* bitstreamG = NULL;
    char* bitstreamB = NULL;
    int tamBufferR = 0;
    int tamBufferG = 0;
    int tamBufferB = 0;
    char* ptr_R;
    char* ptr_G;
    char* ptr_B;

    char* bloque;
    char* matriz;
    short int* mcuant;
    float* DCT = NULL;
    int* Q;

    long int i, j;
    int tam = 0;

    bufferImg = readbmp( bmpin, h, ih );

    bR = malloc( (ih->biWidth)*(ih->biHeight) );
    bG = malloc( (ih->biWidth)*(ih->biHeight) );
    bB = malloc( (ih->biWidth)*(ih->biHeight) );

    bitstreamR = malloc( (ih->biWidth)*(ih->biHeight) );
    bitstreamG = malloc( (ih->biWidth)*(ih->biHeight) );
    bitstreamB = malloc( (ih->biWidth)*(ih->biHeight) );

    ptr_R = bitstreamR;
    ptr_G = bitstreamG;
    ptr_B = bitstreamB;

    for( i = 0; i < (ih->biHeight)*3; i++ )
    {
        for(j = 0; j < (ih->biWidth)*3; j++)
        {
            if( (j % 3) == 0 )
            {
                bR[i/3][j/3] = bufferImg[i][j];
            }
            else
            {
                if( (j % 3) == 1 )
                {
                    bG[i/3][j/3] = bufferImg[i][j];
                }
                else
                {
                    bB[i/3][j/3] = bufferImg[i][j];
                }
            }
        }
    }

    joh->fType[0] = 'J';
    joh->fType[1] = 'O';
    joh->fType[2] = 'C';
    joh->fType[3] = '2';

    DCT = generarDCT();
    Q = generarQ();

    for( i = 0; i <  ih->biWidth; i+= 8 )
    {
        for( j = 0; j <  ih->biHeight; j+= 8 )
        {
            bloque = dividirBloques( bR, i, j, ih->biWidth);
            transformar( bloque , DCT );
            mcuant = cuantizar( bloque, Q );
            bufferJoc2  = codificar( mcuant, &tam );
            tamBufferR = tamBufferR + tam;
            memcpy( ptr_R, bufferJoc2, tam );
            ptr_R = ptr_R + tam;
        }
    }

    for( i = 0; i <  ih->biWidth ; i+= 8 )
    {
        for( j = 0; j <  ih->biHeight; j+= 8 )
        {
            bloque = dividirBloques( bG, i, j, ih->biWidth );
            transformar( bloque , DCT );
            mcuant = cuantizar( bloque, Q );
            bufferJoc2  = codificar( mcuant, &tam );
            tamBufferG = tamBufferG + tam;
            memcpy( ptr_G, bufferJoc2, tam );
            ptr_G = ptr_G + tam;
        }
    }

    for( i = 0; i <  ih->biWidth; i+= 8 )
    {
        for( j = 0; j <  ih->biHeight; j+= 8 )
        {
            bloque = dividirBloques( bB, i, j, ih->biWidth );
            transformar( bloque , DCT );
            mcuant = cuantizar( bloque, Q );
            bufferJoc2  = codificar( mcuant, &tam );
            tamBufferB = tamBufferB + tam;
            memcpy( ptr_B, bufferJoc2, tam );
            ptr_B = ptr_B + tam;
        }
    }
    joh->bSize = tamBufferR + tamBufferG + tamBufferB;
    writejoc2(joc2out, h,  ih, joh, bitstreamR, bitstreamG,bitstreamB, tamBufferR, tamBufferG, tamBufferB);

}

void joc22bmp( char* joc2in, char* bmpout ){
    /*joc22bmp: programa principal para descomprimir.*/
    struct header vh;
    struct infoHeader vih;
    struct joc2FileHeader vjoh;
    struct header* h = &vh;
    struct infoHeader* ih = &vih;
    struct joc2FileHeader* joh = &vjoh;
    struct bufferRGB bf;
    struct bufferRGB* bRGB = &bf;

    char* bitstream;
    char* bufferImg;
    char* bR = NULL;
    char* bG = NULL;
    char* bB = NULL;
    char* bitstreamR = NULL;
    char* bitstreamG = NULL;
    char* bitstreamB = NULL;
    int tamBufferR = 0;
    int tamBufferG = 0;
    int tamBufferB = 0;
    char* ptr_R;
    char* ptr_G;
    char* ptr_B;

    char* bloque;
    char* matriz;
    short int* mcuant;
    float* DCT = NULL;
    int* Q;

    long int i, j;
    int tam = 0;
    int offset = 0;

    bitstream = readjoc2( joc2in, h, ih, oh );

    DCT = generarDCT();
    Q = generarQ();

    i = j = 0;
    while( offset < joh->bSize )
    {
        mcuant = decodificar( bitstream, &offset);
        bloque = descuantizar( mcuant, Q );
        antitransformar( bloque, DCT );
        unirBloques( canal, bloque, i, j, ih->biWidth );
        i=+8;
        j=+8;
    }

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
                fread( &(joh->bSize), 4, 1, fp );

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

                    tamBits = joh->bSize;

                    /*reservo memoria para el bitstream*/

                    bitstream = malloc( tamBits );

                    /*Cargo el bitstream*/

                    fread( bitstream, 1, tamBits, fp );
                }
    }

    fclose(fp);

    return bitstream;

}

int* generarQ(){

    int* Q = NULL;

    Q = malloc(4*64);

    Q[1] = 16; Q[2] = 11; Q[3] = 10; Q[4] = 16; Q[5] = 24; Q[6] = 40; Q[7] = 51; Q[8] = 61;
    Q[9] = 12; Q[10] = 12; Q[11] = 14; Q[12] = 29; Q[13] = 26; Q[14] = 58; Q[15] = 50; Q[16] = 55;
    Q[17] = 14; Q[18] = 13; Q[19] = 16; Q[20] = 24; Q[21] = 40; Q[22] = 57; Q[23] = 69; Q[24] = 56;
    Q[25] = 14; Q[26] = 17; Q[27] = 22; Q[28] = 29; Q[29] = 51; Q[30] = 87; Q[31] = 80; Q[32] = 62;
    Q[33] = 18; Q[34] = 22; Q[35] = 37; Q[36] = 56; Q[37] = 68; Q[38] = 109; Q[39] = 103; Q[40] = 77;
    Q[41] = 24; Q[42] = 35; Q[43] = 55; Q[44] = 64; Q[45] = 81; Q[46] = 104; Q[47] = 113; Q[48] = 92;
    Q[49] = 49; Q[50] = 64; Q[51] = 78; Q[52] = 87; Q[53] = 103; Q[54] = 121; Q[55] = 120; Q[56] = 101;
    Q[57] = 72; Q[58] = 92; Q[59] = 95; Q[60] = 98; Q[61] = 112; Q[62] = 100; Q[63] = 103; Q[64] = 99;

    return Q;
}

void writejoc2( char* joc2out, header* h, infoHeader* ih, joc2FileHeader* joh, char* bR, char* bG, char* bB, int tamR, int tamG, int tamB )
{

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
            fwrite( &(joh->bSize), 4, 1, fp );

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

            fwrite( bR, 1, tamR, fp );
            fwrite( bG, 1, tamG, fp );
            fwrite( bB, 1, tamB, fp );
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







