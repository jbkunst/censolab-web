# ¿Cómo consultamos la API del Banco Central "a mano"?
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
