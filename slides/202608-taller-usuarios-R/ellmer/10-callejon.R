# ¿Y si no conocemos el identificador?
chat_ambiguo <- chat_openai(echo = TRUE)
chat_ambiguo$register_tool(tool_serie)

# El chat solo tiene la tool de descarga: NO puede buscar en el catálogo.
chat_ambiguo$chat("Quiero datos de los depósitos a plazo en UF.")
