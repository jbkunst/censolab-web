descargar_serie <- function(series_id) {
  get_series(series_id)
}
tool_serie <- tool(
  descargar_serie,
  description = "Descarga una serie del Banco Central de Chile.",
  arguments = list(
    series_id = type_string(
      "Identificador exacto de la serie, p. ej. F049.DES.TAS.INE9.10.M"
    )
  )
)
chat_con_args <- chat_openai(echo = TRUE)
chat_con_args$register_tool(tool_serie)

pregunta_pib <- glue(
  "Analiza el PIB trimestral en volumen de Chile desde 2020 y describe sus principales etapas."
)

# El chat puede descargar, pero no buscar el identificador correcto.
chat_con_args$chat(pregunta_pib)
