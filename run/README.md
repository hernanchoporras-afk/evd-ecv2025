# Directorio de ejecución (`run/`)

El directorio `run/` contiene los **puntos de entrada y las verificaciones de ejecución**, separados del código que construye las variables y realiza la inferencia (`codigo/`).

| Archivo | Función |
| --- | --- |
| `verificar_insumos.R` | Confirma que los seis módulos originales están disponibles y no están vacíos. |
| `analisis_completo.R` | Reconstruye la base, estima las comparaciones y produce figuras y tablas. |
| `verificar_resultados.R` | Comprueba la generación de salidas y algunos controles de reproducibilidad. |

Desde la **raíz del repositorio**:

```bash
Rscript --vanilla run/analisis_completo.R
```

En RStudio, primero abre el proyecto desde la carpeta raíz y ejecuta:

```r
if (!requireNamespace('survey', quietly = TRUE)) install.packages('survey')
source('run/analisis_completo.R', encoding = 'UTF-8')
```

El flujo actual es determinista y no necesita semilla; si posteriormente se integra bootstrap u otro remuestreo, se documentarán explícitamente semilla, número de réplicas y unidad remuestreada.

La ejecución genera `resultados/` y `figuras/`. Estas carpetas se reconstruyen en cada ejecución y **no forman parte de los archivos fuente versionados**. Para reproducir el análisis en GitHub sin R instalado localmente, utiliza Actions y descarga el artefacto de la ejecución.

**Alcance:** los controles de integridad no prueban causalidad ni sustituyen la revisión del diseño muestral, la pertinencia de la prueba o la interpretación de resultados.
