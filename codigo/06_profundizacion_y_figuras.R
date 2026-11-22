# ============================================================================
# ECV 2025 | Parte 2 | Profundizacion inferencial familiar y figuras
# Ejecutar desde la RAIZ del repositorio, DESPUES de 00_preparar_datos.R
# y 01_inferencia.R (preferiblemente despues de 02_figuras.R).
# No sustituye los scripts anteriores ni reescribe sus resultados.
# ============================================================================

if (!requireNamespace('survey', quietly = TRUE)) {
  stop('Falta survey: install.packages("survey")')
}
objetos <- c('d_total', 'd_principal', 'marco', 'principal', 'alt',
             'contrastes', 'salidas')
faltan <- objetos[!vapply(objetos, exists, logical(1), inherits = TRUE)]
if (length(faltan)) {
  stop('Ejecuta antes 00_preparar_datos.R y 01_inferencia.R. Faltan: ',
       paste(faltan, collapse = ', '))
}
dir.create(salidas, recursive = TRUE, showWarnings = FALSE)
dir.create('figuras', recursive = TRUE, showWarnings = FALSE)

# 1. Misma subpoblacion de los dos grupos economicos para todos los modelos.
# subset() conserva la informacion de diseno necesaria para inferencia de dominio.
d_fam <- subset(d_principal, !is.na(Z1) & !is.na(Z2) & !is.na(Y_alt))
obs <- d_fam$variables
if (!all(c('Y','Y_alt','insuf','X','Z1','Z2') %in% names(obs))) {
  stop('Faltan columnas Y, Y_alt, insuf, X, Z1 o Z2 en el diseno.')
}
if (anyNA(obs[, c('Y','Y_alt','insuf','Z1','Z2')])) {
  stop('Quedan datos faltantes en la muestra de los nuevos modelos.')
}
if (!all(obs$insuf %in% c(0, 1))) stop('insuf debe ser 0/1.')
if (length(unique(obs$insuf)) != 2L) stop('No hay dos grupos economicos.')
for (z in c('Z1', 'Z2')) {
  if (!is.factor(obs[[z]]) || length(levels(obs[[z]])) != 2L ||
      any(table(obs[[z]]) == 0L)) {
    stop(z, ' debe ser un factor binario con ambos grupos observados.')
  }
}
n_muestra <- nrow(obs)
if (n_muestra != 7451L) {
  warning('La muestra nueva es de ', n_muestra,
          ' adolescentes, no de 7451. Revisar exclusiones antes de comparar.')
}
gl_diseno <- survey::degf(d_fam)
if (!is.finite(gl_diseno) || gl_diseno <= 0) {
  stop('No hay grados de libertad validos para inferencia.')
}

# 2. Contraste lineal usando la matriz de covarianzas de diseno.
# Se declara el criterio t de referencia: degf(d_fam), no gl de Welch.
contraste <- function(modelo, L, resultado, variable, tipo, grupo,
                      gl = gl_diseno) {
  b <- stats::coef(modelo)
  V <- stats::vcov(modelo)
  if (!all(names(L) %in% names(b))) {
    stop('Terminos ausentes: ', paste(setdiff(names(L), names(b)),
                                     collapse = ', '))
  }
  v <- stats::setNames(rep(0, length(b)), names(b))
  v[names(L)] <- as.numeric(L)
  est <- sum(v * b)
  ee2 <- as.numeric(crossprod(v, V %*% v))
  if (!is.finite(est) || !is.finite(ee2) || ee2 <= 0) {
    stop('Contraste no estimable: ', resultado, ' / ', variable, ' / ', tipo)
  }
  ee <- sqrt(ee2)
  tval <- est / ee
  critico <- stats::qt(.975, df = gl)
  data.frame(resultado = resultado, variable = variable,
             contraste = tipo, grupo = grupo,
             estimacion = as.numeric(est), error_estandar = ee,
             li95 = est - critico * ee, ls95 = est + critico * ee,
             estadistico_t = tval, p_bilateral = 2 * stats::pt(-abs(tval), gl),
             gl_diseno = gl, gl_residuales_modelo = stats::df.residual(modelo),
             n = n_muestra, stringsAsFactors = FALSE)
}

