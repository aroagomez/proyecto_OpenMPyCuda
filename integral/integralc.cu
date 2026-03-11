/***********************************************************************
  integral.c (CUDA) - integral de una funcion 
  limites: 0 y 100
  num trapecios: 2^n

  ATENCION: compilar con la opcion -lm
************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

double fh (double x) 
{
  double  y; 

  y = 1.0 / (sin(x) + 2.0) + 1.0 / (sin(x)*cos(x) + 2.0);
  return (y); 
}

__device__ double fd (double x) 
{
  double  y; 

  y = 1.0 / (sin(x) + 2.0) + 1.0 / (sin(x)*cos(x) + 2.0);
  return (y); 
}

__global__ void Integrar (double a, double b, int n, double w, double *out) 
{ 
  extern __shared__ double temp[];

  double x, aux; 

  int idx = (blockDim.x * blockIdx.x) + threadIdx.x; 
  int stride = blockDim.x * gridDim.x;
  int tid = threadIdx.x;

  aux = 0.0;
  for (int i=idx; i<n; i+=stride) { 
    if (i > 0) {
    x =  (a + i*w);
    aux += fd(x); 
    }
  } 
  
  temp[tid] = aux;
  __syncthreads();

  for (int stride=1; stride<blockDim.x; stride*=2) {
      if (((tid % (2*stride)) == 0) && ((tid+stride) < blockDim.x)) temp[tid] += temp[tid + stride];
      __syncthreads();
  }

  if (tid == 0) out[blockIdx.x] = temp[tid];
}

void Leer_datos (int *n, int *numb, int *tamb)
{
  printf ("\nIntroduce n (numero de trapecios, 2^n): ");
  scanf  ("%d",n);
  (*n) = 1 << (*n);    // potencias de 2

  printf("\nIntroduce el número de bloques: ");
  scanf("%d", numb); 
  printf("\nIntroduce el tamaño del bloque: ");
  scanf("%d", tamb); 
}



int main () 
{
  double  a, b, w, resultado, *out, *dOut;    
  int n, numb, tamb;   
  double tex;
  struct timespec t0, t1;

  a = 0;
  b = 100;
  Leer_datos (&n, &numb, &tamb);

  out = (double *)  malloc (numb*sizeof(double));
  cudaMalloc(&dOut, numb*sizeof(double));

  clock_gettime (CLOCK_REALTIME, &t0);

  resultado = (fh(a) + fh(b)) / 2.0; 
  w = (b-a) / n;   

  cudaMemset(dOut, 0, numb*sizeof(double));
  Integrar <<<numb, tamb, tamb*sizeof(double)>>> (a, b, n, w, dOut);
  cudaMemcpy(out, dOut, numb*sizeof(double), cudaMemcpyDeviceToHost);

  for (int i=0; i<numb; i++) resultado += out[i];
  resultado *= w;

  clock_gettime (CLOCK_REALTIME, &t1);
  tex = (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) / (double)1e9;

  printf ("\nValor de la integral (%d trapecios): %.10f\n", n, resultado);
  printf ("Tiempo de ejecucion (Cuda (%dx%d)) = %1.3f ms \n\n", numb, tamb, tex*1000);

  return(0);
}

