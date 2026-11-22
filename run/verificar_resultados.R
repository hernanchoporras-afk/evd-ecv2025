# Control de integridad de salidas; no reemplaza la revision metodologica.
archivos_esperados <- c(
  'resultados/01_flujo_muestra.csv',
  'resultados/03_rezago_por_X.csv',
  'resultados/inferencia/00_control_marco.csv',
  'resultados/inferencia/01_medias_diseno.csv',
  'resultados/inferencia/02_contrastes.csv',
  'resultados/inferencia/03_potencia_futura.csv',
  'resultados/inferencia/04_escenarios_potencia.csv',
  'resultados/inferencia/05_diagnosticos_diseno.csv',
  'resultados/inferencia/06_solitarios_dominio.csv',
  'resultados/inferencia/07_sensibilidad_solitarios.csv',
  'resultados/inferencia/08_exclusiones_por_X.csv',
  'resultados/inferencia/versiones_R.txt',
  'resultados/inferencia/09_celdas_heterogeneidad_Z2.csv',
  'resultados/inferencia/10_interaccion_Z2.csv',
  'figuras/01_distribucion_grupos.png',
  'figuras/02_medias_ponderadas_ic95.png',
  'figuras/03_contraste_diseno_vs_welch.png'
)
faltantes <- archivos_esperados[!file.exists(archivos_esperados)]
if (length(faltantes)) stop('Faltan salidas: ', paste(faltantes, collapse = ', '))

salidas <- file.info(archivos_esperados)$size
if (any(is.na(salidas) | salidas <= 0)) stop('Se detectaron salidas vacias.')

control <- read.csv2('resultados/inferencia/00_control_marco.csv',
                     stringsAsFactors = FALSE)
stopifnot(control$valor[control$indicador == 'Y calculable'] == 7717)

contrastes <- read.csv2('resultados/inferencia/02_contrastes.csv',
                        stringsAsFactors = FALSE)
stopifnot(nrow(contrastes) >= 3L)
stopifnot(all(is.finite(contrastes$estimacion)))
stopifnot(all(contrastes$li95 < contrastes$ls95))
stopifnot(all(contrastes$p_bilateral >= 0 & contrastes$p_bilateral <= 1))

# Control de regresion basado en la corrida de GitHub Actions del 19/11/2026.
stopifnot(abs(contrastes$estimacion[1] - 0.6361267) < 0.0001)
cat('Controles de salidas y reproduccion: OK.\n')

# Verificaciones de estructura basadas en archivos y conteos efectivos.
diag <- read.csv2('resultados/inferencia/05_diagnosticos_diseno.csv',
                  stringsAsFactors = FALSE)
valor <- function(nombre) {
  v <- diag$valor[diag$indicador == nombre]
  stopifnot(length(v) == 1L)
  as.numeric(v)
}
stopifnot(valor('segmentos_marco') == 8543,
          valor('estratos_marco') == 356,
          valor('segmentos_comparacion') == 4736,
          valor('estratos_comparacion') == 356,
          valor('solitarios_comparacion') == 2,
          valor('pesos_no_validos_marco') == 0,
          valor('gl_diseno') == 8187)

pot <- read.csv2('resultados/inferencia/03_potencia_futura.csv',
                 stringsAsFactors = FALSE)
stopifnot(nrow(pot) == 6L, all(pot$n_por_grupo > 0),
          all(pot$potencia_aproximada >= 0 & pot$potencia_aproximada <= 1))
cat('Diagnosticos del diseno y planificacion prospectiva: OK.\n')


# Verificar el análisis de heterogeneidad familiar (Z2)

interaccion <- read.csv2(
  'resultados/inferencia/10_interaccion_Z2.csv',
  stringsAsFactors = FALSE
)


# Verificar el análisis de heterogeneidad familiar (Z2)

interaccion <- read.csv2(
  'resultados/inferencia/10_interaccion_Z2.csv',
  stringsAsFactors = FALSE
)

celdas_z2 <- read.csv2(
  'resultados/inferencia/09_celdas_heterogeneidad_Z2.csv',
  stringsAsFactors = FALSE
)

stopifnot(
  nrow(interaccion) == 3L,
  nrow(celdas_z2) == 4L,
  !anyNA(celdas_z2$n),
  sum(celdas_z2$n) == 7451L,
  all(is.finite(interaccion$estimacion)),
  all(is.finite(interaccion$error_estandar)),
  all(interaccion$error_estandar > 0),
  all(interaccion$li95 < interaccion$ls95),
  is.finite(interaccion$p_bilateral[3]),
  interaccion$p_bilateral[3] >= 0,
  interaccion$p_bilateral[3] <= 1
)

cat('Contraste exploratorio de heterogeneidad Z2: OK.\n')
