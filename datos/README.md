# Microdatos de origen

**Fuente:** Departamento Administrativo Nacional de Estadística (DANE), Encuesta Nacional de Calidad de Vida (ECV) 2025.

- Catálogo oficial: https://microdatos.dane.gov.co/index.php/catalog/905
- Descarga de microdatos: https://microdatos.dane.gov.co/index.php/catalog/905/get-microdata
- Diccionario de variables: https://microdatos.dane.gov.co/index.php/catalog/905/data-dictionary

Coloca en este directorio los seis archivos originales:

1. `Características y composición del hogar.csv`
2. `Educación.csv`
3. `Condiciones de vida del hogar y tenencia de bienes.csv`
4. `Fuerza de trabajo.csv`
5. `Datos de la vivienda.csv`
6. `Variables diseño muestral.csv`

Por la extracción en Windows, algunos nombres pueden presentar caracteres codificados de forma incorrecta. El programa reconoce las variantes ya observadas y normaliza las referencias de los módulos necesarios para la ejecución.

El código utiliza `read.csv2()`, dado que los CSV están separados por punto y coma y pueden tener coma decimal.

**Procedencia y limitaciones:** los archivos de origen pertenecen al DANE; las variables de rezago, comparaciones, figuras e interpretaciones de este repositorio son elaboraciones académicas del equipo y **no son resultados oficiales del DANE ni del MEN**.
