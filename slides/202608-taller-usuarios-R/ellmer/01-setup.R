# En el archivo .Renviron (usethis::edit_r_environ(scope = "project")):
# OPENAI_API_KEY=tu_clave
# BCCH_TOKEN=tu_token
# Ejecutar el taller desde la raíz del proyecto para cargar este .Renviron


"OPENAI_API_KEY" |>
  Sys.getenv() |>
  nzchar()

"BCCH_TOKEN" |>
  Sys.getenv() |>
  nzchar()
