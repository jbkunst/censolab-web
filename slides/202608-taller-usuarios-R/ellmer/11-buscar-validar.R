resolver_serie <- tool(
  resolve_series,
  name = "resolve_series",
  description = "Busca candidatos en el catálogo de series del Banco Central.",
  arguments = list(
    query = type_string("Una a tres palabras significativas"),
    frequency = type_string("Frecuencia de la serie", required = FALSE),
    token = type_ignore(),
    verbose = type_ignore()
  )
)

describir_serie <- tool(
  describe_series,
  name = "describe_series",
  description = "Describe y valida un identificador exacto de serie.",
  arguments = list(
    series_id = type_string("Identificador exacto devuelto por resolve_series"),
    token = type_ignore(),
    verbose = type_ignore()
  )
)

prompt_aclaracion <- glue(
  "Eres un asistente para consultar series del Banco Central de Chile. ",
  "Si la petición del usuario es ambigua, busca candidatos con ",
  "resolve_series, muestra las opciones con su nombre y cobertura, y ",
  "PREGUNTA al usuario cuál prefiere. Nunca elijas una serie por tu ",
  "cuenta ni inventes identificadores. Antes de descargar, valida el ",
  "identificador con describe_series."
)

chat_aclarador <- chat_openai(
  system_prompt = prompt_aclaracion,
  echo = TRUE
)
chat_aclarador$register_tool(resolver_serie)
chat_aclarador$register_tool(describir_serie)
chat_aclarador$register_tool(tool_serie)
