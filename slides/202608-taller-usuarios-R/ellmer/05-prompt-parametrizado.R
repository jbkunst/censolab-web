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
