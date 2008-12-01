#include <stdio.h>
#include <stdlib.h>
#include "string.h"

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
extern float* transformar( char* bloqueDe8x8, float* DCT );
extern short int* cuantizar( float* bloqueTransf, int* q);
extern char* codificar( short int* bloqueCuant, int* tam );
extern short int* decodificar( char* bitstream, int* offset );
extern float* descuantizar( short int* bloqueCuant, int* q );
extern char* antiTransformar( float* bloqueTransf, float* DCT );
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
    char* bmpout = "testd.bmp";

    bmp2joc2( bmpin, joc2out );
    joc22bmp( joc2in, bmpout );

    printf("vuelva prontos!\n");
    return 0;
}

/************************************************************************************
**                     Implementacion: Funciones en C                              **
************************************************************************************/

void bmp2joc2( char* bmpin, char* joc2out )
{

    /*bmp2joc2: programa principal para comprimir.*/

    struct header vh;
    struct infoHeader vih;
    struct joc2FileHeader vjoh;
    struct header* h = &vh;
    struct infoHeader* ih = &vih;
    struct joc2FileHeader* joh = &vjoh;

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
    float* bloque_trans;
    short int* mcuant;
    float* DCT = NULL;
    int* Q;

    long int i, j, k;
    int tam = 0;

    bufferImg = readbmp( bmpin, h, ih );

    bR = malloc( ih->biSizeImage/3 );
    bG = malloc( ih->biSizeImage/3 );
    bB = malloc( ih->biSizeImage/3 );

    bitstreamR = malloc( ih->biSizeImage );
    bitstreamG = malloc( ih->biSizeImage );
    bitstreamB = malloc( ih->biSizeImage );

    ptr_R = bitstreamR;
    ptr_G = bitstreamG;
    ptr_B = bitstreamB;

    for( i = 0; i < ih->biSizeImage; i++ )
    {
	    k = i/3;
	    bR[k] = bufferImg[i];
	    i++;
	    k = i/3;
	    bG[k] = bufferImg[i];
	    i++;
	    k = i/3;
	    bB[k] = bufferImg[i];
    }

    free(bufferImg);

    joh->fType[0] = 'J';
    joh->fType[1] = 'O';
    joh->fType[2] = 'C';
    joh->fType[3] = '2';

    DCT = generarDCT();
    Q = generarQ();
int p;
    for( i = 0; i <  (ih->biWidth); i+= 8 )
    {
        for( j = 0; j <  (ih->biHeight); j+= 8 )
        {
            /*compresion del bloque correspondiente al canal rojo*/
            bloque = dividirBloques( bR, i, j, ih->biWidth);
            /*for(p = 0; p < 64; p++)
            {
                printf("la posicion %d tiene al %d \n", p, bloque[p] );
            }*/
            bloque_trans = transformar( bloque , DCT );
            /*for(p = 0; p < 64; p++)
            {
                printf("la posicion %d tiene al %f \n", p, bloque_trans[p] );
            }*/
            mcuant = cuantizar( bloque_trans, Q );
            /*for(p = 0; p < 64; p++)
            {
                printf("la posicion %d tiene al %d \n", p, mcuant[p] );
            }*/
            bufferJoc2  = codificar( mcuant, &tam );
            /*for(p = 0; p < tam; p++)
            {
                printf("la posicion %d tiene al %d \n", p, bufferJoc2[p] );
            }*/
            tamBufferR = tamBufferR + tam;
            memcpy( ptr_R, bufferJoc2, tam );
            ptr_R = ptr_R + tam;
            free(bloque);
            free(bloque_trans);
            free(mcuant);
            free(bufferJoc2);
            /*compresion del bloque correspondiente al canal verde*/
            bloque = dividirBloques( bG, i, j, ih->biWidth );
            bloque_trans = transformar( bloque , DCT );
            mcuant = cuantizar( bloque_trans, Q );
            bufferJoc2  = codificar( mcuant, &tam );
            tamBufferG = tamBufferG + tam;
            memcpy( ptr_G, bufferJoc2, tam );
            ptr_G = ptr_G + tam;
            free(bloque);
            free(bloque_trans);
            free(mcuant);
            free(bufferJoc2);
            /*compresion del bloque correspondiente al canal azul*/
            bloque = dividirBloques( bB, i, j, ih->biWidth );
            bloque_trans = transformar( bloque , DCT );
            mcuant = cuantizar( bloque_trans, Q );
            bufferJoc2  = codificar( mcuant, &tam );
            tamBufferB = tamBufferB + tam;
            memcpy( ptr_B, bufferJoc2, tam );
            ptr_B = ptr_B + tam;
            free(bloque);
            free(bloque_trans);
            free(mcuant);
            free(bufferJoc2);
        }
    }

    joh->bSize = tamBufferR + tamBufferG + tamBufferB;
    writejoc2(joc2out, h,  ih, joh, bitstreamR, bitstreamG,bitstreamB, tamBufferR, tamBufferG, tamBufferB);

    free(DCT);
    free(Q);
    free(bR);
    free(bG);
    free(bB);
    free(bitstreamR);
    free(bitstreamG);
    free(bitstreamB);

}

