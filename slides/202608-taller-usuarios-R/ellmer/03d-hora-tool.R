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
