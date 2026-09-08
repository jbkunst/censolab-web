# Flujo de CensoBot

[Abrir el diagrama interactivo](https://censolab.cl/assets/diagrams/censobot/flujo.html).

El diagrama resume las ocho tools de CensoLab. Las flechas representan recorridos coordinados por el bot, no llamadas directas entre funciones ni una secuencia obligatoria. El bot reutiliza territorios, variables y resultados suficientes que ya estén en la conversación.

| Solicitud | Recorrido después de resolver lo necesario |
| --- | --- |
| Gráfico estadístico | `get_query` → datos dentro de una configuración YAML → `show_chart` |
| Tabla o listado | `get_query` → datos JSON → `show_table` |
| Respuesta directa | `get_query` → respuesta basada en el resultado |
| Indicador territorial o valor de una unidad | `show_map` ejecuta su propia consulta y actualiza el mapa |
| Centrar el mapa | `navigate_to` con un `geo_id` confirmado |
| Informe territorial | `show_report` con un `geo_id` confirmado; Chile usa `pais:CL` |

`resolve_territory` obtiene códigos y filtros. `search_metadata` descubre variables, universos y categorías cuando faltan. `get_query` devuelve un resultado de hasta 100 filas y no abre una vista. Los gráficos y tablas reciben los datos del bot; no ejecutan SQL. Cambiar su presentación puede reutilizar el resultado disponible.

## Archivos y publicación

- `flujo.workflow.json`: fuente editable de Archify, esquema workflow v2.
- `flujo.html`: visor autónomo generado, con zoom, foco y exportación.
- `flujo.svg`: exportación estática desde el visor.
- `ARCHIFY-LICENSE.txt`: licencia MIT del visor distribuido.

El recurso se enlaza desde `acerca-de/index.qmd`. La regla `assets/**` de `_quarto.yml` lo copia a `_site`; el workflow existente publica el sitio al actualizar `main`. No requiere acceso al repositorio privado de la aplicación para verlo. El contenido del diagrama está en español; los controles del visor conservan el inglés de Archify.

## Fuente y reproducción

Revisado el 8 de septiembre de 2026 contra `jbkunst/censolab`, rama `dev`, commit `6c510875f501c4a557082c653a0f44bc1560b2e4`: README, coordinación de tools, contratos de consulta y salida, e implementación de `get_query` y `show_chart`. Describe esa revisión de desarrollo; no verifica qué versión de la aplicación está desplegada.

Generado con [Archify](https://github.com/tt-a1i/archify) en el commit `2ead014aa8ec91f104cd052f1a6ca82de5e26c31`. Desde un checkout de Archify y con las rutas ajustadas:

```sh
node archify/bin/archify.mjs validate workflow flujo.workflow.json --quality showcase --json
node archify/bin/archify.mjs deliver workflow flujo.workflow.json flujo.html --quality showcase --json
node archify/bin/archify.mjs visual-check flujo.html --json
```

Editar la fuente y regenerar; no modificar el HTML generado. Para actualizar el SVG, abrir el HTML y usar Export → SVG.

## Validación de esta versión

Validación showcase: 9 de 9 controles, cero errores y cero advertencias. Comprobación en navegador: 1440×900, 1600×1000, 1920×1080 y 2048×1320, sin desbordamiento. Revisión visual de cuatro capturas en claro y oscuro: aprobada. Foco, Escape y exportación SVG comprobados sin errores JavaScript.

- Fuente: SHA-256 `ee845f5dd236aa68b81d623da244ed031889077a99b4ed2d6966894cb5b33066`, 4343 bytes.
- HTML: SHA-256 `9c5e37347fab15d885563aa3a2adbbe1d18f122dc575f4e7efcdcb7289f97402`, 713977 bytes.