# 3. Heterogeneidad: comparar DIRECTAMENTE las brechas de dos grupos de Z.
# Con Y ~ insuf*Z, el coeficiente insuf:Z es la diferencia entre brechas
# (grupo 2 menos grupo 1). No inferir diferencias comparando p-valores separados.
ajustar_interaccion <- function(y, z) {
  f <- stats::as.formula(paste0(y, ' ~ insuf * ', z))
  m <- survey::svyglm(f, design = d_fam)
  nombres <- names(stats::coef(m))
  inter <- grep(paste0('^insuf:', z), nombres, value = TRUE)
  if (length(inter) != 1L) {
    stop('No se identifico una sola interaccion para ', y, ' y ', z,
         ': ', paste(nombres, collapse = ', '))
  }
  niveles <- levels(obs[[z]])
  tab <- rbind(
    contraste(m, c(insuf = 1), y, z, 'Brecha economica', niveles[1]),
    contraste(m, stats::setNames(c(1, 1), c('insuf', inter)),
              y, z, 'Brecha economica', niveles[2]),
    contraste(m, stats::setNames(1, inter), y, z,
              'Diferencia entre brechas (grupo 2 - grupo 1)',
              paste(niveles[2], 'menos', niveles[1]))
  )
  list(modelo = m, tabla = tab)
}

modelos_int <- list()
for (y in c('Y','Y_alt')) {
  for (z in c('Z1','Z2')) {
    modelos_int[[paste(y, z, sep = '_')]] <- ajustar_interaccion(y, z)
  }
}
interacciones <- do.call(rbind, lapply(modelos_int, `[[`, 'tabla'))
rownames(interacciones) <- NULL
interacciones$p_holm_2_interacciones <- NA_real_
for (y in c('Y','Y_alt')) {
  idx <- interacciones$resultado == y &
    grepl('Diferencia entre brechas', interacciones$contraste, fixed = TRUE)
  # Holm para las dos interacciones exploratorias de cada definicion de Y.
  interacciones$p_holm_2_interacciones[idx] <-
    stats::p.adjust(interacciones$p_bilateral[idx], method = 'holm')
}
utils::write.csv2(interacciones, file.path(salidas, '09_interacciones_Z1_Z2.csv'),
                  row.names = FALSE)

# 4. Brecha economica ajustada y asociaciones familiares con el nivel de Y.
# Modelo ADITIVO: asume una brecha economica comun para niveles de Z.
# No es estimacion causal ni prueba de ausencia de interaccion.
modelos_aj <- list()
filas_aj <- list()
filas_fam <- list()
termino <- function(m, z) {
  n <- names(stats::coef(m))
  res <- n[startsWith(n, z) & !grepl(':', n, fixed = TRUE)]
  if (length(res) != 1L) stop('No hay un unico coeficiente para ', z)
  res
}
for (y in c('Y','Y_alt')) {
  m1 <- survey::svyglm(stats::as.formula(paste0(y, ' ~ insuf + Z2')),
                       design = d_fam)
  m2 <- survey::svyglm(stats::as.formula(paste0(y, ' ~ insuf + Z1 + Z2')),
                       design = d_fam)
  modelos_aj[[paste0(y, '_Z2')]] <- m1
  modelos_aj[[paste0(y, '_Z1_Z2')]] <- m2
  filas_aj[[y]] <- rbind(
    contraste(m1, c(insuf = 1), y, 'Z2',
              'Brecha economica ajustada (aditiva)', 'Ajuste por Z2'),
    contraste(m2, c(insuf = 1), y, 'Z1+Z2',
              'Brecha economica ajustada (aditiva)', 'Ajuste por Z1 y Z2')
  )
  filas_fam[[y]] <- rbind(
    contraste(m2, stats::setNames(1, termino(m2,'Z1')), y, 'Z1',
              'Asociacion familiar ajustada (aditiva)',
              paste(levels(obs$Z1)[2], 'menos', levels(obs$Z1)[1])),
    contraste(m2, stats::setNames(1, termino(m2,'Z2')), y, 'Z2',
              'Asociacion familiar ajustada (aditiva)',
              paste(levels(obs$Z2)[2], 'menos', levels(obs$Z2)[1]))
  )
}
ajustadas <- do.call(rbind, filas_aj)
asociaciones <- do.call(rbind, filas_fam)
rownames(ajustadas) <- NULL; rownames(asociaciones) <- NULL
utils::write.csv2(ajustadas, file.path(salidas, '10_brechas_ajustadas.csv'),
                  row.names = FALSE)
