# Metodología y alcance de la inferencia

**Estudio:** rezago educativo adolescente y condiciones familiares en Colombia. **Fuente:** microdatos de la ECV 2025 del DANE. **Estado:** contraste principal reproducido; inferencia exploratoria, no evaluación causal ni producto oficial del MEN.

## 2.1. De la exploración a una pregunta poblacional

**Decisor de referencia:** Subdirección de Permanencia del Ministerio de Educación Nacional; se trata de un actor hipotético para orientar el diagnóstico, no de una entidad que encargó o avaló el estudio. **Pregunta de negocio:** ¿qué dimensiones económicas y familiares convendría conservar y profundizar al caracterizar inicialmente el rezago educativo de adolescentes de 15 y 16 años?

**Pregunta analítica:** ¿cuál es la diferencia de rezago medio entre adolescentes de hogares que perciben sus ingresos como insuficientes y aquellos cuyos ingresos justo alcanzan, y qué papel descriptivo tienen la ocupación del jefe y la cantidad de menores del hogar?

La Parte 1 estimó, sin ponderar, una brecha de **0,6055 grados** (medias 1,9004 y 1,2949); esa observación motivó el contraste posterior. En consecuencia, **la hipótesis nace de un análisis exploratorio de los mismos datos** y no corresponde presentar la Parte 2 como validación independiente.

## 2.2. Datos, unidad de análisis, exclusiones y generalización

**Unidad de observación y análisis:** adolescente. **Periodo:** ECV 2025, corte transversal. **Alcance territorial:** población cubierta por la encuesta nacional; sin extrapolación automática a población no cubierta, años futuros, escuelas o adolescentes fuera de la cohorte.

| Etapa | Registros |
| --- | ---: |
| Adolescentes de 15–16 años identificados | 7.792 |
| Sin escolaridad comparable para construir `Y` | 75 |
| Con `Y` calculable | **7.717** |
| Ingresos insuficientes | 3.524 |
| Ingresos justo alcanzan | 3.927 |
| Ingresos superan gastos mínimos | 266 |
| Comparación principal (primeros dos grupos) | **7.451** |

Los 75 casos sin `Y` se descomponen por suficiencia económica en **26, 47 y 2**, respectivamente. La exclusión se debe a que la regla de homologación de escolaridad no produce una medida comparable, **no** a que el resultado de interés sea necesariamente cero. Los 266 del tercer grupo permanecen en la descripción, pero no integran el contraste entre las dos categorías centrales. No se supone que estas exclusiones sean aleatorias ni se corrigen con el factor de expansión.

**Variables:** `Y = max(0, edad - 6 - grados_aprobados)` (rezago derivado), `X = P9090` (percepción, no ingresos monetarios observados), `Z1` (jefe ocupado/no ocupado, no confundir no ocupado con desempleado), `Z2` (uno frente a dos o más menores residentes, incluido el propio adolescente). Como sensibilidad se define `Y_alt = max(0, edad - 7 - grados_aprobados)`. Ninguno de estos indicadores construidos es la tasa oficial de extraedad del MEN.

### Diseño muestral y auditoría reproducible

Según la ficha de metadatos del DANE, la ECV utiliza **UPM (municipios) y USM (segmentos de viviendas)** en un muestreo estratificado multietápico. El archivo público ofrece `FEX_C`, `ESTRATO2020` y `SEGMENTO`. El código representa una **aproximación basada en segmentos dentro de estratos**, no una reconstrucción certificada de todas las etapas, probabilidades de selección, correcciones finitas, calibraciones y estimadores oficiales de varianza.

```r
options(survey.lonely.psu = 'adjust',
        survey.adjust.domain.lonely = FALSE)
d_total <- survey::svydesign(
  ids = ~SEGMENTO, strata = ~ESTRATO2020,
  weights = ~FEX_C, data = marco, nest = TRUE
)
d_principal <- subset(d_total,
  !is.na(Y) & X %in% c('Insuficientes', 'Justo alcanzan'))
```

