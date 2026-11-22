# Registro de decisiones analíticas

Este registro documenta cambios y criterios **del estudio**, sin dividirlo en tareas de integrantes. Separa decisiones implementadas de las que requieren nuevas evidencias o una discusión colectiva.

| Momento | Decisión adoptada | Alternativas consideradas | Evidencia / motivo | Consecuencia y límite |
| --- | --- | --- | --- | --- |
| Pregunta y población | Adolescentes de 15 y 16 años, ECV 2025 | Toda la población escolar | 7.792 identificados y 7.717 con rezago comparable | No generalizar automáticamente a otras edades, periodos o población fuera del marco |
| Operacionalización | `Y = max(0, edad-6-grados_aprobados)` | Asistencia escolar binaria o referencia edad−7 | Se requiere intensidad del rezago, no solo asistencia | Indicador derivado; sensibilidad obligatoria y no se confunde con extraedad oficial |
| Exclusiones | Conservar 7.717 con `Y` calculable | Asignar arbitrariamente Y=0 a 75 registros | 75 no comparables (26, 47, 2 por categorías de X) | Selección potencialmente no aleatoria; explicitar sus límites |
| Grupos económicos | Tres categorías para caracterizar; contraste principal de dos grupos | Colapsar las tres en un binario | 3.524 insuficientes, 3.927 justo alcanzan, 266 superan | n principal=7.451; tercera categoría no integra la prueba |
| Diseño de encuesta | `svydesign()` sobre marco y subconjunto del dominio | Welch sin pesos | 8.543 segmentos y 356 estratos en marco; 4.736 en dominio; pesos positivos | Variancia por diseño aproximado; NO reconstruye oficialmente todas las etapas DANE |
| Estratos con solo una USM de dominio | Registrar 2 y comparar el ajuste de dominio | Ignorarlos o tratar el dominio como muestra nueva | CSV `06` y `07`: EE principal 0,0674597832; EE alternativo 0,0674598149 | Estabilidad numérica frente a esa opción; no equivale a validar integralmente la varianza oficial |
| Contraste | `H0: Δ=0`, bilateral, `α=0,05` | Alternativa unilateral favorable a la exploración | Hipótesis motivada por la Parte 1 con los mismos datos | Evidencia exploratoria, no confirmatoria independiente |
| Resultado | Brecha 0,6361; IC [0,5039; 0,7684] | Presentar solo p o Welch | Magnitud e incertidumbre del contraste de diseño | Conservar dimensión económica, no atribuir causa ni seleccionar beneficiarios |
| Importancia práctica | Proponer `δ*=0,5` como referencia diagnóstica agregada del equipo | Presentar 0,5 como norma del MEN | Escala en grados y equivalencia de 50 grados acumulados por 100 adolescentes | No validado externamente; adopción institucional necesitaría concertación previa |
| Sensibilidad | Reportar edad−6 y edad−7 | Ocultar resultados menos favorables | Δ disminuye de 0,6361 a 0,5144 | No declarar brecha superior a 0,5 de forma robusta |
| Errores estadísticos | Mantener α=0,05 y vigilar especialmente falsos negativos en la fase diagnóstica | Cambiar α después de conocer p | Costos sociales discutidos como juicio analítico, no criterio institucional | Requiere discusión prospectiva y potencia planificada, no post hoc |
| Potencia | Dimensionar estudio futuro con σ piloto y DEFF hipotéticos | Reportar potencia «observada» cercana al 100 % | Escenario DEFF=2; n≈375/501 por grupo para 80/90 % | Cifras hipotéticas; necesitan diseño real, proporciones de grupos y ajuste por no respuesta |
| Visualizaciones | Integrar figuras 1, 2 y 3 en evidencia | Incluir solo imagen de medias | Distribución, incertidumbre y contraste de procedimientos | Las figuras no sustituyen interpretación ni prueba de la diferencia |
| Técnica complementaria | Contrastar heterogeneidad familiar por interacciones con diseño (Z1 y Z2), con Y e Y_alt | ACP o segmentación sin una necesidad identificada | La pregunta pendiente exige comparar **diferencias entre brechas**, no crear perfiles latentes | Las interacciones son exploratorias y no respaldan todavía prioridades diferenciadas entre subgrupos |
| Comparaciones adicionales | Ajustar dos pruebas de interacción con Holm dentro de cada definición de Y | Tratar cada p exploratorio como confirmatorio | Varias comparaciones motivadas por el mismo EDA | La corrección es limitada a las dos interacciones de cada medida, no a toda la investigación |
| Profundización ajustada | Usar modelo aditivo con insuficiencia percibida, Z1 y Z2 | Interpretar asociaciones simples como efectos causales | Brecha económica ajustada 0,5969; aporte aditivo Z2 +0,2221, IC [0,0805; 0,3636] | Z2 aporta contexto al **nivel de rezago**; no se infiere causalidad ni heterogeneidad confirmada |
| Grados de libertad | Documentar la referencia del marco (8.187) y la del dominio familiar (4.380) | Ocultar que los dos scripts usan referencias t distintas | Salidas verificadas `10_interaccion_Z2.csv` y `11_control_gl.csv` | Las estimaciones puntuales son consistentes; intervalos/p deben atribuirse a su procedimiento |

## Pendientes de integración de la Parte 2 completa

1. **Retroalimentación real de la Parte 1:** incorporar la tabla del punto 1 usando exclusivamente las observaciones efectivamente recibidas; no inventar comentarios del profesor.
2. **Pertinencia de la especificación del diseño:** los controles y la sensibilidad de unidades solitarias **ya se ejecutaron y verificaron**; queda documentar el alcance de la aproximación a las etapas de selección descritas por DANE y evitar presentarla como estimador oficial idéntico.
3. **Técnica complementaria, punto 6: realizada.** Se ejecutaron interacciones Z1/Z2, sensibilidad con Y_alt y modelos aditivos; falta integrar sus hallazgos en el informe de Overleaf, sin presentar ACP o segmentación no aplicados.
4. **Heterogeneidad por Z1 y Z2: contrastada.** Los contrastes directos no aportan evidencia suficiente de diferencias entre brechas; no se concluye igualdad de subgrupos. Se mantienen verificaciones posteriores de estabilidad y validez externa.
5. **Síntesis, límites y siguiente dato, puntos 8–10:** integrar el análisis de todos los integrantes y verificar que no se contradigan población, medidas o inferencias.

## Criterio de lectura

- **Observado:** patrones descriptivos y exclusiones de la muestra ECV.
- **Inferido bajo supuestos:** medias y contrastes ponderados con estratos y segmentos declarados.
- **Comprobado:** sensibilidad numérica al ajuste de unidades solitarias del dominio, además de los escenarios de potencia prospectiva.
- **Pendiente:** validación externa y sustantiva del criterio 0,5, revisión especializada de la varianza y contraste con datos educativos independientes; la profundización familiar ya fue ejecutada.
- **No demostrado:** causalidad, impacto de políticas y un umbral institucional de 0,5 grados.

**Secuencia:** pregunta → evidencia → interpretación → decisión diagnóstica → nueva pregunta.
