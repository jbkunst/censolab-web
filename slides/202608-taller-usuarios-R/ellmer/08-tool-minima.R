desocupacion_desde_2020 <- function() {
  get_series("F049.DES.TAS.INE9.10.M", from = "2020-01-01")
}

tool_minima <- tool(
  desocupacion_desde_2020,
  description = "Descarga la tasa de desocupación nacional mensual desde 2020."
)

chat_minimo <- chat_openai(echo = TRUE)
chat_minimo$register_tool(tool_minima)

chat_minimo$chat("¿Cómo ha evolucionado la desocupación en Chile desde 2020?")
