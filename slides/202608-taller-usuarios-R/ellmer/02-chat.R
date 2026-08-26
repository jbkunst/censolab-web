# Conceptos:
# - proveedor: servicio que da acceso a modelos
# - modelo: LLM
# - prompt: texto que enviamos al modelo
# - turno: un prompt o una respuesta
# - conversación: secuencia de turnos
# - tokens: unidad básica de información de un modelo de lenguaje
# - contexto: instrucciones e historial enviados en cada consulta

chat <- chat_openai()

chat |> class()
