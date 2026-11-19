# Etapa 2: tres figuras conectadas con preguntas del informe.
# Todas las figuras se reconstruyen desde los datos, no capturas del software.

etiqueta <- 'DANE, ECV 2025. Adolescentes 15-16 con Y calculable; estimaciones del equipo.'

# Figura 1: comparar distribuciones observadas, sin pretender inferencia.
d <- subset(marco, !is.na(Y) & X %in% c('Insuficientes', 'Justo alcanzan'))
lev <- c('Insuficientes', 'Justo alcanzan')
vals <- 0:10
tab <- sapply(lev, function(x) {
  y <- d$Y[d$X == x]
  as.numeric(table(factor(y, levels = vals))) / length(y)
})
png('figuras/01_distribucion_grupos.png', width = 1900, height = 1100, res = 200)
par(mar = c(5.8, 5.8, 5, 1.3), family = 'sans')
matplot(vals, tab * 100, type = 'o', pch = c(16, 17), lty = 1,
        col = c('#2F6B83', '#BA744B'), lwd = 2, xaxt = 'n',
        xlab = 'Grados de rezago (variable derivada)',
        ylab = 'Porcentaje dentro de cada grupo')
axis(1, at = vals)
title(main = 'Los dos grupos se solapan, aunque difieren en rezago medio', cex.main = 1.0)
legend('topright', lev, col = c('#2F6B83', '#BA744B'), lty = 1,
       pch = c(16, 17), bty = 'n')
mtext('Muestra sin ponderar: n = 3.524 y 3.927. Distribucion observada, no incertidumbre.',
      side = 1, line = 4.0, cex = .77)
mtext(etiqueta, side = 1, line = 5.0, cex = .66)
dev.off()

# Figura 2: medias poblacionales ponderadas e IC del 95%.
png('figuras/02_medias_ponderadas_ic95.png', width = 1900, height = 1100, res = 200)
par(mar = c(7.8, 5.6, 4.2, 1), family = 'sans')
xs <- seq_len(nrow(medias_df))
plot(xs, medias_df$media_ponderada, ylim = c(0, max(medias_df$ls95) * 1.15),
     xlim = c(.6, 3.4), xaxt = 'n', pch = 19, cex = 1.7,
     col = '#2F6B83', ylab = 'Rezago medio (grados escolares)', xlab = '')
segments(xs, medias_df$li95, xs, medias_df$ls95, col = '#2F6B83', lwd = 3)
segments(xs-.09, medias_df$li95, xs+.09, medias_df$li95, col = '#2F6B83', lwd = 2)
segments(xs-.09, medias_df$ls95, xs+.09, medias_df$ls95, col = '#2F6B83', lwd = 2)
axis(1, at = xs, labels = c('Ingresos\ninsuficientes', 'Justo\nalcanzan', 'Superan\nlos minimos'))
text(xs, medias_df$ls95 + .12, labels = paste0('n = ', format(medias_df$n, big.mark='.')), cex = .8)
title(main = 'El rezago medio estimado es mayor con ingresos insuficientes', cex.main = 1.0)
mtext('Puntos: medias ponderadas. Barras: IC 95% linealizados por estrato y segmento.',
      side = 1, line = 5.2, cex = .77)
mtext(etiqueta, side = 1, line = 6.3, cex = .65)
dev.off()

# Figura 3: contraste principal de A-B frente al metodo sin diseno.
a <- contrastes[1:2, ]
png('figuras/03_contraste_diseno_vs_welch.png', width = 1900, height = 1050, res = 200)
par(mar = c(5.7, 12.2, 4.2, 1.2), family = 'sans')
pos <- c(2, 1)
plot(a$estimacion, pos, xlim = range(c(0, a$li95, a$ls95)) + c(-.12,.12),
     ylim = c(.5, 2.6), yaxt = 'n', pch = 19, cex = 1.7,
     col = c('#2F6B83', '#BA744B'),
     xlab = 'Diferencia de rezago medio (insuficientes menos justo alcanzan)', ylab = '')
axis(2, at = pos, labels = c('Diseno ECV (ponderado)', 'Welch (sin diseno)'), las = 1)
abline(v = 0, lty = 2, col = '#777777')
segments(a$li95, pos, a$ls95, pos, lwd = 3, col = c('#2F6B83', '#BA744B'))
text(a$estimacion, pos + .22, labels = sprintf('%.3f [%.3f; %.3f]',
                                              a$estimacion, a$li95, a$ls95), cex = .85)
title(main = 'Los estimadores e intervalos cambian al considerar el diseno', cex.main = 1.0)
mtext('Barras: IC 95%. Diferentes estimadores y supuestos; Welch no representa el diseno complejo.',
      side = 1, line = 4.1, cex = .74)
mtext(etiqueta, side = 1, line = 5.1, cex = .64)
dev.off()
