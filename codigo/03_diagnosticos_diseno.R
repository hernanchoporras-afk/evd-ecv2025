# Diagnosticos reproducibles del marco y del dominio analitico.
# Requiere codigo/00_preparar_datos.R y codigo/01_inferencia.R.

psu_por_estrato <- function(d) {
  pares <- unique(d[, c('ESTRATO2020', 'SEGMENTO'), drop = FALSE])
  table(pares$ESTRATO2020)
}

contar_psu <- function(d) nrow(unique(d[, c('ESTRATO2020', 'SEGMENTO'), drop = FALSE]))

muestra_15_16 <- subset(marco, !is.na(X))
muestra_y <- subset(muestra_15_16, !is.na(Y))
comparacion <- subset(muestra_y, X %in% c('Insuficientes', 'Justo alcanzan'))

psu_m <- psu_por_estrato(marco)
psu_d <- psu_por_estrato(comparacion)

# Validacion de los identificadores de persona y los pesos que aporta DANE.
stopifnot(!anyDuplicated(clave(dis, llave_persona)),
          !anyDuplicated(clave(base, llave_persona)),
          nrow(marco) == nrow(dis),
          nrow(base) == 7792L,
          nrow(muestra_y) == 7717L,
          nrow(comparacion) == 7451L)

pesos_invalidos <- sum(!is.finite(marco$FEX_C) | marco$FEX_C <= 0)
control <- data.frame(
  indicador = c('personas_marco', 'adolescentes_15_16', 'y_calculable',
                'n_comparacion', 'segmentos_marco', 'estratos_marco',
                'segmentos_comparacion', 'estratos_comparacion',
                'solitarios_marco', 'solitarios_comparacion',
                'pesos_no_validos_marco', 'peso_min_marco',
                'peso_mediana_marco', 'peso_max_marco', 'gl_diseno'),
  valor = c(nrow(marco), nrow(base), nrow(muestra_y), nrow(comparacion),
            contar_psu(marco), length(psu_m), contar_psu(comparacion),
            length(psu_d), sum(psu_m == 1L), sum(psu_d == 1L),
            pesos_invalidos, min(marco$FEX_C),
            median(marco$FEX_C), max(marco$FEX_C), degf(d_total))
)
write.csv2(control, file.path(salidas, '05_diagnosticos_diseno.csv'),
           row.names = FALSE)

# Un segmento unico dentro de un estrato del dominio no implica que
# el estrato tenga un unico segmento en el marco completo.
resumen_solitarios <- data.frame(
  grupo = c('Marco completo', 'Dominio de contraste',
            'Ingresos insuficientes', 'Ingresos justo alcanzan'),
  n_observaciones = c(nrow(marco), nrow(comparacion),
                      sum(comparacion$X == 'Insuficientes'),
                      sum(comparacion$X == 'Justo alcanzan')),
  segmentos = c(contar_psu(marco), contar_psu(comparacion),
                contar_psu(subset(comparacion, X == 'Insuficientes')),
                contar_psu(subset(comparacion, X == 'Justo alcanzan'))),
  estratos = c(length(psu_m), length(psu_d),
               length(psu_por_estrato(subset(comparacion, X == 'Insuficientes'))),
               length(psu_por_estrato(subset(comparacion, X == 'Justo alcanzan')))),
  estratos_un_segmento = c(sum(psu_m == 1L), sum(psu_d == 1L),
                           sum(psu_por_estrato(subset(comparacion, X == 'Insuficientes')) == 1L),
                           sum(psu_por_estrato(subset(comparacion, X == 'Justo alcanzan')) == 1L))
)
write.csv2(resumen_solitarios,
           file.path(salidas, '06_solitarios_dominio.csv'), row.names = FALSE)

exclusiones <- data.frame(
  grupo = levels(base$X),
  n_15_16 = as.integer(table(base$X)[levels(base$X)]),
  n_sin_y = as.integer(table(factor(base$X[is.na(base$rezago)],
                                    levels = levels(base$X))))
)
exclusiones$n_con_y <- exclusiones$n_15_16 - exclusiones$n_sin_y
write.csv2(exclusiones,
           file.path(salidas, '08_exclusiones_por_X.csv'), row.names = FALSE)

# Se contrasta el tratamiento de PSU solitarias EN EL DOMINIO.
# No modifica el contraste principal y no certifica el diseno oficial.
ee_ajuste_dominio <- (function() {
  antes <- getOption('survey.adjust.domain.lonely')
  on.exit(options(survey.adjust.domain.lonely = antes), add = TRUE)
  options(survey.adjust.domain.lonely = TRUE)
  m <- svyglm(Y ~ insuf, design = d_principal)
  sqrt(unname(vcov(m)['insuf', 'insuf']))
})()

sensibilidad_solitarios <- data.frame(
  especificacion = c('Dominio solitario: sin ajuste adicional',
                     'Dominio solitario: ajuste activado'),
  error_estandar = c(principal$error_estandar, ee_ajuste_dominio),
  diferencia_estimada = principal$estimacion,
  referencia_df = gl
)
write.csv2(sensibilidad_solitarios,
           file.path(salidas, '07_sensibilidad_solitarios.csv'),
           row.names = FALSE)

stopifnot(contar_psu(marco) == 8543L, length(psu_m) == 356L,
          contar_psu(comparacion) == 4736L, length(psu_d) == 356L,
          sum(psu_d == 1L) == 2L,
          pesos_invalidos == 0L, degf(d_total) == 8187)
cat('Diagnosticos del diseno y del dominio: verificados.\n')
print(resumen_solitarios)
print(sensibilidad_solitarios)
