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

Los **nuevos resultados de sensibilidad a PSU solitarias** deben inspeccionarse después de ejecutar esta versión. No se presupone que el error estándar sea idéntico bajo ambas opciones.

## Validar GitHub Actions

Sube los archivos de `docs/`, `codigo/` y `run/` mediante GitHub Desktop y usa **Commit to main → Push origin**. En el workflow `ECV 2025 | Evidencia reproducible`, confirma una nueva ejecución **verde** y descarga el artifact `evidencia-ecv-2025` para revisar `05`–`08` y las tres figuras.

## Criterios de interpretación

Los controles de reproducibilidad numérica **no** validan automáticamente la interpretación causal, la definición institucional de extraedad, el diseño muestral oficial completo o el criterio de relevancia de 0,5 grados. Para la justificación, consultar `docs/metodologia.md` y `docs/evidencia.md`.