La declaración del **marco disponible completo** antes de la restricción del dominio preserva información de segmentos y estratos con cero adolescentes relevantes. No se justifica tratar los 7.451 adolescentes como observaciones independientes.

Los siguientes diagnósticos se verificaron también mediante reconstrucción independiente de las llaves sobre los CSV originales y ahora se exportan reproduciblemente en `resultados/inferencia/`:

| Diagnóstico | Marco disponible | Comparación principal |
| --- | ---: | ---: |
| Registros de personas/adolescentes | 235.350 | 7.451 |
| Pares estrato–segmento observados | 8.543 | 4.736 |
| Estratos presentes | 356 | 356 |
| Estratos con un único segmento observado | 0 | 2 |
| Pesos `FEX_C` nulos, ausentes o no positivos | 0 | 0 |

El programa verifica ausencia de duplicados por clave de persona, correspondencia de archivos, uniones controladas y positividad de pesos. Para el marco disponible, `FEX_C` varía entre aproximadamente **1,545 y 4.843,504** (mediana **111,059**). Esta amplitud refuerza la necesidad de estimación ponderada; no es por sí sola una validación de la calibración oficial.

**Dos estratos tienen un único segmento con observaciones en el dominio**, aunque ninguno presenta esa condición en el marco completo. La especificación principal usa `survey.adjust.domain.lonely = FALSE`. En la ejecución del 19 de noviembre de 2026, el script `codigo/03_diagnosticos_diseno.R` comparó esta opción con `TRUE` y produjo errores estándar de **0,0674597832** y **0,0674598149**, respectivamente; la diferencia absoluta es **0,0000000317 grados** (`07_sensibilidad_solitarios.csv`). Para esta comprobación concreta, el resultado es numéricamente estable; no se demuestra con ello que la varianza reproduzca todas las etapas del diseño oficial del DANE.

**Grados de libertad:** el contraste reporta `degf(d_total) = 8.543 - 356 = 8.187`. Son grados de libertad del diseño aproximado especificado, no número de adolescentes independientes ni grados de libertad del procedimiento oficial completo. El uso del total del marco en la referencia t es una elección declarada del equipo; no equivale a deducirlos de la muestra de 7.451 personas.

### Qué condiciones no quedan resueltas por el diseño

La ponderación y la linealización no resuelven por sí mismas la percepción subjetiva de `P9090`, errores en la homologación de grados aprobados, cobertura de la encuesta, asociación con variables omitidas, la selección de la hipótesis tras el EDA, ni la falta de información longitudinal. No se estiman efectos causales. La especificación debe interpretarse como una **aproximación operativa verificable**, no como reproducción exacta de la incertidumbre publicada por DANE.

## 2.3. Relevancia de 0,5 grados: decisión de dominio, no norma

La **literatura respalda la importancia de la distorsión edad-grado**, pero no ofrece una regla general de **0,5 grados de brecha entre medias**. El MEN define su indicador institucional de extraedad en términos de una edad **dos años o más** superior a la teórica del grado en estudiantes matriculados; ese indicador binario y la **diferencia media continua derivada en la ECV** tienen **poblaciones, definiciones y escalas distintas**.

Como **referencia de trabajo propuesta por el equipo para una caracterización**, se adopta `δ* = 0,5` grados: equivale, matemáticamente, a 50 grados adicionales de rezago acumulado por cada 100 adolescentes de un grupo frente a otros 100 con el mismo criterio de medida. Es una diferencia agregada de medias, **no significa que cada joven pierda medio año escolar, ni es una recomendación o umbral del MEN**. La justificación se apoya en la escala natural del indicador (grados escolares) y en el interés sustantivo de identificar desigualdades visibles, no en una validación externa del valor numérico.

Fuentes de contexto: el MEN emplea la extraedad para seguimiento de trayectorias y describe medidas de aceleración del aprendizaje para estudiantes en desfase; la OCDE incluye la extraedad por grado como indicador de equidad educativa. **Estas fuentes validan la pertinencia del problema, no el 0,5 elegido por el equipo**.

