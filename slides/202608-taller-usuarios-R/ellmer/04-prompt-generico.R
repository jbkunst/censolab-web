pregunta_desocupacion <- glue(
  "Analiza la evolución de la tasa de desocupación nacional durante el año 2020 ",
  "Incluye cifras y una descripción."
)

bot_generico <- chat_openai()

bot_generico$chat(pregunta_desocupacion)
