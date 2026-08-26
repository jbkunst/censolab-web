resolver_serie <- tool(
  resolve_series,
  name = "resolve_series",
  description = "Busca candidatos en el catálogo de series del Banco Central.",
  arguments = list(
    query = type_string("Una a tres palabras significativas"),
    frequency = type_string(
      paste(
        "Frecuencia del catálogo. Valores válidos:",
        "DAILY, MONTHLY, QUARTERLY o ANNUAL"
      ),
      required = FALSE
    ),
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

chat_tools <- chat_openai(echo = TRUE)
chat_tools$register_tool(resolver_serie)
chat_tools$register_tool(describir_serie)
chat_tools$register_tool(tool_serie)

# Exactamente la misma consulta del paso anterior. Ahora el chat puede buscar
# el identificador, inspeccionarlo si lo necesita y descargar los datos.
chat_tools$chat(pregunta_pib)
