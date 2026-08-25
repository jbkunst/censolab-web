# Mismo chat, mismas tools; solo cambia el system prompt.
prompt_resumen <- glue(
  "Eres un asistente para consultar series del Banco Central de Chile. ",
  "Cuando descargues una serie, resúmela en exactamente dos insights ",
  "breves, con cifras de la propia serie. Nada más."
)

chat_resumen <- chat_openai(
  system_prompt = prompt_resumen,
  echo = TRUE
)
chat_resumen$register_tool(tool_serie)

chat_resumen$chat("Descarga F049.DES.TAS.INE9.10.M desde 2020.")
