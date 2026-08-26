desocupacion_full <- function() {
  get_series("F049.DES.TAS.INE9.10.M")
}

tool_minima <- tool(
  desocupacion_full,
  description = "Descarga la tasa de desocupación nacional sin ajuste estacional"
)

chat_minimo <- chat_openai(echo = TRUE)
chat_minimo$register_tool(tool_minima)

chat_minimo$chat(
  glue(
    "Consulta la tasa de desocupación de Chile.",
    "Luego explica cómo ha evolucionado desde 2020 usando los datos."
  )
)
