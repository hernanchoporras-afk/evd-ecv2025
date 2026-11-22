# Ejecutar y auditar el análisis ECV 2025

Desde la **raíz del repositorio** (la que contiene `codigo/`, `datos/`, `docs/` y `run/`), ejecutar:

```bash
Rscript --vanilla run/analisis_completo.R
```

Se necesita R y el paquete CRAN `survey`. En RStudio:

```r
if (!requireNamespace('survey', quietly = TRUE)) {
  install.packages('survey')
}
source('run/analisis_completo.R', encoding = 'UTF-8')
```

El procedimiento parte de los microdatos CSV originales de DANE en `datos/` y produce tablas en `resultados/`, figuras en `figuras/` y las versiones exactas de R y paquetes en `resultados/inferencia/versiones_R.txt`. Se emplean rutas relativas y **no** se requiere semilla, ya que el contraste y los diagnósticos actuales no usan remuestreo aleatorio.

## Etapas

| Archivo | Responsabilidad |
| --- | --- |
| `run/verificar_insumos.R` | Verifica que los seis CSV de origen estén disponibles |
| `codigo/00_preparar_datos.R` | Reconstruye Y, X, Z, integra archivos y declara el marco |
| `codigo/01_inferencia.R` | Calcula medias y contrastes con diseño aproximado y Welch |
| `codigo/03_diagnosticos_diseno.R` | Audita segmentos, estratos, exclusiones, pesos y unidades solitarias |
| `codigo/04_potencia_futura.R` | Construye **escenarios prospectivos** de tamaño muestral y potencia; no potencia observada |
| `codigo/02_figuras.R` | Genera tres imágenes a partir de los microdatos |
| `run/verificar_resultados.R` | Verifica integridad y cifras clave del proceso |
| `codigo/05_heterogeneidad_familiar.R` | Contrasta directamente la interacción de ingresos percibidos con Z2 para Y |
| `codigo/06_profundizacion_y_figuras.R` | Añade interacciones por Z1/Z2 para Y e Y_alt, ajustes aditivos y nuevas figuras |

## Archivos nuevos de verificación

Se generan en `resultados/inferencia/`:

| Archivo | Qué contiene |
| --- | --- |
| `03_potencia_futura.csv` | Tamaños prospectivos por grupo para 80 % y 90 % de potencia, con DEFF hipotéticos |
| `04_escenarios_potencia.csv` | Potencias aproximadas para tamaños y efectos de diseño alternativos |
| `05_diagnosticos_diseno.csv` | 235.350 personas, 8.543 segmentos, 356 estratos, 4.736 segmentos del contraste y pesos |
| `06_solitarios_dominio.csv` | Conteos de segmentos solitarios en marco, dominio y cada grupo |
| `07_sensibilidad_solitarios.csv` | EE principal comparado con la opción de ajuste a solitarios del dominio |
| `08_exclusiones_por_X.csv` | Distribución de 75 exclusiones según las tres categorías de suficiencia |
| `09_celdas_heterogeneidad_Z2.csv` y `10_interaccion_Z2.csv` | Conteos y contraste inicial Z2 |
| `09_interacciones_Z1_Z2.csv` | Doce contrastes: brechas por grupo e interacciones Z1/Z2 para Y e Y_alt, incluidos p de Holm |
| `10_brechas_ajustadas.csv` | Brechas económicas de modelos aditivos |
| `11_control_gl.csv` | Tamaño del dominio y referencias de grados de libertad |
| `12_aporte_familiar_ajustado.csv` | Coeficientes familiares de modelos aditivos |
| `13_tamanios_celdas.csv` | Conteos de las ocho celdas Z1/Z2 por suficiencia económica |
| `14_modelos_profundizacion.rds` | Objetos de modelos y tablas para auditoría en R |
| `15_versiones_profundizacion.txt` | Versiones de R y paquetes de la profundización |

La sensibilidad al tratamiento de unidades primarias de muestreo (PSU) solitarias fue ejecutada y verificada mediante GitHub Actions el 19 de noviembre de 2026.

El error estándar de la diferencia principal fue de **0,0674597832** bajo la especificación original y de **0,0674598149** al activar el ajuste alternativo, con una variación absoluta de **0,0000000317 grados**.

Esta comprobación demuestra estabilidad numérica frente al tratamiento evaluado, pero no certifica que la estimación de varianza reproduzca íntegramente el diseño muestral oficial del DANE.

## Profundización familiar reproducible

Los scripts `05` y `06` corren dentro de `run/analisis_completo.R`. Los nuevos CSV y las figuras `01_distribucion_grupos_ponderada.png`, `04_forest_sensibilidad_Y.png`, `05_brechas_familiares_ponderadas.png` y `06_diferencia_entre_brechas.png` quedan en el artefacto de GitHub Actions. La estimación puntual inicial de interacción Z2 se coteja con la segunda implementación. El script `06` utiliza 4.380 grados de libertad del dominio, mientras que el `05` reporta 8.187 del marco; se conserva esa distinción en la documentación. Los resultados son exploratorios y no prueban ausencia de heterogeneidad ni causalidad.

## Reproducibilidad mediante GitHub Actions

El análisis fue ejecutado y verificado en GitHub Actions el
19 de noviembre de 2026, mediante el workflow
`ECV 2025 | Evidencia reproducible`.

La ejecución generó el artefacto `evidencia-ecv-2025`,
que contiene las tablas de inferencia, los diagnósticos
del diseño muestral, los escenarios prospectivos de
potencia y las visualizaciones producidas por R.

### Resultados verificados

| Comprobación | Resultado |
| --- | --- |
| Adolescentes con rezago calculable | 7.717 |
| Adolescentes en el contraste principal | 7.451 |
| Diferencia ponderada estimada | 0,6361267 grados |
| Error estándar principal | 0,06745978 |
| IC del 95 % | [0,5038884; 0,7683650] |
| Segmentos del marco | 8.543 |
| Segmentos presentes en la comparación | 4.736 |
| Estratos del marco | 356 |
| Estratos con un único segmento en el dominio | 2 |

La comprobación de sensibilidad al tratamiento de
conglomerados solitarios produjo errores estándar de
0,0674597832 y 0,0674598149, respectivamente.

Los resultados principales también se reprodujeron
en Windows 11 con R 4.5.3 y `survey` 4.5.

### Repetir la ejecución

1. Acceder a la pestaña `Actions` del repositorio.
2. Seleccionar `ECV 2025 | Evidencia reproducible`.
3. Ejecutar `Run workflow` sobre la rama `main`.
4. Comprobar que la ejecución finalice correctamente.
5. Descargar el artefacto `evidencia-ecv-2025`.
6. Revisar las tablas de `resultados/inferencia/`
   y las imágenes generadas en `figuras/`.

Las verificaciones acreditan reproducibilidad numérica,
pero no implican causalidad ni equivalencia automática
con el estimador oficial del DANE.

## Criterios de interpretación

Los controles de reproducibilidad numérica **no** validan automáticamente la interpretación causal, la definición institucional de extraedad, el diseño muestral oficial completo o el criterio de relevancia de 0,5 grados. Para la justificación, consultar `docs/metodologia.md` y `docs/evidencia.md`.
