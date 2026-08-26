catalogo <- read_yaml("ellmer/series_bcch.yml")$series

# safely(): si una serie falla, el reporte no cae; el error queda registrado.
resumir_serie <- safely(function(series_id, nombre, unidad, desde) {
  chat <- chat_openai(system_prompt = prompt_resumen, echo = FALSE)
  chat$register_tool(tool_serie)

  resumen <- chat$chat(glue(
    "Descarga {series_id} desde {desde}."
  ))

  glue("## {nombre}\n\nIdentificador: {series_id} ({unidad})\n\n{resumen}\n")
})

# transpose() convierte la lista de series en una lista de campos;
# cada campo entra como un argumento distinto de resumir_serie().
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
