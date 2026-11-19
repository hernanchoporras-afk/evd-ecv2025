# ============================================================================
# UNIVERSIDAD DE LOS ANDES | EXPLORACION Y VISUALIZACION DE DATOS
# ECV 2025 - Proyecto Parte 1 | SCRIPT UNICO REPRODUCIBLE
#
# Pregunta: ¿como varia el rezago en escolaridad alcanzada (Y) segun la
# suficiencia percibida de ingresos (X), condicionando por ocupacion del
# jefe (Z1) y numero de menores residentes (Z2)?
#
# Descripcion de la muestra de adolescentes 15-16 anos; NO ponderada.
# No se estiman efectos causales ni se ejecutan pruebas de hipotesis.
# La Y es un indicador DERIVADO y NO es la tasa oficial de extraedad del MEN.
#
# EJECUCION: abrir RStudio desde la carpeta raiz que contiene datos/ y
# ejecutar source("ECV2025_Parte1_UNICO.R", encoding = "UTF-8")
# Entradas: SOLO cuatro CSV oficiales dentro de datos/.
# Salidas: tablas CSV + TRES figuras PNG dentro de resultados/.
# No requiere paquetes ni otros scripts. No modifica los archivos originales.
# ============================================================================

options(stringsAsFactors = FALSE)
if (!dir.exists("datos")) {
  stop("Abre el proyecto de RStudio desde la carpeta que contiene datos/.")
}
dir.create("resultados", showWarnings = FALSE, recursive = TRUE)

llave_persona <- c("DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA")
llave_hogar <- c("DIRECTORIO", "SECUENCIA_P")
clave <- function(datos, columnas) do.call(paste, c(datos[columnas], sep = "|"))

leer <- function(nombre, columnas) {
  archivo <- file.path("datos", nombre)
  if (!file.exists(archivo)) stop("Falta CSV: ", archivo)
  datos <- read.csv2(archivo, check.names = FALSE, stringsAsFactors = FALSE,
                     fileEncoding = "UTF-8-BOM")
  faltantes <- setdiff(columnas, names(datos))
  if (length(faltantes)) {
    stop("Columnas faltantes en ", nombre, ": ", paste(faltantes, collapse = ", "))
  }
  datos[, columnas, drop = FALSE]
}

exportar <- function(datos, nombre) {
  write.csv2(datos, file.path("resultados", nombre), row.names = FALSE)
}

# 1. Identificar la unidad de analisis y preservar las llaves.
cat("\n1. IMPORTACION, IDENTIFICACION E INTEGRACION\n")
p <- leer("Características y composición del hogar.csv",
          c(llave_persona, "P6040", "P6051", "P6020", "FEX_C"))
e <- leer("Educación.csv",
          c(llave_persona, "P8586", "P1088", "P1088S1",
            "P8587", "P8587S1"))
h <- leer("Condiciones de vida del hogar y tenencia de bienes.csv",
          c("DIRECTORIO", "SECUENCIA_ENCUESTA", "P9090"))
f <- leer("Fuerza de trabajo.csv",
          c(llave_persona, "P6240", "P6250", "P6260", "P6270"))
names(h)[names(h) == "SECUENCIA_ENCUESTA"] <- "SECUENCIA_P"

stopifnot(!anyDuplicated(clave(p, llave_persona)))
stopifnot(!anyDuplicated(clave(e, llave_persona)))
stopifnot(!anyDuplicated(clave(f, llave_persona)))
stopifnot(!anyDuplicated(clave(h, llave_hogar)))

ad <- p[p$P6040 %in% c(15, 16), c(llave_persona, "P6040", "FEX_C"), drop = FALSE]
stopifnot(nrow(ad) == 7792L)

# La muestra original tiene 7.792 adolescentes; no fusionar solo por DIRECTORIO.
base <- merge(ad, e, by = llave_persona, all.x = TRUE, sort = FALSE)
base <- merge(base, h, by = llave_hogar, all.x = TRUE, sort = FALSE)
stopifnot(nrow(base) == 7792L)
stopifnot(!anyNA(base$P8586), !anyNA(base$P9090))

