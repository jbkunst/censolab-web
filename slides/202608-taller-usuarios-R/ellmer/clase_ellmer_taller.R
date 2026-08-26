# Taller ellmer: prompts y tool calling
# TODO: Al ir narrando ir dialogando con la experiencia de censo

suppressPackageStartupMessages({
  library(ellmer)
  library(bcchr)
  library(glue)
  library(purrr)
  library(yaml)
})

# 1. Conceptos básicos y setup --------------------------------------------
# En el archivo .Renviron:
# OPENAI_API_KEY=tu_clave
# BCCH_TOKEN=tu_token
# usethis::edit_r_environ(scope = "project")
# Reiniciar R después de guardar: R lee .Renviron solo al inicio de la sesión

"OPENAI_API_KEY" |>
  Sys.getenv() |>
  nzchar()

"BCCH_TOKEN" |>
  Sys.getenv() |>
  nzchar()

# Conceptos:
# - proveedor: servicio que da acceso a modelos;
# - modelo: LLM;
# - prompt: texto que enviamos al modelo;
# - turno: un prompt o una respuesta;
# - conversación: secuencia de turnos;
# - tokens: unidad básica de información de un modelo de lenguaje;
# - contexto: instrucciones e historial enviados en cada consulta.

chat <- chat_openai()

chat_openai |> args()
chat |> class()

# ls(chat) lista 25 métodos y abruma; los que usaremos hoy:
# $chat()            conversar
# $register_tool()   darle una herramienta
# $get_turns()       ver el historial de turnos
# $get_cost()        costo acumulado de ESTE chat
# $chat_structured() devolver datos de R (no lo veremos hoy)

# ¿Por qué chat es un objeto R6 (mutable) y no funcional?
# Porque una conversación tiene ESTADO: el historial de turnos.
# - Cada $chat() agrega turnos al historial y la siguiente consulta
#   se construye sobre esa memoria.
# - El objeto también administra el "tool loop": cuando el modelo pide
#   ejecutar una función, ellmer la corre y agrega el resultado al historial.
# Referencias:
# - Documentación de Chat: https://ellmer.tidyverse.org/reference/Chat.html
#   ("A Chat is a mutable R6 object that takes care of managing the state
#    associated with the chat")
# - Motivación de R6 para objetos con estado: Advanced R, cap. 14
#   https://adv-r.hadley.nz/r6.html
# Consecuencia práctica: el costo en tokens crece con el historial y la
# calidad puede degradarse en conversaciones muy largas -> conviene
# conversaciones cortas y temáticamente acotadas.

chat$chat("¿Qué es la antropología?")

chat$chat("en una frase") # tiene memoria

chat$chat("¿qué hora es?") # no está actualizado

hora_santiago <- function() {
  format(Sys.time(), tz = "America/Santiago", usetz = TRUE)
}

hora_santiago <- tool(
  hora_santiago,
  description = "Devuelve la fecha y hora actuales en Santiago de Chile."
)

chat$register_tool(hora_santiago)

# Esta función parece simple pero le da mucho poder
chat$chat("¿qué hora es?")

chat$chat("cuántos días han pasado desde la fundación de santiago de chile")

# El historial es tangible: cada turno (pregunta, respuesta, llamada a
# tool y su resultado) queda guardado dentro del objeto.
chat$get_turns()

# El costo es POR CHAT: cada turno reenvía todo el historial al proveedor.
chat$get_cost()

# OJO: token_usage() existe, pero es global de la sesión de R (suma todos
# los chats); para costo por conversación usar chat$get_cost().


# 2. Prompt ---------------------------------------------------------------
# Idea central: el prompt determina buena parte de la respuesta.
# Recorrido: prompt genérico -> anatomía de un buen prompt ->
# parametrizar con interpolate_file() y {{}}.

# OJO: la pregunta apunta a la tasa de desocupación nacional a secas, es
# decir la serie NO ajustada estacionalmente (F049.DES.TAS.INE9.10.M), la
# MISMA que descargaremos en el bloque 3. Así las cifras del bot sin datos
# se pueden comparar directamente con las del chat con tool.
pregunta_desocupacion <- glue(
  "Analiza la evolución de la tasa de desocupación nacional durante el año 2020. ",
  "Incluye cifras y una descripción."
)

