/********************************************************
    mxv.c   matriz x vector  - SERIE

    Parametros: 
     1.- fichero con el tamano de las matrices a procesar
     2.- fichero de resultados
*********************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define VECES 100

// matriz x vector, por filas
void mxv (float *m, float *v, float *p, int N)
{
  int  i, j;

  for (i=0; i<N; i++)
  {
    p[i] = 0.0;
    for (j=0; j<N; j++) p[i] += m[i*N+j] * v[j];
  }
}


// inicializar la matriz y el vector
void inicializar (float *m, float *v, int N)
{
  int  i, j;

  srand (1);
  for (i=0; i<N; i++)
    for (j=0; j<N; j++) m[i*N+j] = rand() % 10; // inicializar matriz
  for (i=0; i<N; i++) v[i] = rand() % 10;	// inicializar vector
}


/**********     programa principal   ***************/
int main (int argc, char *argv[])
{
  int     i, j, k, nmat, N;
  float   *matriz, *vector, *producto;
  double  tex;
  struct  timespec  t0, t1;
  FILE    *fdm, *fdp;


  // comprobar si se han pasado los parametros
  if (argc!=3)
  {
   printf ("\nERROR: %s fichero_tamanos fichero_resultados\n", argv[0]);
   exit(-1);
  }

  printf ("\nSERIE");
  printf ("\n=======================");
  printf ("\nTam (N) --- Tex (ms)\n");

  fdp = fopen (argv[2],"w");  // abrir fichero resultados

  // abrir el fichero de tamanos
  if ((fdm = fopen (argv[1],"r"))==NULL)  
  {
    printf ("\nERROR al abrir el fichero de tamanos %s\n",argv[1]);
    exit (-1);
  }
  fscanf (fdm,"%d",&nmat);  // numero de productos

  // procesar todos los tamanos de matrices
  for (k=0; k<nmat; k++)
  {
    fscanf (fdm,"%d",&N);  // tamano de este producto
    matriz = (float *) malloc (N*N*sizeof (float));
    vector = (float *) malloc (N*sizeof (float));
    producto = (float *) malloc (N*sizeof (float));

    // inicializar matriz y vector
    inicializar (matriz, vector, N);

    // ejecutar varias veces, tiempo de ejecucion total
    tex=0.0;
    for (i=0; i<VECES; i++)
    {
      clock_gettime (CLOCK_REALTIME, &t0);
      mxv (matriz, vector, producto, N);     // producto mxv 
      clock_gettime (CLOCK_REALTIME, &t1);
      tex += (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) / (double)1e9;
    }
    // almacenar el producto 
    for (j=0; j<N; j++) fprintf (fdp, "%f\n", producto[j]);
  
    // imprimir tiempos de ejecucion y liberar memoria, para la siguiente prueba
    printf  ("  %5d\t    %8.4f\n", N, tex*1000);
    free (matriz); free (vector); free (producto);
  }

  printf ("\n");
  fclose(fdm);
  fclose (fdp);

  return 0;
}

