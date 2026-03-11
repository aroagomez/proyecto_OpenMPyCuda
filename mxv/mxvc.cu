/********************************************************
    mxvc.cu   matriz x vector  - CUDA

    Parametros: 
     1.- fichero con el tamano de las matrices a procesar
     2.- fichero de resultados
*********************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define VECES 100

// matriz x vector, por filas
__global__ void mxv (float *m, float *v, float *p, int N)
{
  int i = (blockDim.x * blockIdx.x) + threadIdx.x;
  float suma = 0.0;

  if (i<N){
    for (int j=0; j<N; j++) suma += m[i*N+j] * v[j];
  }

  p[i] = suma;
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
  int     i, j, k, nmat, N, numb, tamb;
  float   *matriz, *vector, *producto, *dMatriz, *dVector, *dProducto, tiempo;
  double  Ttotal, Tcopias, Tkernel;
  cudaEvent_t start,stop;
  struct  timespec  t0, t1, t2, t3;
  FILE    *fdm, *fdp;

  // comprobar si se han pasado los parametros
  if (argc!=3)
  {
   printf ("\nERROR: %s fichero_tamanos fichero_resultados\n", argv[0]);
   exit(-1);
  }

  printf("\nIntroduce el tamaño del bloque: ");
  scanf("%d", &tamb);

  printf ("\nCUDA");
  printf ("\n=======================");
  printf ("\nTam (N) --- numbxtamb --- Tkernel (ms) --- Ttotal (ms)\n");

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

    cudaMalloc (&dMatriz, N*N*sizeof(float));
    cudaMalloc (&dVector, N*sizeof(float));
    cudaMalloc (&dProducto, N*sizeof(float));

    // inicializar matriz y vector
    inicializar (matriz, vector, N);
    numb = (N+tamb-1)/tamb;

    //Copia de memoria de la CPU a la GPU:
    clock_gettime (CLOCK_REALTIME, &t0);
    cudaMemcpy(dMatriz, matriz, N*N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dVector, vector, N*sizeof(float), cudaMemcpyHostToDevice);
    clock_gettime (CLOCK_REALTIME, &t1);

    // ejecutar varias veces, tiempo de ejecucion total
    Tkernel = 0.0;
    for (i=0; i<VECES; i++)
    {
      cudaEventCreate(&start);
      cudaEventCreate(&stop); 
      cudaEventRecord(start,0);
      mxv <<<numb, tamb>>> (dMatriz, dVector, dProducto, N);     // producto mxv 
      cudaEventRecord(stop,0);
      cudaEventSynchronize(stop);
      cudaEventElapsedTime(&tiempo,start,stop);
      cudaEventDestroy(start);
      cudaEventDestroy(stop);
      Tkernel += tiempo;
    }

    //Copia de memoria de la GPU a la CPU:
    clock_gettime (CLOCK_REALTIME, &t2);
    cudaMemcpy(producto, dProducto, N*sizeof(float), cudaMemcpyDeviceToHost);
    clock_gettime (CLOCK_REALTIME, &t3);

    Tcopias = (t1.tv_sec - t0.tv_sec) + (t3.tv_sec - t2.tv_sec) + (((t1.tv_nsec - t0.tv_nsec) + (t3.tv_nsec - t2.tv_nsec)) / (double)1e9);
    Ttotal = Tkernel + Tcopias*1000;

    // almacenar el producto 
    for (j=0; j<N; j++) fprintf (fdp, "%f\n", producto[j]);
  
    // imprimir tiempos de ejecucion y liberar memoria, para la siguiente prueba
    printf  ("  %5d\t    %5dx%d\t    %8.4f\t    %8.4f\n", N, numb, tamb, Tkernel, Ttotal);
    free (matriz); free (vector); free (producto);
    cudaFree (dMatriz); cudaFree (dVector); cudaFree (dProducto);
  }

  printf ("\n");
  fclose(fdm);
  fclose (fdp);

  return 0;
}