utils::write.csv2(asociaciones,
                  file.path(salidas, '12_aporte_familiar_ajustado.csv'),
                  row.names = FALSE)

# 5. Auditoria: n de cada celda y GL del marco vs dominio.
n_celdas <- do.call(rbind, lapply(c('Z1','Z2'), function(z) {
  a <- as.data.frame(table(X = obs$X, Z = obs[[z]]),
                     stringsAsFactors = FALSE)
  a$variable <- z
  a <- a[a$X %in% c('Insuficientes','Justo alcanzan'), ]
  names(a) <- c('X','grupo','n_observado','variable')
  a[, c('variable','X','grupo','n_observado')]
}))
rownames(n_celdas) <- NULL
utils::write.csv2(n_celdas, file.path(salidas, '13_tamanios_celdas.csv'),
                  row.names = FALSE)
control <- data.frame(
  indicador = c('n_comparacion_familiar', 'GL_marco_completo',
                'GL_diseno_subpoblacion', 'GL_residuales_modelo_Y_Z1',
                'GL_residuales_modelo_Y_Z2'),
  valor = c(n_muestra, survey::degf(d_total), gl_diseno,
            stats::df.residual(modelos_int[['Y_Z1']]$modelo),
            stats::df.residual(modelos_int[['Y_Z2']]$modelo))
)
utils::write.csv2(control, file.path(salidas, '11_control_gl.csv'),
                  row.names = FALSE)
saveRDS(list(interacciones = interacciones, ajustadas = ajustadas,
             asociaciones = asociaciones, control = control,
             modelos_interaccion = lapply(modelos_int, `[[`, 'modelo'),
             modelos_aditivos = modelos_aj),
        file = file.path(salidas, '14_modelos_profundizacion.rds'))

# 6. Figuras de la profundizacion, generadas desde los estimadores (base R).
fmt <- function(x, d = 3) {
  formatC(x, format = 'f', digits = d, decimal.mark = ',')
}
fmt_n <- function(x) format(x, big.mark = '.', decimal.mark = ',',
                           scientific = FALSE, trim = TRUE)
azul <- '#276A89'; naranja <- '#B57143'; gris <- '#777777'

# 6A. Distribuciones PONDERADAS de grados, para acompañar la inferencia.
# No confundir porcentajes ponderados con IC de las medias.
d_plot <- stats::update(d_fam, grado_plot = factor(Y, levels = 0:10))
tab_peso <- as.matrix(survey::svytable(~X + grado_plot, design = d_plot))
grupos <- c('Insuficientes','Justo alcanzan')
porc <- 100 * prop.table(tab_peso[grupos, , drop = FALSE], margin = 1)
N1 <- sum(obs$X == grupos[1]); N2 <- sum(obs$X == grupos[2])
grDevices::png('figuras/01_distribucion_grupos_ponderada.png',
               width = 2100, height = 1300, res = 200)
graphics::par(mar = c(8.7, 6.4, 4.5, 1.6), family = 'sans')
graphics::matplot(0:10, t(porc), type = 'o', pch = c(16,17), lty = 1,
                  col = c(azul,naranja), lwd = 2.5, xaxt = 'n',
                  xlab = 'Grados de rezago educativo (indicador derivado)',
                  ylab = 'Porcentaje ponderado dentro de cada grupo',
                  main = 'La distribución ponderada del rezago difiere entre grupos')
