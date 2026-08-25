# Un segundo chat, sin tools, actúa como EDITOR.
# Las tools dan datos; los prompts dan roles.
prompt_editor <- glue(
  "Eres el editor de un informe económico breve. Recibirás resúmenes de ",
  "series del Banco Central de Chile. Escribe una síntesis ejecutiva de ",
  "tres líneas que conecte los hallazgos entre series, sin agregar ",
  "cifras nuevas ni recomendaciones."
)

chat_editor <- chat_openai(system_prompt = prompt_editor, echo = FALSE)

sintesis <- chat_editor$chat(
  paste(secciones, collapse = "\n")
)

encabezado <- glue(
  "# Resumen de series del Banco Central de Chile\n\n",
  "Generado el {format(Sys.Date())} con ellmer + bcchr.\n"
)

writeLines(
  c(encabezado, "\n## Síntesis ejecutiva\n", sintesis, "\n", secciones),
  "reporte_series.md"
)