void joc22bmp( char* joc2in, char* bmpout ){
    /*joc22bmp: programa principal para descomprimir.*/
    struct header vh;
    struct infoHeader vih;
    struct joc2FileHeader vjoh;
    struct header* h = &vh;
    struct infoHeader* ih = &vih;
    struct joc2FileHeader* joh = &vjoh;

    char* bitstream;
    char* bufferImg;
    char* bR;
    char* bG;
    char* bB;
    //char* bitstreamR = NULL;
    //char* bitstreamG = NULL;
    //char* bitstreamB = NULL;
    //int tamBufferR = 0;
    //int tamBufferG = 0;
    //int tamBufferB = 0;
    //char* ptr_R;
    //char* ptr_G;
    //char* ptr_B;

    char* bloque;
    float* bloque_trans;
    short int* mcuant;
    float* DCT = NULL;
    int* Q;

    int i, j, k;
    //int tam = 0;
    int offset = 0;

    bitstream = readjoc2( joc2in, h, ih, joh );

    bufferImg = malloc( (ih->biSizeImage) );
    bR = malloc( (ih->biSizeImage)/3 );
    bG = malloc( (ih->biSizeImage)/3 );
    bB = malloc( (ih->biSizeImage)/3 );

    DCT = generarDCT();
    Q = generarQ();
int p;
    for( i = 0; i < (ih->biWidth); i+=8 )
    {
        for( j = 0; j < (ih->biHeight); j+=8 )
        {
            mcuant = decodificar( bitstream, &offset);
            bloque_trans = descuantizar( mcuant, Q );
            bloque = antiTransformar( bloque_trans, DCT );
            /*for(p = 0; p < 64; p++)
            {
                printf("la posicion %d tiene al %d \n", p, bloque[p] );
            }*/
            unirBloques( bR, bloque, i, j, ih->biWidth );
            free(mcuant);
            free(bloque_trans);
            free(bloque);

        }
    }
    offset = 0;
    for( i = 0; i < (ih->biWidth); i+=8 )
    {
        for( j = 0; j < (ih->biHeight); j+=8 )
        {
            mcuant = decodificar( bitstream, &offset);
            bloque_trans = descuantizar( mcuant, Q );
            bloque = antiTransformar( bloque_trans, DCT );
            unirBloques( bG, bloque, i, j, ih->biWidth );
            free(mcuant);
            free(bloque_trans);
            free(bloque);
        }
    }
    offset = 0;
    for( i = 0; i < (ih->biWidth); i+=8 )
    {
        for( j = 0; j < (ih->biHeight); j+=8 )
        {
            mcuant = decodificar( bitstream, &offset);
            bloque_trans = descuantizar( mcuant, Q );
            bloque = antiTransformar( bloque_trans, DCT );
            unirBloques( bB, bloque, i, j, ih->biWidth );
            free(mcuant);
            free(bloque_trans);
            free(bloque);
        }
    }

    for( i = 0; i < ih->biSizeImage; i++ )
    {
	    k = i/3;
	    bufferImg[i] = bR[k];
	    i++;
	    k = i/3;
        bufferImg[i] = bG[k];
	    i++;
	    k = i/3;
        bufferImg[i] = bB[k];
    }

    writebmp( bmpout,h,ih,bufferImg);

    free(bR);
    free(bG);
    free(bB);
    free(bufferImg);
    free(bitstream);
    free(DCT);
    free(Q);

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
        fwrite( &(ih->biPlanes), 2, 1, fp );
        fwrite( &(ih->biBitCount), 2, 1, fp );
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
                    /*transformo el tama�o que esta en Bytes a bits*/

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

    Q[0] = 16; Q[1] = 11; Q[2] = 10; Q[3] = 16; Q[4] = 24; Q[5] = 40; Q[6] = 51; Q[7] = 61;
    Q[8] = 12; Q[9] = 12; Q[10] = 14; Q[11] = 29; Q[12] = 26; Q[13] = 58; Q[14] = 50; Q[15] = 55;
    Q[16] = 14; Q[17] = 13; Q[18] = 16; Q[19] = 24; Q[20] = 40; Q[21] = 57; Q[22] = 69; Q[23] = 56;
    Q[24] = 14; Q[25] = 17; Q[26] = 22; Q[27] = 29; Q[28] = 51; Q[29] = 87; Q[30] = 80; Q[31] = 62;
    Q[32] = 18; Q[33] = 22; Q[34] = 37; Q[35] = 56; Q[36] = 68; Q[37] = 109; Q[38] = 103; Q[39] = 77;
    Q[40] = 24; Q[41] = 35; Q[42] = 55; Q[43] = 64; Q[44] = 81; Q[45] = 104; Q[46] = 113; Q[47] = 92;
    Q[48] = 49; Q[49] = 64; Q[50] = 78; Q[51] = 87; Q[52] = 103; Q[53] = 121; Q[54] = 120; Q[55] = 101;
    Q[56] = 72; Q[57] = 92; Q[58] = 95; Q[59] = 98; Q[60] = 112; Q[61] = 100; Q[62] = 103; Q[63] = 99;

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
            fwrite( &(ih->biPlanes), 2, 1, fp );
            fwrite( &(ih->biBitCount), 2, 1, fp );
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

    //int res;
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
