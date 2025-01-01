library(dplyr)
library(tidyr)
library(readr)
library(DT)
#install.packages("stringr")
library(stringr)
library(ggplot2)
library(caret)
library(nnet)
datos <- read.csv("C:/Users/USER/Documents/Proyecto minería/Datasets/blackjack_simulator.csv", sep = ",", header = TRUE, nrows= 50000)

#rm(datos)

set.seed(123)  
datos <- datos %>% sample_n(20000)
datos %>%
  filter(str_count(dealer_final, ",") > 4) %>%
  select(dealer_final)

datatable(head(datos))


datos <- datos %>%
  mutate(initial_hand = str_replace_all(initial_hand, "\\[|\\]", "")) %>%
  separate(initial_hand, into = c("carta1", "carta2"), sep = ",", fill = "right")

datatable(head(datos))

datos <- datos %>%
  mutate(dealer_final = str_replace_all(dealer_final, "\\[|\\]", "")) %>%
  separate(dealer_final, into = c("dealer_carta1", "dealer_carta2", "dealer_carta3", "dealer_carta4", "dealer_carta5", "dealer_carta6", "dealer_carta7"), sep = ", ", fill = "right")

replace_actions_multiple <- function(actions) {

  actions_list <- str_split(actions, ", ")
  

  actions_replaced <- lapply(actions_list, function(action_group) {
    sapply(action_group, function(action) {
      case_when(
        action == "H" ~ "Pedir",
        action == "S" ~ "Quedarse",
        action == "D" ~ "Doblar",
        action == "P" ~ "Dividir",
        action == "R" ~ "Rendirse",
        action == "I" ~ "Seguro",
        action == "N" ~ "No Seguro",
        TRUE ~ action
      )
    })
  })
  
  
  return(sapply(actions_replaced, function(x) paste(x, collapse = ", ")))
}


datos <- datos %>%
  mutate(actions_taken = str_replace_all(actions_taken, "\\[|\\]|'", ""),
         actions_taken = replace_actions_multiple(actions_taken))

datos <- datos %>%
  mutate(across(where(is.numeric), ~ replace_na(., 0)), 
         across(where(is.character), ~ replace_na(., "0")))

datatable(head(datos))

datos <- datos %>%
  mutate(resultado = case_when(
    win < 0 ~ "Perdió",
    win == 0 ~ "Empató",
    win > 0 ~ "Ganó"
  ))

ggplot(datos, aes(x = resultado)) +
  geom_bar(fill = "yellow", color = "black") +
  labs(title = "Resultados de la partida: Ganó, Empató o Perdió", 
       x = "Resultado", 
       y = "Número de partidas") +
  theme_minimal()

ggplot(datos, aes(x = dealer_final_value, fill = resultado)) +
  geom_density(alpha = 0.4) +
  labs(title = "Distribución del valor final del dealer",
       x = "Valor final del dealer", 
       y = "Densidad") +
  theme_minimal() +
  scale_fill_manual(values = c("Ganó" = "green", "Empató" = "yellow", "Perdió" = "red"))

ggplot(datos, aes(x = resultado, y = dealer_carta1, fill = resultado)) +
  geom_boxplot(outlier.colour = "red", outlier.shape = 16) +  # Resaltar outliers en rojo
  labs(title = "Distribución de la primera carta del dealer según el resultado del jugador",
       x = "Resultado del jugador", 
       y = "Primera carta del dealer") +
  scale_fill_manual(values = c("Ganó" = "green", "Empató" = "yellow", "Perdió" = "red")) +
  theme_minimal() +
  theme(legend.position = "top") 


acciones_frecuentes <- datos %>%
  group_by(actions_taken) %>%
  summarise(conteo = n()) %>%
  arrange(desc(conteo)) %>%
  slice_max(order_by = conteo, n = 5)  # Seleccionar las 5 más comunes


ggplot(acciones_frecuentes, aes(x = reorder(actions_taken, -conteo), y = conteo)) +
  geom_bar(stat = "identity", fill = "lightgreen", color = "black") +
  labs(title = "Las 5 acciones más comunes tomadas por los jugadores", 
       x = "Acción", 
       y = "Número de veces") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

