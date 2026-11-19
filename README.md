# ECV 2025 — Rezago educativo: inferencia Persona 1

Proyecto de R reproducible que reconstruye la Parte 1 y desarrolla las secciones **2, 3, 4 y 7** de la Parte 2.

## Estructura requerida

```text
ECV2025/
├── .github/
│   └── workflows/
│       └── analisis-persona1.yml
├── codigo/
│   ├── ejecutar_persona1.R
│   ├── 00_preparar_datos.R
│   ├── 01_inferencia.R
│   ├── 02_figuras.R
│   └── parte1/
│       └── ECV2025_Parte1_UNICO.R
├── datos/
│   ├── Características y composición del hogar.csv
│   ├── Educación.csv
│   ├── Condiciones de vida del hogar y tenencia de bienes.csv
│   ├── Fuerza de trabajo.csv
│   ├── Variables diseño muestral.csv
│   └── Datos de la vivienda.csv
├── .gitignore
└── README.md
```

Los seis CSV oficiales del DANE deben colocarse en `datos/` **en tu equipo**; no están incluidos en este paquete. El script acepta las variantes con codificación incorrecta de algunos nombres y realiza una copia con el nombre esperado.

## Ejecutar desde GitHub Actions

1. Crear un repositorio privado vacío en GitHub, sin README, `.gitignore` ni licencia generados automáticamente.
2. Copiar el contenido de este paquete dentro de la carpeta local del proyecto, manteniendo los seis CSV en `datos/`.
3. Abrir **PowerShell** en la carpeta raíz del proyecto y ejecutar (reemplazar `TU_USUARIO`):

```powershell
git init
git add .
git commit -m "Configurar analisis reproducible ECV 2025"
git branch -M main
git remote add origin git@github.com:TU_USUARIO/evd-ecv2025.git
git push -u origin main
```

4. En GitHub, abrir **Actions**, elegir **ECV 2025 - Inferencia Persona 1**, pulsar **Run workflow**, elegir `main` y confirmar.
5. Al terminar, abrir la ejecución y descargar **resultados-ecv2025-persona1** en la sección **Artifacts**.

El flujo también se ejecuta al hacer `push` a `main` si cambia `codigo/`, `datos/` o la configuración de Actions.

**GitHub no es el intérprete de R:** GitHub Actions prepara una máquina Linux, instala R y `survey`, ejecuta el script y guarda sus resultados.

## Ejecutar localmente

Desde la raíz del proyecto:

```r
if (!requireNamespace('survey', quietly = TRUE)) {
  install.packages('survey')
}
source('codigo/ejecutar_persona1.R', encoding = 'UTF-8')
```

## Notas metodológicas

- La definición de rezago replica la utilizada en la Parte 1 y es una medida derivada del equipo.
- El código usa un diseño `survey` con estratos, segmentos y expansión presentes en los microdatos. Las afirmaciones inferenciales deben revisarse con el profesor y contrastarse con la documentación del DANE.
- El análisis de potencia utiliza **0,5 grados como referencia provisional**, pendiente de justificación sustantiva.
- La reproducción integral de los resultados en GitHub Actions sigue pendiente de la primera ejecución en el repositorio del usuario.
- Los CSV se versionan únicamente porque el flujo necesita reconstruir el análisis desde los datos originales. En proyectos más grandes puede resultar preferible usar almacenamiento externo con descarga reproducible y verificación de integridad.
