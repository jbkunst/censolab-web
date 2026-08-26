# Un chat nuevo permite observar este tool loop sin heredar el paso anterior.
chat_iteracion <- chat_openai(
  echo = TRUE
)
chat_iteracion$register_tool(resolver_serie)
chat_iteracion$register_tool(describir_serie)
chat_iteracion$register_tool(tool_serie)

# Provocamos un error real: bcchr no acepta "TRIMESTRAL" como frecuencia.
# El error entra al historial y el modelo debe corregir el argumento.
chat_iteracion$chat(
  glue(
    "Busca el PIB en volumen desde 2020. ",
    "En el primer intento usa frequency = 'TRIMESTRAL'."
  )
)
