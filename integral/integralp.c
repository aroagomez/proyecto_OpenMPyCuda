/***********************************************************************
  integral.c (PARALELO OPENMP) - integral de una funcion 
  limites: 0 y 100
  num trapecios: 2^n

  ATENCION: compilar con la opcion -lm
************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <omp.h>

double f (double x) 
{
  double  y; 

  y = 1.0 / (sin(x) + 2.0) + 1.0 / (sin(x)*cos(x) + 2.0);
  return (y); 
}

double Integrar (double a, double b, int n, double w) 
{ 
  double  resultado, x; 
  int     i; 

  resultado = (f(a) + f(b)) / 2.0; 

  #pragma omp parallel for private(i,x) shared(a,w), reduction(+:resultado) schedule(static)
  for (i=1; i<n; i++) 
  { 
    x = a + i*w; 
    resultado += f(x); 
  } 
  resultado *=  w; 

  return (resultado);
}

void Leer_datos (int *n)
{
  printf ("\nIntroduce n (numero de trapecios, 2^n): ");
  scanf  ("%d",n);
  (*n) = 1 << (*n);    // potencias de 2
}



int main () 
{
  double  a, b, w, resultado;    
  int n;   
  double tex;
  struct timespec t0, t1;

  a=0;
  b=100;
  Leer_datos (&n);

  clock_gettime (CLOCK_REALTIME, &t0);
  w = (b-a) / n;   
  resultado = Integrar (a, b, n, w);
  clock_gettime (CLOCK_REALTIME, &t1);
  tex = (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) / (double)1e9;

  printf ("\nValor de la integral (%d trapecios): %.10f\n", n, resultado);
  printf ("Tiempo de ejecucion (%d hilos) = %1.3f ms \n\n", omp_get_max_threads(), tex*1000);

  return(0);
}

