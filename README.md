# Rezago educativo adolescente y condiciones familiares en Colombia

**Un estudio exploratorio e inferencial con microdatos de la Encuesta Nacional de Calidad de Vida (ECV) 2025.**

[![Evidencia reproducible](https://github.com/hernanchoporras-afk/evd-ecv2025/actions/workflows/analisis-ecv.yml/badge.svg)](https://github.com/hernanchoporras-afk/evd-ecv2025/actions/workflows/analisis-ecv.yml)

## Una pregunta de interés público

La acumulación de rezago en la trayectoria escolar plantea un desafío para comprender las condiciones en las que adolescentes avanzan por el sistema educativo. Reconocer asociaciones entre trayectorias escolares y características de sus hogares puede ayudar a formular diagnósticos más precisos, pero requiere separar los patrones observados de lo que realmente permite inferir una encuesta.

> **Pregunta de negocio:** ¿Qué características económicas y familiares convendría priorizar en una caracterización diagnóstica inicial del rezago educativo de adolescentes de 15 y 16 años, para orientar el trabajo de la Subdirección de Permanencia del Ministerio de Educación Nacional?

Este proyecto investiga esa pregunta mediante datos públicos del **DANE**. El Ministerio es el *decisor de referencia del ejercicio*, no un patrocinador del estudio. **No se atribuye causalidad ni se proponen decisiones automáticas de intervención.**

## Qué investigamos

| Dimensión | Variable | Sentido de la comparación |
| --- | --- | --- |
| Resultado (`Y`) | Rezago en escolaridad alcanzada, medido en grados | Intensidad, no solo asistencia o inasistencia |
| Condición económica (`X`) | Suficiencia percibida de ingresos | Insuficientes, justo alcanzan, superan los gastos mínimos |
| Contexto laboral (`Z1`) | Ocupación del jefe del hogar | Ocupado frente a no ocupado |
| Composición familiar (`Z2`) | Menores de 18 años residentes | Un menor frente a dos o más |

El rezago es un **indicador construido por el equipo** a partir de la edad y la escolaridad reportada; **no es la medida oficial de extraedad del MEN**. La ECV 2025 es transversal: el estudio describe asociaciones, no mecanismos causales ni trayectorias individuales a lo largo del tiempo.

## Evidencia principal reproducida

| Indicador | Valor |
| --- | ---: |
| Adolescentes de 15-16 años identificados | 7.792 |
| Observaciones con rezago comparable | 7.717 |
| Comparación económica principal | 7.451 |
| Rezago medio ponderado, ingresos insuficientes | 1,741 grados |
| Rezago medio ponderado, ingresos que justo alcanzan | 1,104 grados |
| **Brecha estimada** | **0,636 grados** |
| **Intervalo de confianza del 95 %** | **[0,504; 0,768] grados** |

![Medias ponderadas de rezago por suficiencia económica, con intervalos de confianza del 95 %](docs/figuras/02_medias_ponderadas_ic95.png)

**Lectura:** la insuficiencia económica percibida está asociada con un rezago medio mayor bajo la especificación estadística utilizada. La diferencia es detectada estadísticamente, pero su interpretación para decisiones educativas requiere discutir magnitud, cobertura, medición y alternativas plausibles. No justifica, por sí sola, asignar apoyos ni afirmar que los ingresos causen rezago.

La estimación utiliza factores de expansión, estratos y segmentos públicos de la ECV. La varianza se calcula mediante una **aproximación de encuesta compleja**; el informe delimita su alcance y no la presenta como reproducción exacta del estimador oficial del DANE. [Consultar evidencia e incertidumbre](docs/evidencia.md).

## De las preguntas a las decisiones

1. **Explorar:** ¿cómo varía la intensidad del rezago según suficiencia económica y condiciones del hogar?
2. **Inferir:** ¿cuál es la magnitud poblacional estimada de la brecha y qué incertidumbre la acompaña?
3. **Comprobar estabilidad:** ¿cambia la lectura al usar otra referencia de edad y grado?
4. **Profundizar:** ¿qué asociaciones cambian al comparar contextos familiares y qué límites siguen abiertos?

La cuarta pregunta orienta una profundización que se documentará únicamente cuando su técnica y sus resultados estén justificados. No añadimos ACP, segmentación ni modelos predictivos solo por complejidad.

## Explorar el repositorio

```text
.
├── .github/workflows/
│   └── analisis-ecv.yml          # Ejecucion automatica y publicacion de evidencia
├── codigo/
│   ├── parte1/                   # Reconstruccion del analisis exploratorio
│   ├── 00_preparar_datos.R       # Validacion, integracion y diseno muestral
│   ├── 01_inferencia.R           # Estimacion, contraste y sensibilidad
│   └── 02_figuras.R             # Figuras generadas desde los microdatos
├── datos/                        # Seis modulos originales de la ECV 2025
├── docs/
│   ├── metodologia.md            # Variables, muestra, inferencia y supuestos
│   ├── evidencia.md              # Resultados y su interpretacion
│   ├── registro_decisiones.md    # Alternativas, criterios y decisiones
│   └── figuras/                  # Vista de una figura generada por el codigo
└── run/
    ├── analisis_completo.R      # Punto de entrada
    ├── verificar_insumos.R      # Control de entradas
    └── verificar_resultados.R   # Control de salidas
```

**Ruta de lectura sugerida:** [metodología](docs/metodologia.md) → [evidencia](docs/evidencia.md) → [decisiones](docs/registro_decisiones.md) → [ejecución reproducible](run/README.md).

## Reproducir el análisis

**Requisitos:** R y el paquete [`survey`](https://cran.r-project.org/package=survey); los seis CSV de la ECV 2025 deben estar en `datos/`. El programa acepta los nombres de archivo con codificación irregular identificados en algunas descargas de Windows.

Desde la raíz del repositorio:

```bash
Rscript --vanilla run/analisis_completo.R
```

En RStudio:

```r
if (!requireNamespace('survey', quietly = TRUE)) install.packages('survey')
source('run/analisis_completo.R', encoding = 'UTF-8')
```

También puedes ejecutar **Actions → ECV 2025 | Evidencia reproducible → Run workflow**. Cada ejecución válida genera las tablas, figuras, controles y versiones de R en el artefacto **`evidencia-ecv-2025`**. Las salidas locales se guardan en `resultados/` y `figuras/` y no se versionan.

No se requiere semilla aleatoria en el flujo actual, porque los procedimientos publicados no realizan remuestreo estocástico. La última corrida verificada del flujo previo utilizó **R 4.6.2** y **`survey` 4.5**. La automatización registra las versiones efectivas de cada ejecución; la nueva presentación del repositorio debe validarse con su primera corrida en Actions.

## Fuentes, límites y responsabilidad académica

- **Fuente primaria:** [DANE, ECV 2025 y microdatos](https://microdatos.dane.gov.co/index.php/catalog/905).
- **Marco de variables:** [Diccionario ECV 2025](https://microdatos.dane.gov.co/index.php/catalog/905/data-dictionary).
- **Método de recolección:** [Metodología general ECV 2025](https://www.dane.gov.co/files/operaciones/ECV/met-ECV-2025.pdf).
- **Código y decisiones:** elaborados por el equipo investigador; no constituyen publicaciones oficiales del DANE ni del MEN.

El estudio forma parte de **Exploración y Visualización de Datos para lo Socioeconómico (MECA-4603)**. Su alcance actual es el análisis exploratorio, la inferencia estadística, la revisión de sensibilidad y el planteamiento de preguntas de profundización. El diseño de un tablero interactivo corresponde a una etapa posterior y **no es un entregable de esta fase**.

**Equipo:** Hernán Felipe Yepes, Martín Santiago Gonzales y Jaime Alejandro Parra.