El criterio se documenta tras la exploración de la Parte 1; por tanto, se usa de modo **exploratorio e interpretativo**, no se lo atribuye a una decisión prespecificada antes de conocer la información. Se considera una propuesta que debería concertarse previamente con el decisor si se realizara una investigación institucional futura.

| Evidencia respecto de `δ*` | Decisión diagnóstica admisible |
| --- | --- |
| Brecha claramente superior a 0,5 con estimación precisa y medida estable | Priorizar `P9090` para una caracterización **más profunda**, no para asignar ayudas |
| Brecha positiva pero menor o compatible con menos de 0,5 | Conservar `P9090` como variable descriptiva, moderar su importancia relativa y estudiar otras dimensiones |
| Intervalo demasiado amplio o dependiente de la definición de `Y` | No graduar prioridades según la brecha; mejorar el indicador y contrastar en nueva evidencia |

**Situación actual:** la estimación principal es 0,6361 [0,5039; 0,7684], pero con `Y_alt` es 0,5144 [0,4002; 0,6285]. No es robusto sostener que la brecha supera 0,5 grados; **sí** persiste una asociación de dirección positiva bajo ambas definiciones.

## 3.1. Ficha de hipótesis

| Elemento | Especificación |
| --- | --- |
| Pregunta | ¿Difiere el rezago medio poblacional entre insuficiencia y suficiencia ajustada percibida? |
| Parámetro | `Δ = E(Y | X = Insuficientes) - E(Y | X = Justo alcanzan)` |
| Estimador | Coeficiente de `insuf` en `survey::svyglm(Y ~ insuf, design = d_principal)`; diferencia de medias ponderadas de dos grupos |
| Hipótesis nula | `H0: Δ = 0` |
| Hipótesis alternativa | `H1: Δ ≠ 0` (bilateral) |
| Regla | `α = 0,05` bilateral; rechazar si `p < 0,05` |
| Unidad y estructura | Adolescente; dependencias dentro de segmentos y hogares; estimación con estratos, segmentos y pesos |
| Origen | Diferencia observada en Parte 1 **en estos mismos datos**: exploratoria, sin validación independiente |

El parámetro `Δ` es una diferencia asociativa descriptiva de población y **no un efecto causal**. El uso bilateral evita elegir una dirección favorable después del EDA.

## 3.2. Método frente a alternativas y supuestos

- **Principal:** `survey::svyglm()` con regresor indicador binario. En este modelo de dos grupos, el coeficiente del indicador reproduce exactamente la diferencia de medias ponderadas. La incertidumbre se aproxima por linealización dentro de estratos/segmentos con el diseño declarado. No se requiere que la distribución individual de `Y` sea normal: `Y` es discreta y asimétrica; lo relevante es la aproximación de muestreo de los estimadores y el número efectivo de unidades primarias del diseño declarado.
- **Alternativa Welch:** permite varianzas distintas en dos grupos, pero supone independencia entre personas y no usa `FEX_C` ni la estructura muestral. No es sustituto de la inferencia a la población cubierta por ECV. Sus diferencias de magnitud e intervalo mezclan cambio de ponderación con cambio de modelo de dependencia; **no** cuantifican aisladamente el efecto de los conglomerados.
- **Alternativa basada en rangos:** respondería a una pregunta distributiva diferente, no sustituye automáticamente el contraste de medias. Una prueba de normalidad individual no puede por sí sola validar o descartar la linealización de diseño.
- **Limitaciones de diagnóstico:** `SEGMENTO` se utiliza como conglomerado último; el diseño completo descrito por DANE tiene municipios como UPM. Se recomienda una verificación especializada de varianzas con especificaciones de etapas adicionales si se pretende producción oficial o decisiones institucionales.

Los controles y la sensibilidad al tratamiento de solitarios se exportan en `05_diagnosticos_diseno.csv`, `06_solitarios_dominio.csv`, `07_sensibilidad_solitarios.csv` y `08_exclusiones_por_X.csv`. Los diagnósticos del diseño y la sensibilidad al tratamiento de segmentos solitarios fueron ejecutados y verificados mediante GitHub Actions. El error estándar de la diferencia principal pasó de 0,0674597832 a 0,0674598149, una variación absoluta de 0,0000000317 grados. Esta comprobación evidencia estabilidad numérica frente al ajuste examinado, sin demostrar equivalencia con el estimador de varianza oficial del DANE.

