# Etapa 0: nombres de archivos, Parte 1 y marco del diseno.
# Ejecutar desde la carpeta raiz del proyecto, no desde codigo/.

salidas <- file.path('resultados', 'persona1')
dir.create(salidas, showWarnings = FALSE, recursive = TRUE)
dir.create('figuras', showWarnings = FALSE, recursive = TRUE)

archivos <- list(
  'Características y composición del hogar.csv' = '^Caracteri.*[.]csv$',
  'Educación.csv' = '^Educaci.*[.]csv$',
  'Condiciones de vida del hogar y tenencia de bienes.csv' = '^Condiciones de vida del hogar.*[.]csv$',
  'Fuerza de trabajo.csv' = '^Fuerza de trabajo.*[.]csv$',
  'Variables diseño muestral.csv' = '^Variables disen.*[.]csv$'
)
for (nombre in names(archivos)) {
  destino <- file.path('datos', nombre)
  if (!file.exists(destino)) {
    candidatos <- list.files('datos', pattern = archivos[[nombre]], full.names = TRUE)
    if (length(candidatos) != 1L) {
      stop('No se encontro un unico archivo para: ', nombre, '. Verifica datos/.')
    }
    if (!file.copy(candidatos, destino)) stop('No fue posible normalizar: ', nombre)
  }
}

# Reconstruir el rezago desde los CSV oficiales, reutilizando exactamente
# la definicion y las verificaciones de la Parte 1.
source(file.path('codigo', 'parte1', 'ECV2025_Parte1_UNICO.R'), encoding = 'UTF-8')
stopifnot(exists('b'), nrow(b) == 7717L)

variables_diseno <- c('DIRECTORIO', 'SECUENCIA_P', 'ORDEN',
                     'SEGMENTO', 'ESTRATO2020', 'MPIO', 'FEX_C')
dis <- read.csv2(file.path('datos', 'Variables diseño muestral.csv'),
                 check.names = FALSE, stringsAsFactors = FALSE,
                 fileEncoding = 'UTF-8-BOM')
stopifnot(all(variables_diseno %in% names(dis)), nrow(dis) == 235350L)
dis <- dis[, variables_diseno]
dis$SECUENCIA_ENCUESTA <- dis$ORDEN
stopifnot(!anyDuplicated(clave(dis, llave_persona)))

dis$FEX_C <- as.numeric(gsub(',', '.', as.character(dis$FEX_C), fixed = TRUE))
stopifnot(!anyNA(dis[, c('ESTRATO2020', 'SEGMENTO', 'FEX_C')]),
          all(is.finite(dis$FEX_C) & dis$FEX_C > 0))

# Conservar todas las personas del marco (235350): los dominios son
# subpoblaciones dentro del diseno, no muestras independientes nuevas.
analitica <- b[, c(llave_persona, 'rezago', 'rezago_conservador',
                   'X', 'Z1', 'Z2'), drop = FALSE]
marco <- merge(dis, analitica, by = llave_persona, all.x = TRUE, sort = FALSE)
stopifnot(nrow(marco) == 235350L, sum(!is.na(marco$rezago)) == 7717L)
marco$Y <- marco$rezago
marco$Y_alt <- marco$rezago_conservador
marco$insuf <- ifelse(is.na(marco$X), NA_integer_,
                      as.integer(marco$X == 'Insuficientes'))

# SEGMENTO identifica la USM; ESTRATO2020 es el estrato de muestreo.
# BLOQUE es para calibracion, no se sustituye por un estrato.
psus <- unique(marco[, c('SEGMENTO', 'ESTRATO2020')])
stopifnot(nrow(psus) == 8543L,
          length(unique(psus$ESTRATO2020)) == 356L,
          all(table(psus$ESTRATO2020) > 1L))
write.csv2(data.frame(indicador = c('Personas marco', 'Adolescentes seleccionados',
                                   'Y calculable', 'Segmentos marco', 'Estratos marco'),
                      valor = c(nrow(marco), 7792, 7717, nrow(psus), 356)),
           file.path(salidas, '00_control_marco.csv'), row.names = FALSE)
