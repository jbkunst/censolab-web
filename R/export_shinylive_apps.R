repo_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
app_dir <- file.path(
  repo_root,
  "slides", "202608-taller-usuarios-R", "apps", "app-01"
)
site_dir <- file.path(repo_root, "_site")
output_dir <- file.path(
  site_dir,
  "slides", "202608-taller-usuarios-R", "apps", "app-01"
)

if (!file.exists(file.path(app_dir, "app.R"))) {
  stop("No se encontró la App 01 del taller.")
}

if (!dir.exists(site_dir)) {
  stop("Renderiza el sitio con Quarto antes de exportar las apps.")
}

if (dir.exists(output_dir)) {
  unlink(output_dir, recursive = TRUE, force = TRUE)
}

shinylive::export(
  appdir = app_dir,
  destdir = output_dir,
  quiet = FALSE
)

message("App 01 exportada en: ", output_dir)
