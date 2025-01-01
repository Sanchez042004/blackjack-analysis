# Análisis Estratégico del Blackjack 🃏

## Descripción del Proyecto  

Este proyecto utiliza el modelo **KDD (Knowledge Discovery in Databases)** para analizar datos históricos de partidas de Blackjack. El objetivo es identificar patrones estratégicos en el comportamiento de los jugadores y las cartas repartidas, ayudando a desarrollar estrategias que maximicen las posibilidades de ganar de manera informada y ética.

## Objetivos  
- **Comprender el dominio del problema**: Analizar las reglas del Blackjack y las dinámicas del juego en casinos.  
- **Selección y limpieza de datos**: Trabajar con datasets obtenidos de Kaggle para garantizar que los datos sean confiables.  
- **Identificación de patrones**: Explorar tendencias en las decisiones de los jugadores y los resultados de las partidas.  
- **Generación de conocimiento**: Proporcionar insights útiles para mejorar la toma de decisiones en el juego.  

## Metodología  
El proyecto sigue las fases del modelo **KDD**:  
1. **Dominio del problema**: Estudio de las reglas del Blackjack y contexto de juego en casinos.  
2. **Selección de datos**: Uso de datasets específicos de partidas históricas de Blackjack disponibles en Kaggle.  
3. **Limpieza y transformación**: Procesamiento de los datos para eliminar inconsistencias y preparar el dataset para el análisis.  
4. **Minería de datos**: Identificación de patrones relevantes en el comportamiento de jugadores y distribución de cartas, en este caso se utilizaron las redes neuronales para crear un modelo que pudiera aprender patrones en los datos y realizar predicciones.  
5. **Evaluación e interpretación**: Generación de resultados y conclusiones.

## Requisitos  
- **Lenguaje de programación**: R (versión 4.0 o superior recomendada).  
- **Paquetes**:  
  - tidyverse  
  - ggplot2  
  - dplyr  
  - knitr  
  - rmarkdown  
- **Datasets**:  
  - [900.000 Hands of BlackJack Results](https://www.kaggle.com/datasets/mojocolors/900000-hands-of-blackjack-results).
  - [50 Million Blackjack Hands](https://www.kaggle.com/datasets/dennisho/blackjack-hands).

## Resultados Esperados  

- **Gráficos y visualizaciones que describan tendencias y patrones.**  
  A continuación se muestran algunas de las gráficas que ilustran las tendencias y patrones descubiertos durante el análisis del juego de Blackjack.
  
  <img src="Capturas/Grafica1.jpg" alt="Gráfico 1: Resultados blackjack" width="500"/>
  
  *Figura 1: Resultados de las diferentes partidas de BlackJack.*

  <img src="Capturas/Grafica2.jpg" alt="Gráfico 2: Acciones comunes tomadas" width="500"/>
  
  *Figura 2: Acciones comunes tomadas por los jugadores.*

  <img src="Capturas/Grafica3.jpg" alt="Gráfico 3: Distribución del valor final del dealer" width="500"/>
  
  *Figura 3: Distribución del valor final de dealer con respecto al resultado.*

- **Conclusiones estratégicas basadas en los datos analizados.**  
  Basado en los análisis anteriores, se han derivado las siguientes conclusiones estratégicas:  
  - Los jugadores deben evitar apostar en manos de bajo valor y centrarse en maximizar sus apuestas en manos fuertes.  
  - El conteo de cartas es una estrategia viable para optimizar las decisiones.

- **Recomendaciones para optimizar las decisiones en el juego.**  
  Se recomienda a los jugadores ajustar sus estrategias según las cartas del crupier, particularmente en los escenarios mostrados en las gráficas.
