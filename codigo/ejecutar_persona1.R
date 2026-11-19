# Desde la raiz del proyecto, ejecutar:
# source('codigo/ejecutar_persona1.R', encoding = 'UTF-8')
if (!dir.exists('datos')) stop('Abre RStudio desde la carpeta del proyecto que contiene datos/.')
source('codigo/00_preparar_datos.R', encoding = 'UTF-8')
source('codigo/01_inferencia.R', encoding = 'UTF-8')
source('codigo/02_figuras.R', encoding = 'UTF-8')
cat('Completado: Parte 1 y Parte 2 Persona 1. Consultar resultados/persona1 y figuras/.\n')
