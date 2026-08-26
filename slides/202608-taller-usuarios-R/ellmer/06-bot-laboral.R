bot_laboral <- chat_openai(
  system_prompt = prompt_analisis
)

bot_laboral$chat(pregunta_desocupacion)