graphics::axis(1, at = 0:10)
graphics::legend('topright', legend = grupos, col = c(azul,naranja),
                 pch = c(16,17), lty = 1, bty = 'n')
graphics::mtext(paste0('Muestra: n = ', fmt_n(N1), ' y ', fmt_n(N2),
                       '. Porcentajes ponderados con FEX_C; no son IC.'),
                side = 1, line = 5.1, cex = .77)
graphics::mtext('Fuente: DANE, ECV 2025; adolescentes de 15 y 16 años; cálculos del equipo.',
                side = 1, line = 6.35, cex = .72)
grDevices::dev.off()

# 6B. Forest plot PRINCIPAL: sensibilidad Y vs Y_alt y umbral exploratorio 0,5.
sens <- data.frame(
  nombre = c('Rezago edad - 6', 'Rezago edad - 7'),
  estimacion = c(principal$estimacion, alt$estimacion),
  li95 = c(principal$li95, alt$li95),
  ls95 = c(principal$ls95, alt$ls95))
pos <- c(2, 1)
grDevices::png('figuras/04_forest_sensibilidad_Y.png',
               width = 2100, height = 1250, res = 200)
graphics::par(mar = c(8.9, 12.3, 4.5, 1.5), family = 'sans')
graphics::plot(sens$estimacion, pos, pch = 19, cex = 1.6,
               col = c(azul,naranja), ylim = c(.5,2.5),
               xlim = c(-.08, max(sens$ls95) + .23), yaxt = 'n',
               xlab = 'Brecha media de rezago: insuficientes menos justo alcanzan',
               ylab = '', main = 'La brecha persiste; su magnitud depende de la medición')
graphics::axis(2, at = pos, labels = sens$nombre, las = 1)
graphics::abline(v = 0, lty = 2, col = gris)
graphics::abline(v = .5, lty = 3, lwd = 2, col = naranja)
graphics::segments(sens$li95, pos, sens$ls95, pos,
                   lwd = 3, col = c(azul,naranja))
graphics::text(sens$estimacion, pos + .23,
               labels = paste0(fmt(sens$estimacion), ' [', fmt(sens$li95),
                               '; ', fmt(sens$ls95), ']'), cex = .78)
graphics::legend('bottomright', legend = c('Igualdad de medias (0)',
                        'Referencia del equipo (0,5 grados)'),
                 lty = c(2,3), col = c(gris,naranja), bty = 'n', cex = .73)
graphics::mtext(paste0('Barras: IC del 95 %. Misma muestra (n = ', fmt_n(n_muestra),
                       ') y mismo diseño. Umbral 0,5: no oficial.'),
                side = 1, line = 5.1, cex = .76)
graphics::mtext('Fuente: DANE, ECV 2025; cálculos del equipo con survey.',
                side = 1, line = 6.4, cex = .72)
grDevices::dev.off()

# 6C. Brechas economicas dentro de cada grupo familiar (Y).
brechas <- interacciones[interacciones$resultado == 'Y' &
                          interacciones$contraste == 'Brecha economica', ]
if (nrow(brechas) != 4L) stop('Esperadas cuatro brechas condicionadas.')
pos <- 4:1; etiquetas <- paste0(brechas$variable, ' | ', brechas$grupo)
grDevices::png('figuras/05_brechas_familiares_ponderadas.png',
               width = 2150, height = 1380, res = 200)
graphics::par(mar = c(9.0, 14.5, 4.5, 1.6), family = 'sans')
graphics::plot(brechas$estimacion, pos, pch = 19, cex = 1.6,
               col = c(azul,azul,naranja,naranja),
               xlim = c(min(0, brechas$li95)-.09, max(brechas$ls95)+.25),
               ylim = c(.5,4.6), yaxt = 'n',
               xlab = 'Brecha económica de rezago (grados)', ylab = '',
               main = 'Brechas económicas ponderadas por condición familiar')
