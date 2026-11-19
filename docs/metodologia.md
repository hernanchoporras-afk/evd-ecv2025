# Metodología, delimitación y trazabilidad

## Pregunta y objeto de inferencia

Se analiza si existe una diferencia en el **rezago medio en escolaridad alcanzada** entre adolescentes de 15 y 16 años que viven en hogares cuya suficiencia económica percibida es **insuficiente** y aquellos cuyos ingresos **justo alcanzan** para cubrir los gastos mínimos, dentro de la población cubierta por la ECV 2025.

La unidad de análisis es el adolescente. La unidad de remuestreo/agrupación inferencial depende del diseño de la encuesta y no debe confundirse con el número de adolescentes observados.

## Definición operacional de las variables

| Símbolo | Variable | Construcción |
| --- | --- | --- |
| `Y` | Rezago en grados | `max(0, edad - 6 - grados_aprobados)`; **medida derivada del equipo**. |
| `X` | Suficiencia económica percibida | Tres categorías obtenidas de `P9090`. |
| `Z1` | Ocupación del jefe del hogar | Jefe ocupado o no ocupado, a partir de los módulos personales y laborales. |
| `Z2` | Número de menores del hogar | Un menor frente a dos o más menores residentes; incluye al adolescente analizado. |

Para la especificación de sensibilidad se usa `max(0, edad - 7 - grados_aprobados)`. La construcción conserva reglas diferenciadas de escolaridad según asistencia y nivel educativo. No equivale a la extraedad oficial del MEN.

## Cohorte analítica

- Adolescentes de 15 y 16 años identificados: **7.792**.
- Con indicador `Y` comparable: **7.717**.
- Muestra de la comparación principal de dos grupos: **7.451**.
- Registros del marco de diseño cargados: **235.350**.
- Estratos registrados: **356**; segmentos registrados: **8.543**.

Las exclusiones (75 observaciones sin `Y` comparable) y la selección de dos categorías de `X` delimitan la interpretación. No constituyen una selección aleatoria adicional de la población.

## Parámetro, estimación y contraste

Se estima la diferencia poblacional de medias:

$$
\Delta = E(Y\mid X=\text{insuficientes})-E(Y\mid X=\text{justo alcanzan}).
$$

La hipótesis nula es `H0: Δ = 0`; la alternativa, bilateral, es `H1: Δ ≠ 0`. Se reportan estimación puntual, error estándar, intervalo del 95 %, estadístico y valor p. La alternativa metodológica de Welch se presenta como contraste de especificación, **no como sustituto del diseño complejo**.

El procedimiento principal implementa `survey::svydesign()` con `SEGMENTO`, `ESTRATO2020` y `FEX_C`; utiliza `survey::svyglm()` para la diferencia y los grados de libertad del marco declarado en el código. Los resultados de incertidumbre son **una aproximación operativa** basada en estas variables públicas, no una certificación de identidad con el estimador oficial de varianzas del DANE.

## Interpretación, potencia y robustez

El contraste realizado con los mismos datos explorados en la etapa anterior tiene **carácter exploratorio**; un valor p pequeño no constituye validación independiente. Una asociación estadística no prueba que las condiciones económicas sean la causa del rezago.

El umbral de **0,5 grados** utilizado en el archivo de potencia es una **referencia provisional**, pendiente de sustento sustantivo en literatura o criterio institucional. No es un punto de corte oficial del MEN ni una norma para asignar apoyos. Las simulaciones de potencia ilustran un estudio futuro y no deben leerse como validación retrospectiva.

Se presenta como sensibilidad el cambio de referencia edad-grado (`edad - 6` a `edad - 7`), porque afecta la medición y la magnitud de la brecha. No resuelve por sí solo sesgos de medición, selección o la ausencia de información longitudinal.

## Fuentes metodológicas

- DANE, ECV 2025: https://microdatos.dane.gov.co/index.php/catalog/905
- Diccionario de variables de diseño: https://microdatos.dane.gov.co/index.php/catalog/905/data-dictionary/F30
- Metodología general ECV: https://www.dane.gov.co/files/operaciones/ECV/met-ECV-2025.pdf
- Paquete `survey` en R: https://cran.r-project.org/package=survey

Los razonamientos y resultados derivados de la ECV pertenecen al equipo; no se atribuyen al DANE ni al Ministerio de Educación Nacional.
