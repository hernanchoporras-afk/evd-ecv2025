# De la evidencia a la decisión diagnóstica

El objetivo no es clasificar beneficiarios ni proponer una intervención definitiva, sino **precisar qué dimensiones conviene conservar y estudiar en la caracterización inicial del rezago educativo**.

## Pregunta 1. ¿Existe una diferencia poblacional de rezago según suficiencia percibida de ingresos?

| Evidencia | Estimación obtenida en R |
| --- | ---: |
| Media ponderada, ingresos insuficientes | 1,7405 grados |
| Media ponderada, ingresos que justo alcanzan | 1,1044 grados |
| Diferencia estimada | **0,6361 grados** |
| Error estándar | 0,06746 grados |
| Intervalo de confianza del 95 % | **[0,5039; 0,7684]** grados |
| Valor p bilateral | 5,25 × 10⁻²¹ |

**Hallazgo:** los datos son compatibles, bajo la especificación de inferencia adoptada, con una asociación positiva entre insuficiencia económica percibida y mayor rezago medio. El rechazo de la hipótesis de igualdad de medias no identifica una causa del rezago.

![Medias ponderadas de rezago e intervalos de confianza del 95 %](figuras/02_medias_ponderadas_ic95.png)

**Implicación provisional:** la suficiencia percibida de ingresos merece conservarse como dimensión descriptiva prioritaria del diagnóstico. Esto **no** fundamenta por sí solo reglas de focalización de beneficiarios.

## Pregunta 2. ¿Cuánto depende la conclusión de cómo se mide el rezago?

| Definición del indicador | Diferencia ponderada | IC del 95 % |
| --- | ---: | --- |
| Referencia `edad - 6` | 0,6361 | [0,5039; 0,7684] |
| Referencia `edad - 7` | 0,5144 | [0,4002; 0,6285] |

**Hallazgo:** ambas especificaciones conservan el sentido de la asociación, pero su magnitud cambia. Esto exige moderar cualquier afirmación basada en un umbral sustantivo de magnitud.

## Siguiente pregunta de investigación

¿La asociación económica tiene magnitudes distintas según la ocupación del jefe y el número de menores residentes, o la heterogeneidad aparente corresponde a variación muestral y composición familiar?

Su evaluación requiere contrastes directos y un análisis de sensibilidad, sin convertir asociaciones condicionadas en efectos causales. Las decisiones complementarias se incorporarán cuando estén sustentadas y reproducidas, en vez de presentarlas como resultados ya finalizados.
