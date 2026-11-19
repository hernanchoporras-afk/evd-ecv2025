# Punto de entrada: reconstruccion, inferencia, visualizaciones y controles.
# Uso: Rscript --vanilla run/analisis_completo.R (desde la raiz)
source('run/verificar_insumos.R', encoding = 'UTF-8')

if (!requireNamespace('survey', quietly = TRUE)) {
  stop('Falta el paquete survey. Instala con install.packages("survey").')
}

source('codigo/00_preparar_datos.R', encoding = 'UTF-8')
source('codigo/01_inferencia.R', encoding = 'UTF-8')
source('codigo/02_figuras.R', encoding = 'UTF-8')
source('run/verificar_resultados.R', encoding = 'UTF-8')

cat('\nAnalisis ECV 2025 completado. Ver resultados/ y figuras/.\n')