table(datos$win)
datatable(head(datos))

# Asegúrate de tener las librerías necesarias
# install.packages("caret") # Si no tienes `caret` instalado
# install.packages("nnet")  # Si no tienes `nnet` instalado
# install.packages("NeuralNetTools")  # Si no tienes `NeuralNetTools` instalado

library(caret)
library(nnet)
library(NeuralNetTools)
# Red neuronal grande

## Minería

# Convertir resultado en factor
datos$resultado <- as.factor(datos$resultado)

# Seleccionar las columnas necesarias para el modelo
datos_modelo <- datos %>%
  select(carta1, carta2, dealer_carta1, dealer_carta2, dealer_carta3, dealer_carta4, dealer_carta5, dealer_carta6, dealer_carta7, dealer_final_value, actions_taken, resultado)

# Crear variables dummy
dummy <- dummyVars(" ~ .", data = datos_modelo)
datos_procesados <- data.frame(predict(dummy, newdata = datos_modelo))
head(datos_procesados)
datatable(head(datos_procesados))

# Añadir la columna resultado después de crear dummies y normalizar
datos_procesados$resultado <- datos_modelo$resultado

# Escalar los datos
preprocess <- preProcess(datos_procesados[, -ncol(datos_procesados)], method = c("center", "scale"))
datos_procesados[, -ncol(datos_procesados)] <- predict(preprocess, datos_procesados[, -ncol(datos_procesados)])

# Dividir los datos en entrenamiento y prueba
set.seed(123)
training_samples <- createDataPartition(datos_procesados$resultado, p = 0.8, list = FALSE)
train_data <- datos_procesados[training_samples, ]
test_data <- datos_procesados[-training_samples, ]

# Entrenar la red neuronal
modelo_nn <- nnet(resultado ~ ., data = train_data, size = 5, maxit = 200, linout = FALSE)
library(tidyr)

# Realizar predicciones
predicciones <- predict(modelo_nn, test_data, type = "class")
resultados <- data.frame(
  Real = test_data$resultado,
  Predicho = predicciones
)
resultados_long <- pivot_longer(resultados, 
                                cols = c("Real", "Predicho"), 
                                names_to = "Tipo", 
                                values_to = "Clase")

# Graficar la comparación de distribuciones
ggplot(resultados_long, aes(x = Clase, fill = interaction(Tipo, Clase))) +
  geom_bar(color = "black", position = "dodge") +  # 'dodge' para barras separadas
  labs(title = "Comparación de Clases Reales y Predichas",
       x = "Clase",
       y = "Frecuencia") +
  theme_minimal() +
  scale_fill_manual(values = c("Real.Ganó" = "green", "Predicho.Ganó" = "darkgreen", 
                               "Real.Empató" = "yellow", "Predicho.Empató" = "gold", 
                               "Real.Perdió" = "red", "Predicho.Perdió" = "darkred"))

cambio_gano <- resultados %>%
  filter(Real == "Ganó" & Predicho != "Ganó")

# Ver los primeros casos donde esto ocurrió
datatable(cambio_gano)



# Convertir predicciones y variable resultado en factores con los mismos niveles
predicciones <- factor(predicciones, levels = levels(test_data$resultado))
test_data$resultado <- factor(test_data$resultado, levels = levels(train_data$resultado))

# Evaluar el modelo con una matriz de confusión
conf_matrix <- confusionMatrix(predicciones, test_data$resultado)
print(conf_matrix)

# Calcular y mostrar la precisión
precision <- sum(predicciones == test_data$resultado) / nrow(test_data)
print(paste("Precisión del modelo:", round(precision * 100, 2), "%"))
library(NeuralNetTools)

# Graficar la red neuronal con plotnet()
plotnet(modelo_nn, 
        alpha = 0.6,               
        circle_col = "lightblue",  
        pos_col = "darkgray",      
        neg_col = "red",           
        bord_col = "black",
        max_sp = 1.5) 
