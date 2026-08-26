descargar_serie <- function(series_id, from = "2020-01-01") {
  get_series(series_id, from = from)
}
tool_serie <- tool(
  descargar_serie,
  description = "Descarga una serie mensual del Banco Central de Chile.",
  arguments = list(
    series_id = type_string(
      "Identificador exacto de la serie, p. ej. F049.DES.TAS.INE9.10.M"
    ),
    from = type_string(
      "Fecha de inicio en formato AAAA-MM-DD",
      required = FALSE
    )
  )
)
chat_con_args <- chat_openai(echo = TRUE)
chat_con_args$register_tool(tool_serie)
chat_con_args$chat(
  "Descarga la serie F049.DES.TAS.INE9.10.M desde 2015 y cuéntame qué ves."
)
