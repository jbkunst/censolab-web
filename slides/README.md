# Presentaciones

Las presentaciones se construyen con Quarto y RevealJS. `0000-template` es la referencia para crear una nueva presentación dentro de este repositorio.

## Recursos compartidos

Los estilos y scripts comunes viven en `assets/slides/`:

- `styles/theme.scss`: variables del tema RevealJS.
- `styles/slides.css`: composición general, secciones, tarjetas y barra de progreso.
- `styles/code.css`: bloques y anotaciones de código.
- `cover.js`: mapa animado de la portada.
- `section-sync.js`: sincroniza el logo y el fondo con la diapositiva activa.
- `cover.html`: carga los scripts necesarios después del cuerpo de la presentación.

Las presentaciones deben referenciar estos archivos desde su YAML:

```yaml
include-after-body: ../../assets/slides/cover.html
format:
  revealjs:
    theme: [brand, ../../assets/slides/styles/theme.scss]
    css:
      - ../../assets/slides/styles/slides.css
      - ../../assets/slides/styles/code.css
```

Así, los cambios visuales comunes se realizan una sola vez.

## Convenciones disponibles

- `.section-slide`: portada de sección.
- `.has-image` y `--section-image`: imagen de fondo de una sección. La URL visual debe ser absoluta desde el sitio, por ejemplo `url('/assets/slides/regions/01.jpg')`.
- `.section-subtitle`: bajada de una portada de sección.
- `.center`: centrado vertical opcional.
- `.cards` y `--cards`: tarjetas y número de columnas.
- `data-flow`: conecta las tarjetas con flechas.
- `data-center`: centra verticalmente el contenido de cada tarjeta.
- `aria-current="true"`: destaca una tarjeta.
- `.incremental`: aparición progresiva administrada por Quarto.
- `.fragment`: aparición progresiva administrada por RevealJS.
- `.code-full`, `.code-small` y `.code-pair`: disposiciones para código.

## Recursos de cada presentación

Las imágenes propias deben declararse en `resources` dentro del YAML. Los ejemplos, aplicaciones y murales específicos permanecen en la carpeta de su presentación.

La extensión `codefrag` se conserva localmente por ahora para que cada presentación siga siendo autocontenida. La función `code_block()` también permanece en cada QMD porque recibe rutas relativas al archivo que la utiliza.

## Nueva presentación

1. Copiar `slides/0000-template/` con un nombre descriptivo.
2. Actualizar el encabezado YAML y las imágenes declaradas en `resources`.
3. Mantener las referencias a los estilos y scripts compartidos.
4. Agregar solamente recursos y estilos locales que sean exclusivos de esa presentación.