graphics::axis(2, at = pos, labels = etiquetas, las = 1)
graphics::abline(v = 0, lty = 2, col = gris)
graphics::segments(brechas$li95, pos, brechas$ls95, pos, lwd = 3,
                   col = c(azul,azul,naranja,naranja))
graphics::text(brechas$estimacion, pos + .23,
               labels = paste0(fmt(brechas$estimacion), ' [', fmt(brechas$li95),
                               '; ', fmt(brechas$ls95), ']'), cex = .75)
graphics::mtext('Barras: IC del 95 % con estratos, segmentos y FEX_C. La interacción prueba la diferencia de brechas.',
                side = 1, line = 5.2, cex = .69)
graphics::mtext('Fuente: DANE, ECV 2025; comparaciones exploratorias del equipo.',
                side = 1, line = 6.45, cex = .69)
grDevices::dev.off()

# 6D. Forest plot del contraste DIRECTO de heterogeneidad (Y y Y_alt).
dif_brechas <- interacciones[grepl('Diferencia entre brechas',
                                   interacciones$contraste, fixed = TRUE), ]
if (nrow(dif_brechas) != 4L) stop('Esperadas cuatro diferencias de brechas.')
pos <- 4:1
nombres <- paste(dif_brechas$resultado, dif_brechas$variable, sep = ' | ')
grDevices::png('figuras/06_diferencia_entre_brechas.png',
               width = 2150, height = 1300, res = 200)
graphics::par(mar = c(8.6, 10.2, 4.5, 1.5), family = 'sans')
graphics::plot(dif_brechas$estimacion, pos, pch = 19, cex = 1.6,
               col = rep(c(azul,naranja),2),
               xlim = range(c(0, dif_brechas$li95, dif_brechas$ls95)) + c(-.17,.17),
               ylim = c(.5,4.6), yaxt = 'n',
               xlab = 'Diferencia entre brechas (grupo 2 menos grupo 1), grados',
               ylab = '', main = 'La heterogeneidad familiar requiere un contraste directo')
graphics::axis(2, at = pos, labels = nombres, las = 1)
graphics::abline(v = 0, lty = 2, col = gris)
graphics::segments(dif_brechas$li95, pos, dif_brechas$ls95, pos,
                   lwd = 3, col = rep(c(azul,naranja),2))
graphics::text(dif_brechas$estimacion, pos + .22,
               labels = paste0(fmt(dif_brechas$estimacion), ' [',
                               fmt(dif_brechas$li95), '; ',
                               fmt(dif_brechas$ls95), ']'), cex = .74)
graphics::mtext('IC del 95 % del coeficiente de interacción; no equivale a comparar significancias por subgrupo.',
                side = 1, line = 5.0, cex = .7)
graphics::mtext('Fuente: DANE, ECV 2025; diferencias exploratorias estimadas por el equipo.',
                side = 1, line = 6.15, cex = .68)
grDevices::dev.off()

# 7. Salida legible y reproducibilidad.
cat('\n=== HETEROGENEIDAD: Z1 y Z2, con Y y Y_alt ===\n')
print(interacciones, row.names = FALSE)
cat('\n=== BRECHAS ECONOMICAS AJUSTADAS ===\n')
print(ajustadas, row.names = FALSE)
cat('\n=== ASOCIACIONES FAMILIARES EN NIVELES AJUSTADAS ===\n')
print(asociaciones, row.names = FALSE)
cat('\n=== CONTROL DE TAMANOS Y GL ===\n')
print(n_celdas, row.names = FALSE)
print(control, row.names = FALSE)
capture.output(utils::sessionInfo(), file = file.path(salidas,
                                                     '15_versiones_profundizacion.txt'))
cat('\nProfundizacion terminada. Resultados:', salidas,
    '| Figuras nuevas: figuras/01_, 04_, 05_, 06_\n')