# Control contrafactual de integracion: unir hogares solo por DIRECTORIO
# multiplica artificialmente algunas personas (7.850 frente a 7.792).
n_si_llave_incompleta <- nrow(merge(
  ad, h[, c("DIRECTORIO", "P9090"), drop = FALSE],
  by = "DIRECTORIO", all.x = TRUE, sort = FALSE
))
stopifnot(n_si_llave_incompleta == 7850L)

# Comparacion historica de la antigua Y de asistencia SOLO como control.
# El analisis principal de rezago sigue siendo completamente sin ponderar.
base$FEX_C <- as.numeric(gsub(",", ".", as.character(base$FEX_C), fixed = TRUE))
stopifnot(all(is.finite(base$FEX_C)), all(base$FEX_C > 0))
tasa_noasist_muestral <- 100 * mean(base$P8586 == 2)
tasa_noasist_ponderada <- 100 * sum(base$FEX_C * (base$P8586 == 2)) /
                           sum(base$FEX_C)
control_inicial <- data.frame(
  control = c("adolescentes_unicos", "filas_union_incorrecta",
              "filas_artificiales", "no_asistentes", "no_asistencia_muestral_pct",
              "no_asistencia_ponderada_pct"),
  valor = c(nrow(base), n_si_llave_incompleta,
            n_si_llave_incompleta - nrow(base), sum(base$P8586 == 2),
            tasa_noasist_muestral, tasa_noasist_ponderada)
)
exportar(control_inicial, "00_validacion_integracion.csv")
cat("Filas artificiales si se une solo por DIRECTORIO:",
    n_si_llave_incompleta - nrow(base), "\n")

# 2. Z1: reconocer al jefe primero, luego aplicar preguntas laborales.
jefes <- p[p$P6051 == 1, llave_persona, drop = FALSE]
stopifnot(nrow(jefes) == 87060L)
stopifnot(!anyDuplicated(clave(jefes, llave_hogar)))
jefes <- merge(jefes, f, by = llave_persona, all.x = TRUE, sort = FALSE)
stopifnot(nrow(jefes) == 87060L)
stopifnot(!anyNA(jefes$P6240))
jefes$ocupado_principal <- jefes$P6240 %in% 1
jefes$ocupado_ampliado <- (
  jefes$P6240 %in% 1 | jefes$P6250 %in% 1 |
  jefes$P6260 %in% 1 | jefes$P6270 %in% 1
)
stopifnot(sum(jefes$ocupado_principal) == 56340L)
stopifnot(sum(jefes$ocupado_ampliado) == 61432L)
z1 <- jefes[, c(llave_hogar, "ocupado_ampliado"), drop = FALSE]
base <- merge(base, z1, by = llave_hogar, all.x = TRUE, sort = FALSE)
stopifnot(nrow(base) == 7792L, !anyNA(base$ocupado_ampliado))

# 3. Z2: contar a TODOS los menores de edad del hogar, incluyendo al focal.
menores <- aggregate(
  list(n_menores18 = as.integer(!is.na(p$P6040) & p$P6040 < 18)),
  by = p[llave_hogar], FUN = sum
)
base <- merge(base, menores, by = llave_hogar, all.x = TRUE, sort = FALSE)
stopifnot(nrow(base) == 7792L, !anyNA(base$n_menores18))
stopifnot(all(base$n_menores18 >= 1))

# 4. Y: armonizar grado CURSADO de asistentes y APROBADO de no asistentes.
cat("\n2. CONSTRUCCION AUDITABLE DE Y, X Y Z\n")
base$grados_aprobados <- NA_real_
asiste <- base$P8586 == 1 & base$P1088 %in% c(2, 3, 4)
no_asiste <- base$P8586 == 2 & base$P8587 %in% c(3, 4, 5)
sin_escolaridad <- base$P8586 == 2 & base$P8587 == 1
# Segun los microdatos ECV, P1088S1/P8587S1 expresan grados globales.
base$grados_aprobados[asiste] <- base$P1088S1[asiste] - 1
base$grados_aprobados[no_asiste] <- base$P8587S1[no_asiste]
base$grados_aprobados[sin_escolaridad] <- 0