## 3.3. Errores de decisión y potencia de un estudio futuro

**Error de tipo I:** declarar una diferencia de medias donde `Δ = 0`, y sobredimensionar el lugar de `P9090` en una caracterización sin evidencia poblacional. **Error de tipo II:** no detectar una brecha existente y sustantiva, y relegar del diagnóstico una dimensión que permite identificar desigualdades relevantes.

**Valoración explícita del equipo como criterio de trabajo, no del MEN:** en esta fase diagnóstica, un error tipo II puede ser socialmente más costoso por invisibilizar un patrón de desigualdad. Aun así, no se aumenta `α` oportunistamente, porque la hipótesis surgió de un EDA y no existe una valoración institucional formal de costos. Se conserva `α = 0,05`, bilateral, como equilibrio transparente de control de falsos positivos; para un estudio **futuro**, la preocupación por el error tipo II se traduce en planificar **potencia ≥ 90 %** cuando sea factible. Estos costos son **juicios normativos del equipo**, no hechos inferidos de la ECV ni decisiones avaladas por el MEN.

**Plan de potencia prospectiva (no potencia retrospectiva):** fijar hipotéticamente `δ* = 0,5`, `α = 0,05`, muestras iguales y una desviación estándar conjunta de **1,7261 grados** obtenida de la ECV 2025 únicamente como **dato piloto para planear**, no como una varianza poblacional confirmada. Se exploran efectos de diseño **supuestos** `DEFF = 1; 2; 3` (no estimados ni publicados por el DANE para nuestro estimador). Bajo aproximación normal bilateral:

`EE_futuro ≈ σ_piloto × sqrt(2 × DEFF / n_por_grupo)`

`n_por_grupo ≈ techo[2 × DEFF × σ_piloto² × (z_(1−α/2) + z_potencia)² / δ*²]`

| DEFF supuesto | N por grupo para 80 % | N por grupo para 90 % |
| ---: | ---: | ---: |
| 1,0 | 188 | 251 |
| 2,0 | **375** | **501** |
| 3,0 | 562 | 752 |

Por ejemplo, con **DEFF = 2**, un estudio futuro necesitaría **aproximadamente 501 adolescentes utilizables en cada uno de los dos grupos**, es decir 1.002 en total, para alrededor de 90 % de potencia de detectar `δ* = 0,5` bajo estos supuestos. No son 1.002 domicilios ni 1.002 conglomerados; el plan real debe contemplar distribución territorial, conglomerados, tamaños relativos de los grupos, pérdidas, no respuesta y estimadores multietápicos. La simulación actual es una **aproximación para dimensionar un diseño**, no un cálculo de potencia observada de la ECV 2025.

El código `codigo/04_potencia_futura.R` recalcula σ piloto, escenarios y tamaños futuros desde los datos y genera `03_potencia_futura.csv` y `04_escenarios_potencia.csv`.

## 4. Método de incertidumbre

Para el contraste principal se usa **linealización**, no bootstrap. Por ello **no existen** réplicas `B` ni semilla de remuestreo que reportar para este análisis. Se presentan el error estándar, intervalo basado en `t_(8187; 0,975)` y valor p bilateral bajo el diseño especificado. Un bootstrap ignorando segmentos no sería apropiado.

## Profundización familiar: especificación y alcance

La pregunta complementaria es si la brecha de rezago asociada con insuficiencia percibida de ingresos varía por ocupación del jefe (Z1) o cantidad de menores (Z2). Para cada resultado `Y` y `Y_alt`, se ajustan por separado los modelos `survey::svyglm(Y ~ insuf * Z1)` y `survey::svyglm(Y ~ insuf * Z2)` sobre el dominio familiar, con estratos, segmentos y `FEX_C` de la aproximación de diseño. El coeficiente `insuf:Zk` mide la diferencia entre brechas económicas (grupo segundo menos grupo primero). Las brechas de cada subgrupo se construyen mediante contrastes lineales y la matriz de covarianza del modelo.

