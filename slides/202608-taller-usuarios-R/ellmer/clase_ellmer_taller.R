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

hora_chile <- function() {
  format(Sys.time(), tz = "America/Santiago", usetz = TRUE)
}

hora_chile <- tool(
  hora_chile,
  description = "Devuelve la fecha y hora actuales en Chile."
)

chat$register_tool(hora_chile)

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
  "La audiencia necesita comprender la evolución de la desocupación en Chile ",
  "sin requerir conocimientos previos de economía laboral."
)

instruccion_insights <- glue(
  "Entrega exactamente {numero_insights} insights breves y una propuesta de ",
  "interpretación en una sola frase. Nada más."
)

prompt_analisis <- interpolate_file(
  "slides/202608-taller-usuarios-R/ellmer/prompt_desocupacion.md",
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

# PASO 0: hacemos a mano el recorrido buscar -> validar -> descargar.
desocupacion <- resolve_series(
  "desocupacion nacional",
  frequency = "MONTHLY"
)

serie_desocupacion <- "F049.DES.TAS.INE9.10.M"
serie_desocupacion |> describe_series()

datos_desocupacion <- get_series(
  serie_desocupacion,
  from = "2020-01-01"
)

pib <- resolve_series(
  "pib volumen",
  frequency = "QUARTERLY"
)

serie_pib <- "F032.PIB.FLU.R.CLP.EP18.Z.Z.0.T"
serie_pib |> describe_series()

datos_pib <- get_series(
  serie_pib,
  from = "2020-01-01"
)

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
descargar_serie <- function(series_id) {
  get_series(series_id)
}

tool_serie <- tool(
  descargar_serie,
  description = "Descarga una serie del Banco Central de Chile.",
  arguments = list(
    series_id = type_string(
      "Identificador exacto de la serie, p. ej. F049.DES.TAS.INE9.10.M"
    )
  )
)

chat_con_args <- chat_openai(echo = TRUE)
chat_con_args$register_tool(tool_serie)

# Ahora el modelo elige los argumentos a partir de la petición
chat_con_args$chat(
  paste(
    "Descarga el PIB en volumen",
    "F032.PIB.FLU.R.CLP.EP18.Z.Z.0.T desde 2020 y cuéntame qué ves."
  )
)

# PASO 3: ¿y si no conocemos el identificador exacto del PIB?
# El chat solo tiene la tool de descarga: NO puede buscar en el catálogo.
chat_sin_busqueda <- chat_openai(echo = TRUE)
chat_sin_busqueda$register_tool(tool_serie)

chat_sin_busqueda$chat(
  "Quiero analizar el PIB trimestral en volumen desde 2020."
)

# PASO 4: agregar la tool de búsqueda + una instrucción de comportamiento.
# Ahora la aclaración viene FUNDADA: opciones reales del catálogo.
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

prompt_tools <- glue(
  "Eres un asistente para consultar series del Banco Central de Chile. ",
  "Busca candidatos con resolve_series y usa la frecuencia del catálogo. ",
  "Nunca inventes identificadores. Antes de descargar, valida el ",
  "identificador con describe_series."
)

chat_tools <- chat_openai(
  system_prompt = prompt_tools,
  echo = TRUE
)
chat_tools$register_tool(resolver_serie)
chat_tools$register_tool(describir_serie)
chat_tools$register_tool(tool_serie)

# Provocamos un error real y reproducible. bcchr rechaza "TRIMESTRAL",
# el error vuelve al historial y el modelo corrige a "QUARTERLY".
# Eso es el TOOL LOOP:
#   1. el modelo responde con una solicitud de tool (no con texto);
#   2. ellmer ejecuta la función de R por nosotros;
#   3. el resultado -o el ERROR- se agrega como un turno más al historial
#      del MISMO objeto R6 (aquí se conecta con el bloque 1: el estado);
#   4. ellmer reenvía la conversación y el modelo decide el siguiente paso.
# El ciclo se repite hasta que el modelo responde con texto.
# Documentación: vignette("tool-calling", package = "ellmer") y la
# referencia de Chat: https://ellmer.tidyverse.org/reference/Chat.html

chat_tools$chat(
  glue(
    "Busca el PIB en volumen desde 2020. ",
    "En el primer intento usa frequency = 'TRIMESTRAL'."
  )
)

# Cierre conceptual: prompts = conducta; tools = capacidades. Al coordinar
# piezas pequeñas, especializadas y verificables pasamos de una conversación
# a un sistema. La composición se esboza en las slides, sin agregar más código.