# PASO 1: prompt genérico, sin rol ni formato.
# Resultado esperado: respuesta larga, sin foco, con cifras no verificables.
bot_generico <- chat_openai()

bot_generico$chat(pregunta_desocupacion)

# PASO 2: anatomía de un buen prompt. Explicitar:
# 1. el rol del asistente;
# 2. la tarea concreta;
# 3. el contexto que necesita;
# 4. el formato y las restricciones de la respuesta.

# PASO 3: el prompt vive en un archivo .md y se parametriza con {{}}.
# interpolate_file() reemplaza las variables {{...}} con valores de R.
# Ventaja: el texto del prompt se edita como documento (con títulos,
# listas) y los parámetros se controlan desde el código.
numero_insights <- 2L

contexto <- glue(
  "Estoy en un taller sobre R en santiago de chile. La audiencia necesita una explicación ",
  "breve y accesible."
)

instruccion_insights <- glue(
  "Entrega exactamente {numero_insights} insights breves y una propuesta de ",
  "interpretación en una sola frase. Nada más."
)

prompt_analisis <- interpolate_file(
  "R/prompt_desocupacion.md",
  contexto = contexto,
  instruccion_insights = instruccion_insights
)

prompt_analisis

bot_laboral <- chat_openai(
  system_prompt = prompt_analisis
)

bot_laboral$chat(pregunta_desocupacion)

# Comparar con PASO 1: misma pregunta, distinto comportamiento.
# Anécdota propia: ensayo y error. Un prompt más estructurado mejora el
# comportamiento, no necesariamente la calidad de la información.
# Detalle potente para comentar: el bot genérico dijo "máximo cercano a
# 13%" y el estructurado "13,1%": cifras plausibles, quizás correctas,
# pero NO VERIFICABLES: no sabemos de dónde salieron.
# Y ahí está el gancho al bloque 3: para mejorar la información,
# hay que darle DATOS REALES al modelo -> tool calling.


# 3. Tool calling ---------------------------------------------------------

# PASO 0: ¿cómo consultamos la API del Banco Central "a mano"?
candidatos <- resolve_series(
  "desocupacion",
  frequency = "MONTHLY"
)

serie <- "F049.DES.TAS.INE9.10.M"

serie |> 
  describe_series()

desempleo <- get_series(
  serie,
  from = "2020-01-01"
)

plot_series(desempleo)

# PASO 1: tool mínima. Solo una función sin argumentos y una descripción.
# El modelo no decide nada: solo puede pedir "la serie de desocupación".

desocupacion_desde_2020 <- function() {
  get_series("F049.DES.TAS.INE9.10.M", from = "2020-01-01")
}

tool_minima <- tool(
  desocupacion_desde_2020,
  description = "Descarga la tasa de desocupación nacional mensual desde 2020."
)

chat_minimo <- chat_openai(echo = TRUE)
chat_minimo$register_tool(tool_minima)

chat_minimo$chat("¿Cómo ha evolucionado la desocupación en Chile desde 2020?")

# Limitación evidente: la serie está "cableada". Si quiero otra serie u
# otro período, la tool no sirve.

# PASO 2: agregar argumentos. type_string() documenta cada argumento para
# que el modelo sepa qué valores poner.
descargar_serie <- function(series_id, from = "2020-01-01") {
  get_series(series_id, from = from)
}

tool_serie <- tool(
  descargar_serie,
  description = "Descarga una serie mensual del Banco Central de Chile.",
  arguments = list(
    series_id = type_string(
      "Identificador exacto de la serie, p. ej. F049.DES.TAS.INE9.10.M"
    ),
    from = type_string(
      "Fecha de inicio en formato AAAA-MM-DD",
      required = FALSE
    )
  )
)

chat_con_args <- chat_openai(echo = TRUE)
chat_con_args$register_tool(tool_serie)

# Ahora el modelo elige los argumentos a partir de la petición
chat_con_args$chat(
  "Descarga la serie F049.DES.TAS.INE9.10.M desde 2015 y cuéntame qué ves."
)

