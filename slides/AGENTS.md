# Reglas para presentaciones

- Consultar `slides/README.md` antes de modificar o crear una presentación.
- Reutilizar los estilos y scripts de `assets/slides/`; no duplicarlos dentro de cada presentación.
- Mantener en la carpeta de cada presentación únicamente su contenido y sus recursos específicos.
- Actualizar `slides/0000-template/` cuando se agregue una convención reutilizable.
- Declarar en `resources` las imágenes y archivos propios que Quarto deba publicar.
- Verificar las rutas desde el QMD y ejecutar `git diff --check` antes de entregar cambios.
- Usar Conventional Commits, con mensajes breves y específicos, por ejemplo:
  - `feat(slides): agrega un componente reutilizable`
  - `fix(slides): corrige el fondo de las secciones`
  - `docs(template): documenta una convención`
  - `style(workshop): ajusta la composición visual`
- Separar en commits distintos los cambios de infraestructura compartida y los cambios de contenido cuando sean independientes.
