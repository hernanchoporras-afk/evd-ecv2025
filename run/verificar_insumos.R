# Verifica presencia de los seis CSV oficiales antes de ejecutar el estudio.
if (!dir.exists('codigo') || !dir.exists('datos')) {
  stop('Ejecuta R desde la raiz del repositorio (donde estan codigo/ y datos/).')
}

insumos <- list(
  'Caracteristicas y composicion del hogar' = '^Caracteri.*[.]csv$',
  'Educacion' = '^Educaci.*[.]csv$',
  'Condiciones de vida del hogar' = '^Condiciones de vida del hogar.*[.]csv$',
  'Fuerza de trabajo' = '^Fuerza de trabajo[.]csv$',
  'Variables de diseno muestral' = '^Variables dise.*[.]csv$',
  'Datos de la vivienda' = '^Datos de la vivienda[.]csv$'
)

archivos <- list.files('datos', full.names = TRUE)
for (etiqueta in names(insumos)) {
  encontrados <- archivos[grepl(insumos[[etiqueta]], basename(archivos))]
  encontrados <- encontrados[file.exists(encontrados)]
  if (!length(encontrados) || !any(file.info(encontrados)$size > 0)) {
    stop('Falta o esta vacio el modulo requerido: ', etiqueta)
  }
  cat(sprintf('[OK] %s: %s\n', etiqueta, basename(encontrados[1])))
}
cat('Validacion inicial terminada. Los archivos estan disponibles.\n')