base$rezago <- pmax(0, base$P6040 - 6 - base$grados_aprobados)
base$rezago_conservador <- pmax(0, base$P6040 - 7 - base$grados_aprobados)
base$X <- factor(base$P9090, levels = c(1, 2, 3),
                 labels = c("Insuficientes", "Justo alcanzan", "Superan"))
base$Z1 <- factor(ifelse(base$ocupado_ampliado,
                          "Jefe ocupado", "Jefe no ocupado"),
                  levels = c("Jefe no ocupado", "Jefe ocupado"))
base$Z2 <- factor(ifelse(base$n_menores18 == 1,
                          "1 menor", "2 o mas menores"),
                  levels = c("1 menor", "2 o mas menores"))
base$asistencia <- factor(base$P8586, levels = c(1, 2),
                          labels = c("Estudia", "No estudia"))

n_valido <- sum(!is.na(base$rezago))
n_excluidos <- sum(is.na(base$rezago))
stopifnot(n_valido == 7717L, n_excluidos == 75L)
stopifnot(sum(base$Z1 == "Jefe ocupado") == 5991L)
stopifnot(sum(base$Z1 == "Jefe no ocupado") == 1801L)
stopifnot(!anyNA(base$X), !anyNA(base$Z1), !anyNA(base$Z2))

b <- base[!is.na(base$rezago), , drop = FALSE]
b$Y_clase <- cut(b$rezago, breaks = c(-0.1, 0.5, 1.5, 2.5, Inf),
                 labels = c("0 grados", "1 grado", "2 grados", "3 o mas"))
stopifnot(nrow(b) == 7717L, !anyNA(b$Y_clase))
stopifnot(sum(b$rezago >= 8) == 97L)

flujo <- data.frame(etapa = c("15-16 anos", "Con Y calculable", "Sin Y comparable"),
                    n = c(nrow(base), nrow(b), n_excluidos))
print(flujo, row.names = FALSE)
cat("Ocupados SOLO P6240:", sum(jefes$ocupado_principal),
    "| Ocupados ampliado:", sum(jefes$ocupado_ampliado), "\n")
exportar(flujo, "01_flujo_muestra.csv")

# 5. Tablas de EDA con estadisticas calculadas sobre las celdas pertinentes.
cat("\n3. EDA: Y, E[Y|X] Y E[Y|X,Z]\n")
resumir <- function(d) {
  data.frame(n = nrow(d),
             rezago_medio = mean(d$rezago),
             rezago_mediano = median(d$rezago),
             desviacion = sd(d$rezago),
             pct_2omas = 100 * mean(d$rezago >= 2),
             media_edad_menos7 = mean(d$rezago_conservador))
}

tabla_x <- do.call(rbind, lapply(levels(b$X), function(x) {
  d <- b[b$X == x, , drop = FALSE]
  cbind(X = x, resumir(d))
}))
rownames(tabla_x) <- NULL

tabla_condicionada <- function(zname) {
  grupos <- list()
  k <- 1L
  for (z in levels(b[[zname]])) {
    for (x in levels(b$X)) {
      d <- b[b$X == x & b[[zname]] == z, , drop = FALSE]
      grupos[[k]] <- cbind(X = x, Z = z, resumir(d))
      k <- k + 1L
    }
  }
  ans <- do.call(rbind, grupos)
  names(ans)[2] <- zname
  rownames(ans) <- NULL
  ans
}
tabla_z1 <- tabla_condicionada("Z1")
tabla_z2 <- tabla_condicionada("Z2")

frecuencias <- data.frame(rezago = 0:10,
                          n = as.integer(table(factor(b$rezago, levels = 0:10))))
frecuencias$porcentaje <- 100 * frecuencias$n / nrow(b)
stopifnot(sum(frecuencias$n) == 7717L)

