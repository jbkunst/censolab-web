# En el archivo .Renviron (usethis::edit_r_environ(scope = "project")):
# OPENAI_API_KEY=tu_clave
# BCCH_TOKEN=tu_token
# Reiniciar R después de guardar: R lee .Renviron solo al inicio de la sesión

"OPENAI_API_KEY" |>
  Sys.getenv() |>
  nzchar()

"BCCH_TOKEN" |>
  Sys.getenv() |>
  nzchar()
