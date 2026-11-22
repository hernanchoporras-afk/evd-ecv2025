# Profundizacion exploratoria: ¿cambia la brecha economica segun Z2?
# Requiere haber ejecutado 00_preparar_datos.R y 01_inferencia.R.

if (!exists('d_principal') || !exists('gl') || !exists('salidas')) {
  stop('Primero ejecuta la preparacion de datos y la inferencia.')
}

niveles_z2 <- c('1 menor', '2 o mas menores')
datos <- d_principal$variables
if (!identical(levels(datos$Z2), niveles_z2)) {
  stop('Los niveles de Z2 cambiaron. Revisar su construccion antes de interpretar la interaccion.')
}
if (anyNA(datos[, c('Y', 'insuf', 'Z2')])) {
  stop('Se encontraron valores faltantes en el dominio de la interaccion.')
}

# Tamano de cada celda; se utiliza exactamente el dominio del contraste principal.
tabla <- as.data.frame(table(datos$X, datos$Z2))
names(tabla) <- c('ingresos', 'composicion_hogar', 'n')
tabla <- tabla[tabla$ingresos %in% c('Insuficientes', 'Justo alcanzan'), ]
stopifnot(sum(tabla$n) == 7451L, nrow(tabla) == 4L, all(tabla$n > 0L))
write.csv2(tabla, file.path(salidas, '09_celdas_heterogeneidad_Z2.csv'),
           row.names = FALSE)

# Con Z2 = "1 menor" como referencia:
# insuf = brecha economica para un menor;
# insuf:Z2 = cambio de la brecha para dos o mas menores.
modelo_z2 <- survey::svyglm(Y ~ insuf * Z2, design = d_principal)
b <- coef(modelo_z2)
V <- vcov(modelo_z2)
interaccion <- names(b)[grepl('insuf', names(b), fixed = TRUE) &
                          grepl('Z2', names(b), fixed = TRUE) &
                          grepl(':', names(b), fixed = TRUE)]
if (!('insuf' %in% names(b)) || length(interaccion) != 1L ||
    anyNA(b) || anyNA(V)) {
  stop('El modelo de interaccion no es estimable con la codificacion esperada.')
}

# Contrastes lineales que usan conjuntamente la matriz de covarianzas del diseno.
L <- matrix(0, nrow = 3, ncol = length(b),
            dimnames = list(c('1 menor', '2 o mas menores',
                              'Diferencia de brechas (2+ menos 1)'), names(b)))
L[1, 'insuf'] <- 1
L[2, c('insuf', interaccion)] <- 1
L[3, interaccion] <- 1
estimacion <- drop(L %*% b)
ee <- sqrt(diag(L %*% V %*% t(L)))
if (any(!is.finite(ee) | ee <= 0)) {
  stop('No fue posible estimar errores estandar validos.')
}

# La tercera fila prueba directamente la interaccion; las dos primeras
# describen las brechas por subgrupo con intervalos del 95 %.
critico <- qt(0.975, df = gl)
resultado <- data.frame(
  contraste = rownames(L),
  estimacion = as.numeric(estimacion),
  error_estandar = as.numeric(ee),
  li95 = as.numeric(estimacion - critico * ee),
  ls95 = as.numeric(estimacion + critico * ee),
  gl_referencia = rep(gl, 3),
  p_bilateral = c(NA_real_, NA_real_,
                  2 * pt(-abs(estimacion[3] / ee[3]), df = gl)),
  caracter = c('Exploratorio', 'Exploratorio', 'Exploratorio')
)
stopifnot(nrow(resultado) == 3L,
          abs(resultado$estimacion[2] - resultado$estimacion[1] -
                resultado$estimacion[3]) < 1e-8)
write.csv2(resultado, file.path(salidas, '10_interaccion_Z2.csv'),
           row.names = FALSE)

cat('\nContraste exploratorio de heterogeneidad por Z2:\n')
print(tabla, row.names = FALSE)
print(resultado, row.names = FALSE)
cat('La interaccion no demuestra causalidad ni valida subgrupos independientes.\n')