extraer_brechas <- function(zname) {
  do.call(rbind, lapply(levels(b[[zname]]), function(z) {
    d1 <- b[b$X == "Insuficientes" & b[[zname]] == z, , drop = FALSE]
    d2 <- b[b$X == "Justo alcanzan" & b[[zname]] == z, , drop = FALSE]
    data.frame(variable = zname, grupo = z,
               n_insuficientes = nrow(d1), n_justo_alcanzan = nrow(d2),
               brecha_grados = mean(d1$rezago) - mean(d2$rezago),
               brecha_conservadora = mean(d1$rezago_conservador) -
                                     mean(d2$rezago_conservador))
  }))
}
brechas <- rbind(extraer_brechas("Z1"), extraer_brechas("Z2"))
rownames(brechas) <- NULL

exportar(frecuencias, "02_distribucion_Y.csv")
exportar(tabla_x, "03_rezago_por_X.csv")
exportar(tabla_z1, "04_rezago_por_X_Z1.csv")
exportar(tabla_z2, "05_rezago_por_X_Z2.csv")
exportar(brechas, "06_brechas_condicionadas.csv")

# 6. Composicion de Z2: estandarizacion DESCRIPTIVA directa.
# Pregunta: ¿cuanto cambia la brecha observada si ambos grupos economicos
# tienen la MISMA distribucion de Z2? No es ajuste causal.
centrales <- b[b$X %in% c("Insuficientes", "Justo alcanzan"), , drop = FALSE]
pesos_comunes <- as.numeric(prop.table(table(centrales$Z2)))
nombres_z2 <- levels(b$Z2)
nombres_x <- c("Insuficientes", "Justo alcanzan")
medias_cond <- sapply(nombres_x, function(x) {
  sapply(nombres_z2, function(z) mean(b$rezago[b$X == x & b$Z2 == z]))
})
medias_std <- colSums(medias_cond * pesos_comunes)
brecha_bruta <- mean(b$rezago[b$X == nombres_x[1]]) -
                mean(b$rezago[b$X == nombres_x[2]])
brecha_estandarizada <- medias_std[1] - medias_std[2]
tabla_estandar <- data.frame(
  grupo_Z2 = nombres_z2,
  peso_comun = pesos_comunes,
  proporcion_Z2_en_insuf = as.numeric(prop.table(table(
    b$Z2[b$X == "Insuficientes"]))),
  proporcion_Z2_en_alcanzan = as.numeric(prop.table(table(
    b$Z2[b$X == "Justo alcanzan"]))),
  media_insuficientes = medias_cond[, 1],
  media_justo_alcanzan = medias_cond[, 2]
)
comparacion_estandar <- data.frame(
  brecha_observada = brecha_bruta,
  brecha_con_pesos_comunes = as.numeric(brecha_estandarizada),
  diferencia_descriptiva = as.numeric(brecha_bruta - brecha_estandarizada)
)
exportar(tabla_estandar, "07_composicion_y_pesos_Z2.csv")
exportar(comparacion_estandar, "08_efecto_descriptivo_composicion.csv")
cat("\nBRECHA OBSERVADA:", round(brecha_bruta, 4), "grados\n")
cat("BRECHA CON COMPOSICION Z2 COMUN:",
    round(brecha_estandarizada, 4), "grados\n")
cat("CAMBIO AL IGUALAR PESOS DE COMPOSICION:",
    round(brecha_bruta - brecha_estandarizada, 4), "grados\n")

# 7. Sensibilidades: referencia edad-grado, extremos y condicion de asistencia.
tabla_sensibilidad <- do.call(rbind, lapply(levels(b$X), function(x) {
  d <- b[b$X == x, , drop = FALSE]
  sin_extremos <- d[d$rezago < 8, , drop = FALSE]
  data.frame(X = x, n = nrow(d), media_principal = mean(d$rezago),
             media_conservadora = mean(d$rezago_conservador),
             n_sin_extremos = nrow(sin_extremos),
             media_sin_extremos = mean(sin_extremos$rezago))
}))
rownames(tabla_sensibilidad) <- NULL
exportar(tabla_sensibilidad, "09_sensibilidad_Y_por_X.csv")

