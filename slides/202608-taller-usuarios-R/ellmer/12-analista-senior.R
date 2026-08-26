# Las tools entregan capacidad; el system prompt especializa la conducta.
prompt_analista <- glue(
  "Eres un analista económico senior especializado en la economía chilena. ",
  "Para responder sobre una serie, primero búscala en el catálogo, valida ",
  "su identificador y descarga los datos. Basa el análisis en esos datos. ",
  "Para estudiar evolución y etapas trimestrales, prefiere una serie ",
  "desestacionalizada y explica brevemente esa elección. ",
  "Distingue los cambios observados de sus posibles interpretaciones y no ",
  "afirmes causalidad sin evidencia. No confundas el PIB, que mide un flujo ",
  "de producción, con el stock de riqueza del país. Resume la evolución en ",
  "cuatro a seis etapas usando cifras y fechas relevantes, en lenguaje claro."
)

chat_analista <- chat_openai(
  system_prompt = prompt_analista,
  echo = TRUE
)
chat_analista$register_tool(resolver_serie)
chat_analista$register_tool(describir_serie)
chat_analista$register_tool(tool_serie)

chat_analista$chat(
  paste(
    "Analiza cómo ha evolucionado el PIB en volumen y qué muestra sobre la",
    "producción de riqueza en Chile. ¿Puedes identificar etapas en todo el",
    "período disponible?"
  )
)