También se ajustan especificaciones **aditivas** `Y ~ insuf + Z2` y `Y ~ insuf + Z1 + Z2` (y sus equivalentes para `Y_alt`). La especificación aditiva presupone una brecha económica común entre niveles de las covariables, por lo que sus coeficientes deben distinguirse de los contrastes de interacción. Los coeficientes son asociaciones condicionadas y no tienen interpretación causal.

Las dos interacciones Z1/Z2 constituyen una familia de comparaciones exploratorias **dentro de cada definición del resultado**. El script aplica el procedimiento de Holm a esos dos valores p; no se interpreta como corrección universal de todas las comparaciones de la investigación ni como validación independiente, ya que el planteamiento surge de la exploración de los mismos microdatos.

**Referencia t documentada:** el script original `05_heterogeneidad_familiar.R` utiliza los grados de libertad del marco completo (`8.187`); el script ampliado `06_profundizacion_y_figuras.R` utiliza los grados de libertad del dominio familiar (`4.380`). Las estimaciones puntuales Z2 coinciden, pero los intervalos y valores p presentan pequeñas diferencias por esa referencia. En el informe deben identificarse los resultados con su procedimiento y evitar combinar valores de ambas especificaciones como si usaran exactamente los mismos grados de libertad.

Las interacciones no resultaron estadísticamente distinguibles de cero al 5 %; ello no demuestra homogeneidad exacta. En cambio, la asociación aditiva de Z2 con el **nivel medio** de Y fue positiva bajo los supuestos del modelo (0,2221 grados; IC del 95 % [0,0805; 0,3636]). Este hallazgo no prueba una modificación de la brecha económica por Z2, ni causalidad, ni capacidad de focalización individual.

**Archivos:** `codigo/05_heterogeneidad_familiar.R` (Z2 principal) y `codigo/06_profundizacion_y_figuras.R` (Z1/Z2, sensibilidades, modelos aditivos y figuras). Ejecución integrada: `run/analisis_completo.R`; verificaciones: `run/verificar_resultados.R`.

## Fuentes verificables

1. **DANE (2026), ECV 2025**, metadatos y diseño muestral: https://microdatos.dane.gov.co/index.php/catalog/905
2. **DANE**, diccionario de variables del diseño: https://microdatos.dane.gov.co/index.php/catalog/905/data-dictionary/F30
3. **Ministerio de Educación Nacional**. (s. f.). F5. Tasa de Extraedad. Sistema de Información Nacional de Educación Básica y Media (SINEB). Fuente de datos: SIMAT: http://bi.mineducacion.gov.co:8380/eportal/web/sineb/f5.-extraedad
4. **MEN**, modelo Aceleración del Aprendizaje (contexto, no umbral 0,5): [https://www.mineducacion.gov.co/1780/w3-article-340092.html](https://contenidos.mineducacion.gov.co/ntg/men/archivos/Referentes_Calidad/Modelos_Flexibles/Aceleracion_del_Aprendizaje/Guia_del_docente/Manual%20Operativo.pdf)
5. **OCDE (2024)**, *Education at a Glance*, equidad y estudiantes en extraedad: https://www.oecd.org/en/publications/education-at-a-glance-2024_c00cad36-en/full-report/equity-in-the-education-sustainable-development-goal_9d94cd1e.html
6. **Lumley (2004)**, *Analysis of Complex Survey Samples*, *Journal of Statistical Software*, 9(8), 1–19: https://doi.org/10.18637/jss.v009.i08
7. **R `survey`**, `svydesign`: https://r-survey.r-forge.r-project.org/pkgdown/docs/reference/svydesign.html
8. **R `survey`**, `degf`, subconjuntos y estimación: https://r-survey.r-forge.r-project.org/pkgdown/docs/reference/surveysummary.html

Los datos son del DANE y las decisiones, operacionalizaciones, códigos y conclusiones aquí expuestas son responsabilidad del equipo. La presencia del MEN como decisor de referencia no supone aval ni aprobación de su parte.