tabla_asistencia <- do.call(rbind, lapply(levels(b$asistencia), function(a) {
  do.call(rbind, lapply(levels(b$X), function(x) {
    d <- b[b$X == x & b$asistencia == a, , drop = FALSE]
    data.frame(asistencia = a, X = x, n = nrow(d),
               rezago_medio = mean(d$rezago),
               mediana = median(d$rezago),
               porcentaje_2omas = 100 * mean(d$rezago >= 2))
  }))
}))
rownames(tabla_asistencia) <- NULL
exportar(tabla_asistencia, "10_rezago_por_X_y_asistencia.csv")

cat("\nY SEGUN X:\n")
print(tabla_x, row.names = FALSE, digits = 4)
cat("\nBRECHAS CONDICIONADAS:\n")
print(brechas, row.names = FALSE, digits = 4)
cat("\nSENSIBILIDADES:\n")
print(tabla_sensibilidad, row.names = FALSE, digits = 4)

# 8. SOLO las tres figuras seleccionadas para el documento.
cat("\n4. FIGURAS DE EVIDENCIA\n")
azul <- "#32637A"
verde <- "#4C867D"
naranja <- "#BF8550"
gris <- "#A4AEB7"
texto <- "#263640"
nota <- "Fuente: DANE, ECV 2025. Adolescentes 15-16; muestra sin ponderar; Y derivada (edad - 6)."
fmt <- function(x, dec = 2) formatC(x, format = "f", digits = dec,
                                    decimal.mark = ",")
fmt_n <- function(x) format(x, big.mark = ".", decimal.mark = ",",
                             trim = TRUE, scientific = FALSE)

# Figura 04: distribucion completa de Y.
ruta <- file.path("resultados", "Figura_04_EDA5_distribucion_Y.png")
png(ruta, width = 1850, height = 950, res = 180)
par(mar = c(7.3, 6, 4.5, 2), family = "sans", col.axis = texto,
    col.lab = texto, col.main = texto)
alturas <- frecuencias$n
pos <- barplot(alturas, names.arg = as.character(0:10),
               col = c(azul, verde, rep(gris, 9)), border = NA,
               ylim = c(0, max(alturas) * 1.19),
               main = "El rezago se concentra en 0 y 1 grado y tiene cola derecha",
               ylab = "Numero de adolescentes en la muestra",
               xlab = "Grados de rezago respecto a la trayectoria de referencia",
               cex.names = 0.9, cex.lab = 0.95)
text(pos, alturas + max(alturas) * 0.033,
     labels = fmt_n(alturas), cex = 0.72, col = texto)
mtext("n valido = 7.717 | Media = 1,56 | Mediana = 1 | 39,61% con 2 o mas grados",
      side = 1, line = 4.25, cex = 0.79, col = texto)
mtext(nota, side = 1, line = 5.45, cex = 0.67, col = "#596872")
dev.off()
cat("Creada:", ruta, "\n")

# Figura 05: columnas normalizadas por categoria X; diferencia entre
# composicion PORCENTUAL y magnitudes absolutas.
tab <- table(ingresos = b$X, clase_rezago = b$Y_clase)
m <- t(prop.table(tab, margin = 1) * 100)
ruta <- file.path("resultados", "Figura_05_EDA5_distribucion_por_X.png")
png(ruta, width = 1800, height = 1020, res = 180)
par(mar = c(9.6, 5.8, 4.5, 1.5), family = "sans",
    col.axis = texto, col.lab = texto, col.main = texto)
cols <- c(azul, verde, naranja, gris)
pos <- barplot(m, beside = FALSE, col = cols, border = NA,
               names.arg = c("Ingresos\ninsuficientes",
                             "Justo\nalcanzan", "Superan\nlos minimos"),
               ylim = c(0, 110),
               main = "La composicion del rezago cambia con la suficiencia economica",
               ylab = "Porcentaje dentro de cada categoria de ingresos",
               cex.names = 0.9)
for (j in seq_len(ncol(m))) {
  inferior <- 0
  for (i in seq_len(nrow(m))) {
    valor <- m[i, j]
    if (valor >= 8) {
      text(pos[j], inferior + valor / 2,
           paste0(fmt(valor, 1), "%"),
           col = if (i %in% c(1, 2)) "white" else texto,
           cex = 0.83, font = 2)
    }
    inferior <- inferior + valor
  }
}
text(pos, rep(103, length(pos)),
     labels = paste0("n=", fmt_n(as.integer(rowSums(tab)))),
     cex = 0.9, col = texto)