#### preguntas1
acciones_efectivas <- datos %>%
  group_by(actions_taken) %>%
  summarise(ganados = sum(resultado == "Ganó"),
            total = n(),
            tasa_ganancia = ganados / total) %>%
  filter(total > 500) %>%  
  arrange(desc(tasa_ganancia), desc(total))  

datatable(acciones_efectivas)
head(acciones_efectivas)
# 1. Filtrar para las acciones de "Doblar"
acciones_doblar <- datos %>%
  filter(actions_taken == "Doblar")

# Convertir las cartas en factores si aún no lo están
acciones_doblar <- acciones_doblar %>%
  mutate(carta1 = as.factor(carta1),
         carta2 = as.factor(carta2),
         dealer_carta1 = as.factor(dealer_carta1),
         dealer_carta2 = as.factor(dealer_carta2))

# Filtrar solo las partidas ganadas para "Doblar"
acciones_doblar_ganadas <- acciones_doblar %>%
  filter(resultado == "Ganó")

# Crear una tabla con las combinaciones de cartas del jugador y del dealer para "Doblar"
combinaciones_cartas_doblar <- acciones_doblar_ganadas %>%
  group_by(carta1, carta2, dealer_carta1, dealer_carta2) %>%
  summarise(ganados = n(),
            total = n(),
            tasa_ganancia = ganados / total) %>%
  arrange(desc(tasa_ganancia))

# Filtrar para mostrar las combinaciones con más partidas (total mayor) para "Doblar"
combinaciones_cartas_doblar_mas_frecuentes <- combinaciones_cartas_doblar %>%
  filter(total > 5)  # Ajustar el umbral según lo que consideres significativo

# Mostrar los resultados para "Doblar"
datatable(combinaciones_cartas_doblar_mas_frecuentes)

# Visualización para "Doblar"
ggplot(combinaciones_cartas_doblar_mas_frecuentes, aes(x = interaction(carta1, carta2), y = tasa_ganancia, fill = tasa_ganancia)) +
  geom_bar(stat = "identity", color = "black") +
  labs(title = "Tasa de Ganancia por Combinación de Cartas - Doblar (Solo Ganadas)",
       x = "Combinación de Cartas",
       y = "Tasa de Ganancia") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 2. Filtrar para las acciones de "Quedarse"
acciones_quedarse <- datos %>%
  filter(actions_taken == "Quedarse")

# Convertir las cartas en factores si aún no lo están
acciones_quedarse <- acciones_quedarse %>%
  mutate(carta1 = as.factor(carta1),
         carta2 = as.factor(carta2),
         dealer_carta1 = as.factor(dealer_carta1),
         dealer_carta2 = as.factor(dealer_carta2))

# Filtrar solo las partidas ganadas para "Quedarse"
acciones_quedarse_ganadas <- acciones_quedarse %>%
  filter(resultado == "Ganó")

# Crear una tabla con las combinaciones de cartas del jugador y del dealer para "Quedarse"
combinaciones_cartas_quedarse <- acciones_quedarse_ganadas %>%
  group_by(carta1, carta2, dealer_carta1, dealer_carta2) %>%
  summarise(ganados = n(),
            total = n(),
            tasa_ganancia = ganados / total) %>%
  arrange(desc(tasa_ganancia))

# Filtrar para mostrar las combinaciones con más partidas (total mayor) para "Quedarse"
combinaciones_cartas_quedarse_mas_frecuentes <- combinaciones_cartas_quedarse %>%
  filter(total > 5)  # Ajustar el umbral según lo que consideres significativo

# Mostrar los resultados para "Quedarse"
datatable(combinaciones_cartas_quedarse_mas_frecuentes)

# Visualización para "Quedarse"
ggplot(combinaciones_cartas_quedarse_mas_frecuentes, aes(x = interaction(carta1, carta2), y = tasa_ganancia, fill = tasa_ganancia)) +
  geom_bar(stat = "identity", color = "black") +
  labs(title = "Tasa de Ganancia por Combinación de Cartas - Quedarse (Solo Ganadas)",
       x = "Combinación de Cartas",
       y = "Tasa de Ganancia") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


library(NeuralNetTools)

