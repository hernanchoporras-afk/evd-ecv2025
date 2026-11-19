# Etapa 1: estimadores y contrastes compatibles con el diseno.
if (!requireNamespace('survey', quietly = TRUE)) {
  stop('Falta survey. Instala en R con install.packages("survey").')
}
library(survey)
# En algunos dominios un estrato puede contener solo un segmento con Y valida.
# Se preserva el marco completo y se indica como tratar casos solitarios.
options(survey.lonely.psu = 'adjust', survey.adjust.domain.lonely = FALSE)

# Mantener el marco entero para preservar estratos/segmentos en dominios.
d_total <- svydesign(ids = ~SEGMENTO, strata = ~ESTRATO2020,
                     weights = ~FEX_C, data = marco, nest = TRUE)
d_valido <- subset(d_total, !is.na(Y))
d_principal <- subset(d_total, !is.na(Y) &
                        X %in% c('Insuficientes', 'Justo alcanzan'))

# Grados de libertad del marco: segmento ultimo - estratos.
# Se reporta este valor para la aproximacion t, explicitando el supuesto.
gl <- degf(d_total)
stopifnot(gl == 8187L)

# Medias por las tres categorias economicas, con errores de diseno.
medias <- svyby(~Y, ~X, design = d_valido, FUN = svymean,
                na.rm = TRUE, vartype = c('se'), keep.names = FALSE)
medias_df <- data.frame(
  grupo = as.character(medias$X),
  n = as.integer(table(marco$X)[as.character(medias$X)]),
  media_ponderada = as.numeric(medias$Y),
  error_estandar = as.numeric(medias$se)
)
critico <- qt(0.975, df = gl)
medias_df$li95 <- medias_df$media_ponderada - critico * medias_df$error_estandar
medias_df$ls95 <- medias_df$media_ponderada + critico * medias_df$error_estandar
write.csv2(medias_df, file.path(salidas, '01_medias_diseno.csv'), row.names = FALSE)

# La pendiente de insuf equivale a media_insuf - media_justo.
modelo <- svyglm(Y ~ insuf, design = d_principal)
extraer_contraste <- function(mod, variable, gl, etiqueta) {
  estimacion <- unname(coef(mod)[variable])
  ee <- sqrt(unname(vcov(mod)[variable, variable]))
  t <- estimacion / ee
  data.frame(
    comparacion = etiqueta, estimacion = estimacion,
    error_estandar = ee, li95 = estimacion - qt(.975, gl) * ee,
    ls95 = estimacion + qt(.975, gl) * ee,
    estadistico_t = t, gl = gl, p_bilateral = 2 * pt(-abs(t), df = gl)
  )
}
principal <- extraer_contraste(modelo, 'insuf', gl,
                              'Insuficientes - Justo alcanzan (edad - 6)')

# Una alternativa NO equivalente para las poblaciones: Welch sin pesos ni clusters.
datos_principales <- subset(marco, !is.na(Y) &
                             X %in% c('Insuficientes', 'Justo alcanzan'))
datos_principales$X <- droplevels(datos_principales$X)
welch <- t.test(Y ~ X, data = datos_principales, var.equal = FALSE,
                alternative = 'two.sided', conf.level = 0.95)
# La formula se ordena alfabeticamente? Se fuerza la diferencia A-B.
val_welch <- mean(datos_principales$Y[datos_principales$X == 'Insuficientes']) -
             mean(datos_principales$Y[datos_principales$X == 'Justo alcanzan'])
se_welch <- unname(abs(val_welch / welch$statistic))
comp_welch <- data.frame(
  comparacion = 'Welch sin diseno, orientado A-B',
  estimacion = val_welch, error_estandar = se_welch,
  li95 = val_welch - qt(.975, welch$parameter) * se_welch,
  ls95 = val_welch + qt(.975, welch$parameter) * se_welch,
  estadistico_t = val_welch / se_welch,
  gl = unname(welch$parameter), p_bilateral = unname(welch$p.value)
)

# Comparacion de sensibilidad que reutilizara la persona 2.
modelo_alt <- svyglm(Y_alt ~ insuf, design = d_principal)
alt <- extraer_contraste(modelo_alt, 'insuf', gl,
                         'Insuficientes - Justo alcanzan (edad - 7)')
contrastes <- rbind(principal, comp_welch, alt)
write.csv2(contrastes, file.path(salidas, '02_contrastes.csv'), row.names = FALSE)

# Proyeccion ilustrativa de potencia para un FUTURO diseno equivalente,
# no potencia observada ni garantia en un estudio prospectivo.
delta_min <- 0.5 # benchmark provisional: media unidad de grado
z <- qnorm(.975)
no_central <- delta_min / principal$error_estandar
potencia_hipotetica <- pnorm(-z - no_central) + 1 - pnorm(z - no_central)
write.csv2(data.frame(delta_relevante_provisional = delta_min,
                      alpha = .05, error_estandar_supuesto = principal$error_estandar,
                      potencia_proyectada_condicional = potencia_hipotetica),
           file.path(salidas, '03_potencia_hipotetica.csv'), row.names = FALSE)

# Control externo de reproduccion de los numeros calculados de manera
# independiente con linealizacion por USM/estrato.
stopifnot(abs(principal$estimacion - 0.6361267) < 0.0001)
if (abs(principal$error_estandar - 0.0674598) > 0.003) {
  warning('EE distinto al chequeo independiente; revisar df, dominio y diseno.')
}
print(medias_df)
print(contrastes)
print(sessionInfo())
capture.output(sessionInfo(), file = file.path(salidas, 'versiones_R.txt'))