# PASO 3: ¿y si no conozco el identificador? "Quiero imacec", a secas.
# Hay varias series de imacec (original, desestacionalizada, anual...).
# El chat solo tiene la tool de descarga: NO puede buscar en el catálogo.
chat_ambiguo <- chat_openai(echo = TRUE)
chat_ambiguo$register_tool(tool_serie)

# Callejón sin salida: o inventa un identificador (alucinación) o nos
# pide el ID exacto... que es justo lo que no conocemos.
# OJO (verificado en pruebas): con "imacec" el contraste es débil, porque
# el modelo se sabe de memoria los IDs del imacec y pregunta igual.
# Con series menos famosas (p. ej. "depósitos a plazo en UF") sí queda
# en evidencia: no puede buscar y queda atrapado pidiendo el código.
chat_ambiguo$chat("Quiero datos de los depósitos a plazo en UF.")

# PASO 4: agregar la tool de búsqueda + una instrucción de comportamiento.
# Ahora la aclaración viene FUNDADA: opciones reales del catálogo.
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

# Opcional: una tercera tool para VALIDAR el identificador antes de
# descargar (ruta completa: buscar -> validar -> descargar).
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

# Ahora la pregunta trae opciones concretas del catálogo, no una
# pregunta vacía ni una promesa falsa de buscar.
chat_aclarador$chat("Quiero datos de los depósitos a plazo en UF.")

# Detalle para comentar si ocurre en vivo: en las pruebas el modelo
# intentó frequency = "M", bcchr respondió con un error, y el modelo se
# autocorrigió a "MONTHLY". Eso es el TOOL LOOP:
#   1. el modelo responde con una solicitud de tool (no con texto);
#   2. ellmer ejecuta la función de R por nosotros;
#   3. el resultado -o el ERROR- se agrega como un turno más al historial
#      del MISMO objeto R6 (aquí se conecta con el bloque 1: el estado);
#   4. ellmer reenvía la conversación y el modelo decide el siguiente paso.
# El ciclo se repite hasta que el modelo responde con texto.
# Documentación: vignette("tool-calling", package = "ellmer") y la
# referencia de Chat: https://ellmer.tidyverse.org/reference/Chat.html

# El usuario responde en el siguiente turno, con más especificación,
# y la conversación va convergiendo. Así se construye un sistema:
# turno a turno, acotando la ambigüedad.
chat_aclarador$chat(
  "La de saldos, mensual. Descárgala desde 2020."
)

# PASO 5: una línea de prompt ordena la salida.
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

# PASO 6: escalar. Un catálogo de series en YAML + pmap con VARIOS
# argumentos: un chat por serie, cada uno descarga y resume.
catalogo <- read_yaml("R/series_bcch.yml")$series

# safely(): si una serie falla, el reporte no cae; el error queda
# registrado en la sección correspondiente.
resumir_serie <- safely(function(series_id, nombre, unidad, desde) {
  chat <- chat_openai(system_prompt = prompt_resumen, echo = FALSE)
  chat$register_tool(tool_serie)

  resumen <- chat$chat(glue(
    "Descarga {series_id} desde {desde}."
  ))

  glue("## {nombre}\n\nIdentificador: {series_id} ({unidad})\n\n{resumen}\n")
})

# pmap necesita una lista de ARGUMENTOS: transpose() convierte la lista de
# series en una lista de campos (todos los series_id juntos, etc.), y cada
# campo entra como un argumento distinto de resumir_serie().
resultados <- catalogo |>
  transpose() |>
  pmap(resumir_serie)

secciones <- map_chr(resultados, function(r) {
  if (is.null(r$error)) {
    r$result
  } else {
    glue("## Serie no disponible\n\nError: {conditionMessage(r$error)}\n")
  }
})

# PASO 7: un segundo chat, sin tools, actúa como EDITOR.
# Las tools dan datos; los prompts dan roles. Componer chats especializados
# es el salto de "consulta" a "sistema".
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

# Cierre: con un buen prompt (bloque 2) y tools bien descritas (bloque 3)
# se construyen sistemas: chat + tool + pmap + chat editor es un pipeline
# completo, y cada pieza es chica y testeable por separado.
