library(magick)

repo_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
deck_file <- file.path(repo_root, "slides", "202608-taller-usuarios-R", "index.qmd")

if (!file.exists(deck_file)) {
  stop("Ejecuta este script desde la raíz del repositorio censolab-web.")
}

hex_dir <- file.path(
  repo_root,
  "slides",
  "202608-taller-usuarios-R",
  "assets",
  "hex"
)
dir.create(hex_dir, recursive = TRUE, showWarnings = FALSE)

groups <- list(
  data = c("duckdb", "arrow", "dplyr"),
  application = c(
    "shiny", "bslib", "ellmer", "shinychat", "mapgl", "highcharter",
    "reactable"
  ),
  web = c("quarto", "ggplot2")
)

# Coordenadas en unidades de ancho y avance vertical de cada sticker.
# El primer elemento de cada grupo funciona como elemento principal.
layouts <- list(
  data = rbind(
    c(0.5, 0),
    c(0, 1), c(1, 1)
  ),
  application = rbind(
    c(1, 0),
    c(0.5, 1), c(1.5, 1), c(2.5, 1),
    c(0, 2), c(1, 2), c(2, 2)
  ),
  web = rbind(
    c(0, 0), c(1, 0)
  )
)

group_colours <- c(
  data = "#2F7883",
  application = "#00566B",
  web = "#6EAAB2"
)

manual_logos <- c(
  arrow = "https://arrow.apache.org/img/arrow-logo_hex_black-txt_white-bg.png",
  mapgl = "https://walker-data.com/mapgl/logo.png",
  reactable = "https://r-graph-gallery.com/img/r-package-img/reactable.png",
  bslib = "https://raw.githubusercontent.com/rstudio/hex-stickers/master/PNG/bslib.png",
  dplyr = "https://raw.githubusercontent.com/rstudio/hex-stickers/master/PNG/dplyr.png",
  quarto = "https://raw.githubusercontent.com/rstudio/hex-stickers/master/PNG/quarto.png"
)

find_installed_logo <- function(package) {
  candidates <- c(
    system.file("help", "figures", "logo.png", package = package),
    system.file("help", "figures", "logo.svg", package = package),
    system.file("html", "logo.png", package = package),
    system.file("html", "logo.svg", package = package)
  )
  candidates <- candidates[nzchar(candidates) & file.exists(candidates)]
  if (length(candidates)) candidates[[1]] else NA_character_
}

make_text_sticker <- function(package, colour, output) {
  size <- 600
  x <- c(300, 545, 545, 300, 55, 55)
  y <- c(18, 159, 441, 582, 441, 159)

  sticker <- image_blank(size, size, color = "none")
  canvas <- image_draw(sticker)
  polygon(x, y, col = colour, border = "white", lwd = 14)
  text(
    size / 2,
    size / 2,
    labels = package,
    col = "white",
    cex = if (nchar(package) > 9) 3.2 else 4.2,
    font = 2
  )
  dev.off()
  image_write(canvas, output, format = "png")
}

prepare_sticker <- function(package, group) {
  output <- file.path(hex_dir, paste0(group, "-", package, ".png"))

  if (package %in% names(manual_logos)) {
    downloaded <- tryCatch(
      {
        temporary_logo <- tempfile(fileext = ".img")
        on.exit(unlink(temporary_logo), add = TRUE)
        download.file(
          manual_logos[[package]],
          temporary_logo,
          mode = "wb",
          quiet = TRUE
        )
        logo_image <- image_read(temporary_logo)
        if (package == "mapgl") {
          logo_image <- image_trim(logo_image)
        }
        image_write(logo_image, output, format = "png")
        file.exists(output) && file.size(output) > 0
      },
      error = function(error) FALSE
    )

    if (downloaded) {
      return(output)
    }

    warning("No fue posible descargar el logo manual de ", package, ".")
  }

  logo <- find_installed_logo(package)

  if (!is.na(logo)) {
    image_read(logo) |>
      image_resize("600x600>") |>
      image_write(output, format = "png")
  } else {
    make_text_sticker(package, group_colours[[group]], output)
  }

  output
}

make_wall <- function(files, output, coords, sticker_width = 260) {
  stickers <- lapply(files, function(file) {
    scale <- if (grepl("duckdb", basename(file), fixed = TRUE)) 0.78 else 1
    image_width <- round(sticker_width * scale)
    image_height <- round(300 * scale)

    image_read(file) |>
      image_background("none") |>
      image_trim() |>
      image_resize(paste0(image_width, "x", image_height)) |>
      image_extent(
        geometry = paste0(sticker_width, "x300"),
        gravity = "center",
        color = "none"
      )
  })

  info <- image_info(stickers[[1]])
  sticker_height <- info$height
  row_step <- round(sticker_height * 0.74)
  column_step <- round(sticker_width * 0.94)
  wall_width <- round(max(coords[, 1]) * column_step + sticker_width)
  wall_height <- round(max(coords[, 2]) * row_step + sticker_height)
  wall <- image_blank(wall_width, wall_height, color = "none")

  for (i in seq_along(stickers)) {
    x <- coords[i, 1] * column_step
    y <- coords[i, 2] * row_step
    wall <- image_composite(
      wall,
      stickers[[i]],
      operator = "over",
      offset = paste0("+", round(x), "+", round(y))
    )
  }

  image_write(wall, output, format = "png")
}

for (group in names(groups)) {
  files <- vapply(groups[[group]], prepare_sticker, character(1), group = group)
  make_wall(
    files,
    file.path(hex_dir, paste0("wall-", group, ".png")),
    coords = layouts[[group]]
  )
}

message("Murales generados en: ", hex_dir)
