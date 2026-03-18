# Computacion Paralela: OpenMP y CUDA

Este proyecto se centra en la paralelización y optimización de algoritmos matemáticos en C/C++, comparando el rendimiento de la ejecución en serie frente a la paralelización en CPU multinúcleo y la aceleración por hardware en GPU. Fue desarrollado para la asignatura de Sistemas Paralelos y Distribuidos del Grado en Inteligencia Artificial.

## Algoritmos Implementados
Se ha llevado a cabo el estudio y la paralelización de problemas computacionales intensivos:

* **Cálculo de Integrales:** Aproximación numérica mediante la suma del área de N trapecios bajo la curva. Se han desarrollado las tres versiones completas del algoritmo (Serie, OpenMP y CUDA).
* **Multiplicación Matriz-Vector (mxv):** Procesamiento de matrices cuadradas a gran escala (hasta dimensiones de 4096) para evaluar los cuellos de botella en la memoria y simular la carga de trabajo típica de las redes neuronales.

## Tecnologías y Modelos de Paralelización
Para la resolución de los problemas se han utilizado los siguientes paradigmas:

* **Ejecución en Serie (C estándar):** Código base ejecutado en un único hilo de CPU, utilizado como línea base (baseline) para el cálculo del Speedup.
* **OpenMP (CPU Multinúcleo):** Paralelización mediante directivas de preprocesador (#pragma omp parallel for). Se gestionan variables privadas, compartidas y operaciones de reducción para evitar condiciones de carrera durante la suma de las áreas.
* **CUDA (Aceleración en GPU):** Ejecución masiva utilizando el kernel de la tarjeta gráfica. Se gestiona de forma manual la jerarquía de memoria (transferencias host-to-device y device-to-host) y el diseño del grid/bloques de hilos. Se implementa el uso de memoria compartida (shared memory) y la sincronización a nivel de bloque (__syncthreads) para optimizar el rendimiento.

## Análisis de Rendimiento
El repositorio incluye un estudio técnico exhaustivo (Trabajo SPD - OpenMP y Cuda.pdf) donde se evalúan las siguientes métricas para distintos tamaños de problema (N) y configuraciones de hilos/bloques:

* **Tiempos de ejecución:** Medición estructurada para evaluar la viabilidad de cada modelo frente a cargas de trabajo escalables.
* **Factor de Aceleración (Speedup):** Cuantificación matemática de la mejora de velocidad respecto a la ejecución secuencial.

Las conclusiones del estudio demuestran cómo la arquitectura de la GPU (CUDA) supera ampliamente las limitaciones físicas de la CPU en valores grandes de N, consolidándose como la alternativa más eficiente para el procesamiento paralelo masivo.
