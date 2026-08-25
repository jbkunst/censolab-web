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
