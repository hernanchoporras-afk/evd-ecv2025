# Control de integridad de salidas; no reemplaza la revision metodologica.
archivos_esperados <- c(
  'resultados/01_flujo_muestra.csv',
  'resultados/03_rezago_por_X.csv',
  'resultados/inferencia/00_control_marco.csv',
  'resultados/inferencia/01_medias_diseno.csv',
  'resultados/inferencia/02_contrastes.csv',
  'resultados/inferencia/03_potencia_hipotetica.csv',
  'resultados/inferencia/versiones_R.txt',
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
