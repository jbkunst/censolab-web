hora_chile <- function() format(Sys.time(), tz = "America/Santiago", usetz = TRUE)

hora_chile <- tool(
  hora_chile,
  description = "Devuelve la fecha y hora actuales en Chile."
)

chat$register_tool(hora_chile)

chat$chat("¿qué hora es?")