legend("bottom", inset = c(0, -0.22), legend = rownames(m),
       fill = cols, horiz = TRUE, xpd = NA, bty = "n", cex = 0.81)
mtext("Las columnas suman 100%; comparar composicion, no cantidades poblacionales.",
      side = 1, line = 7.0, cex = 0.77, col = texto)
mtext(nota, side = 1, line = 8.2, cex = 0.66, col = "#596872")
dev.off()
cat("Creada:", ruta, "\n")

# Figura 06: medios condicionados a Z2 + n por celda.
medias <- matrix(NA_real_, nrow = 2, ncol = 3,
                 dimnames = list(levels(b$Z2), levels(b$X)))
ns <- medias
for (i in seq_len(nrow(tabla_z2))) {
  medias[as.character(tabla_z2$Z2[i]), as.character(tabla_z2$X[i])] <-
    tabla_z2$rezago_medio[i]
  ns[as.character(tabla_z2$Z2[i]), as.character(tabla_z2$X[i])] <-
    tabla_z2$n[i]
}
ruta <- file.path("resultados", "Figura_06_EDA5_condicionada_Z2.png")
png(ruta, width = 1830, height = 950, res = 180)
par(mar = c(7.7, 5.8, 4.4, 1.5), family = "sans",
    col.axis = texto, col.lab = texto, col.main = texto)
plot(1:3, medias[1, ], type = "n", xlim = c(0.75, 3.25),
     ylim = c(0, 2.5), xaxt = "n", xlab = "",
     ylab = "Rezago promedio (grados)",
     main = "La composicion familiar distingue niveles; las brechas son parecidas")
axis(1, at = 1:3,
     labels = c("Ingresos\ninsuficientes", "Justo\nalcanzan",
                "Superan\nlos minimos"))
abline(h = seq(0, 2.5, 0.5), col = "#E6EAEE", lty = 3)
for (j in 1:2) {
  color <- c(azul, naranja)[j]
  lines(1:3, medias[j, ], col = color, lwd = 2.5)
  points(1:3, medias[j, ], pch = 19, cex = 1.4, col = color)
  desplazamiento <- if (j == 1) -0.17 else 0.17
  text(1:3, medias[j, ] + desplazamiento,
       labels = paste0(fmt(medias[j, ], 2), "  (n=", ns[j, ], ")"),
       col = color, cex = 0.72)
}
legend("topright", legend = c("1 menor en el hogar", "2 o mas menores"),
       col = c(azul, naranja), lwd = 2.5, pch = 19,
       bty = "n", cex = 0.82, inset = 0.01)
mtext("Brecha insuficientes vs. justo alcanzan: 0,547 (1 menor) y 0,587 (2 o mas).",
      side = 1, line = 4.6, cex = 0.77, col = texto)
mtext(nota, side = 1, line = 5.7, cex = 0.66, col = "#596872")
dev.off()
cat("Creada:", ruta, "\n")

# 9. Verificaciones finales y resumen para la bitacora.
stopifnot(sum(tabla_x$n) == 7717L)
stopifnot(sum(tabla_z1$n) == 7717L)
stopifnot(sum(tabla_z2$n) == 7717L)
stopifnot(abs(mean(b$rezago) - 1.5600622) < 1e-4)
stopifnot(abs(brecha_bruta - 0.6055) < 0.001)
stopifnot(all(file.exists(file.path("resultados", c(
  "Figura_04_EDA5_distribucion_Y.png",
  "Figura_05_EDA5_distribucion_por_X.png",
  "Figura_06_EDA5_condicionada_Z2.png"
)))))
cat("\nSCRIPT UNICO COMPLETADO: 11 tablas CSV y 3 figuras PNG.\n")
cat("NOTA: analisis descriptivo de muestra; el indicador Y no es la extraedad oficial.\n")