# Graficar la red neuronal con plotnet()
plotnet(modelo_nn, 
        alpha = 0.6,               # Transparencia de las conexiones
        circle_col = "lightblue",  # Color de las neuronas
        pos_col = "darkgray",      # Color de las conexiones positivas
        neg_col = "red",           # Color de las conexiones negativas
        bord_col = "black")        # Color del borde de las neuronas















#install.packages("NeuralNetTools")
library(NeuralNetTools)
#plotnet(modelo_nn, alpha = 0.3, circle_col = "lightblue", pos_col = "darkgray")

# Minería pequeña

# Convertir `resultado` en factor
datos$resultado <- as.factor(datos$resultado)

# Seleccionar un subconjunto de las columnas necesarias para el modelo (reducido)
datos_modelo <- datos %>%
  select(carta1, dealer_carta1, resultado)

# Crear variables dummy
dummy <- dummyVars(" ~ .", data = datos_modelo)
datos_procesados <- data.frame(predict(dummy, newdata = datos_modelo))

# Añadir la columna `resultado` después de crear dummies y normalizar
datos_procesados$resultado <- datos_modelo$resultado

# Escalar los datos
preprocess <- preProcess(datos_procesados[, -ncol(datos_procesados)], method = c("center", "scale"))
datos_procesados[, -ncol(datos_procesados)] <- predict(preprocess, datos_procesados[, -ncol(datos_procesados)])

# Dividir los datos en entrenamiento y prueba
set.seed(123)
training_samples <- createDataPartition(datos_procesados$resultado, p = 0.8, list = FALSE)
train_data <- datos_procesados[training_samples, ]
test_data <- datos_procesados[-training_samples, ]

# Entrenar una red neuronal pequeña
modelo_nn <- nnet(resultado ~ ., data = train_data, size = 2, maxit = 100, linout = FALSE)

# Realizar predicciones
predicciones <- predict(modelo_nn, test_data, type = "class")

# Convertir predicciones y variable `resultado` en factores con los mismos niveles
predicciones <- factor(predicciones, levels = levels(test_data$resultado))
test_data$resultado <- factor(test_data$resultado, levels = levels(train_data$resultado))

# Evaluar el modelo con una matriz de confusión
conf_matrix <- confusionMatrix(predicciones, test_data$resultado)
print(conf_matrix)

# Calcular y mostrar la precisión
precision <- sum(predicciones == test_data$resultado) / nrow(test_data)
print(paste("Precisión del modelo:", round(precision * 100, 2), "%"))

# Crear una función para obtener activaciones de la capa oculta
obtener_activaciones <- function(modelo, datos) {
  # Convertir los datos a numéricos para asegurar la compatibilidad en la multiplicación de matrices
  datos <- as.matrix(sapply(datos, as.numeric))
  
  # Multiplicación de pesos de entrada y suma del sesgo para cada neurona en la capa oculta
  pesos_entrada <- modelo$wts[1:(ncol(datos) * modelo$n[2])]
  pesos_sesgo <- modelo$wts[(ncol(datos) * modelo$n[2] + 1):(ncol(datos) * modelo$n[2] + modelo$n[2])]
  pesos_entrada <- matrix(pesos_entrada, ncol = modelo$n[2], byrow = TRUE)
  
  # Activaciones de la capa oculta para el primer caso
  activaciones_ocultas <- datos[1, ] %*% pesos_entrada + pesos_sesgo
  activaciones_ocultas <- 1 / (1 + exp(-activaciones_ocultas))  # función de activación sigmoide
  
  return(activaciones_ocultas)
}

# Obtener activaciones de la capa oculta para el primer caso de prueba
activaciones_primer_caso <- obtener_activaciones(modelo_nn, test_data[, -ncol(test_data)])

# Graficar las activaciones de las neuronas ocultas
barplot(as.numeric(activaciones_primer_caso), main = "Activaciones de la Red Neuronal", col = "lightblue", las = 2)

# Visualizar la red neuronal reducida
plotnet(modelo_nn, alpha = 0.3, circle_col = "lightblue", pos_col = "darkgray")

