# Registro de decisiones analíticas

Este registro documenta cambios y criterios **del estudio**, sin dividirlo en tareas de integrantes. Separa decisiones implementadas de las que requieren nuevas evidencias o una discusión colectiva.

| Momento | Decisión adoptada | Alternativas consideradas | Evidencia / motivo | Consecuencia y límite |
| --- | --- | --- | --- | --- |
| Pregunta y población | Adolescentes de 15 y 16 años, ECV 2025 | Toda la población escolar | 7.792 identificados y 7.717 con rezago comparable | No generalizar automáticamente a otras edades, periodos o población fuera del marco |
| Operacionalización | `Y = max(0, edad-6-grados_aprobados)` | Asistencia escolar binaria o referencia edad−7 | Se requiere intensidad del rezago, no solo asistencia | Indicador derivado; sensibilidad obligatoria y no se confunde con extraedad oficial |
| Exclusiones | Conservar 7.717 con `Y` calculable | Asignar arbitrariamente Y=0 a 75 registros | 75 no comparables (26, 47, 2 por categorías de X) | Selección potencialmente no aleatoria; explicitar sus límites |
| Grupos económicos | Tres categorías para caracterizar; contraste principal de dos grupos | Colapsar las tres en un binario | 3.524 insuficientes, 3.927 justo alcanzan, 266 superan | n principal=7.451; tercera categoría no integra la prueba |
| Diseño de encuesta | `svydesign()` sobre marco y subconjunto del dominio | Welch sin pesos | 8.543 segmentos y 356 estratos en marco; 4.736 en dominio; pesos positivos | Variancia por diseño aproximado; NO reconstruye oficialmente todas las etapas DANE |
| Estratos con solo una USM de dominio | Registrar 2 y comparar opción de corrección | Ignorarlos o tratar el dominio como muestra nueva | Verificación en CSV; nuevos diagnósticos R `06` y `07` | Hasta ejecutar y revisar EE alternativo, no declarar robustez al ajuste |
| Contraste | `H0: Δ=0`, bilateral, `α=0,05` | Alternativa unilateral favorable a la exploración | Hipótesis motivada por la Parte 1 con los mismos datos | Evidencia exploratoria, no confirmatoria independiente |
| Resultado | Brecha 0,6361; IC [0,5039; 0,7684] | Presentar solo p o Welch | Magnitud e incertidumbre del contraste de diseño | Conservar dimensión económica, no atribuir causa ni seleccionar beneficiarios |
| Importancia práctica | Proponer `δ*=0,5` como referencia diagnóstica agregada del equipo | Presentar 0,5 como norma del MEN | Escala en grados y equivalencia de 50 grados acumulados por 100 adolescentes | No validado externamente; adopción institucional necesitaría concertación previa |
| Sensibilidad | Reportar edad−6 y edad−7 | Ocultar resultados menos favorables | Δ disminuye de 0,6361 a 0,5144 | No declarar brecha superior a 0,5 de forma robusta |
| Errores estadísticos | Mantener α=0,05 y vigilar especialmente falsos negativos en la fase diagnóstica | Cambiar α después de conocer p | Costos sociales discutidos como juicio analítico, no criterio institucional | Requiere discusión prospectiva y potencia planificada, no post hoc |
| Potencia | Dimensionar estudio futuro con σ piloto y DEFF hipotéticos | Reportar potencia «observada» cercana al 100 % | Escenario DEFF=2; n≈375/501 por grupo para 80/90 % | Cifras hipotéticas; necesitan diseño real, proporciones de grupos y ajuste por no respuesta |
| Visualizaciones | Integrar figuras 1, 2 y 3 en evidencia | Incluir solo imagen de medias | Distribución, incertidumbre y contraste de procedimientos | Las figuras no sustituyen interpretación ni prueba de la diferencia |

## Pendientes de integración de la Parte 2 completa

1. **Retroalimentación real de la Parte 1:** incorporar la tabla del punto 1 usando exclusivamente las observaciones efectivamente recibidas; no inventar comentarios del profesor.
2. **Diagnóstico R recién añadido:** ejecutar `run/analisis_completo.R`, revisar `07_sensibilidad_solitarios.csv` y verificar que las nuevas salidas aparezcan en el artifact de Actions.
3. **Técnica complementaria, punto 6:** el equipo debe decidir si tiene una necesidad justificada de segmentación/ACP u otra, o argumentar por qué no hace falta, y registrarlo con alternativas y evidencia.
4. **Heterogeneidad por `Z1` y `Z2`:** no inferir diferencias entre brechas a partir de p-valores por subgrupo; usar contrastes directos si se incorporan al proyecto.
5. **Síntesis, límites y siguiente dato, puntos 8–10:** integrar el análisis de todos los integrantes y verificar que no se contradigan población, medidas o inferencias.

## Criterio de lectura

- **Observado:** patrones descriptivos y exclusiones de la muestra ECV.
- **Inferido bajo supuestos:** medias y contrastes ponderados con estratos y segmentos declarados.
- **Pendiente:** sensibilidad a opciones de unidades solitarias, profundización familiar y validación externa.
- **No demostrado:** causalidad, impacto de políticas y un umbral institucional de 0,5 grados.

**Secuencia:** pregunta → evidencia → interpretación → decisión diagnóstica → nueva pregunta.
