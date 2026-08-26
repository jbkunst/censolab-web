# Antes de crear tools, consultamos una serie a mano.
desocupacion <- resolve_series(
  "desocupacion nacional",
  frequency = "MONTHLY"
)

serie_desocupacion <- "F049.DES.TAS.INE9.10.M"
serie_desocupacion |> describe_series()

datos_desocupacion <- get_series(
  serie_desocupacion
)
