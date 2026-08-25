# Genera el diagrama SVG del flujo de cambios y despliegue.
# El isotipo se incrusta dentro del SVG final: no queda como dependencia externa.

repo_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
index_qmd <- file.path(
  repo_root,
  "slides",
  "202608-taller-usuarios-R",
  "index.qmd"
)

if (!file.exists(index_qmd)) {
  stop("Ejecuta este script desde la raíz del repositorio censolab-web.")
}

logo_path <- file.path(
  repo_root,
  "assets",
  "brand",
  "censolab-logo-white.svg"
)
output_dir <- file.path(
  repo_root,
  "slides",
  "202608-taller-usuarios-R",
  "assets",
  "diagrams"
)
output_path <- file.path(output_dir, "deployment-flow.svg")
vertical_output_path <- file.path(output_dir, "deployment-flow-vertical.svg")

logo_svg <- paste(readLines(logo_path, warn = FALSE), collapse = "\n")
logo_content <- sub("^[\\s\\S]*?<svg[^>]*>", "", logo_svg, perl = TRUE)
logo_content <- sub("</svg>[\\s\\S]*$", "", logo_content, perl = TRUE)

logo <- function(x, y, size = 62) {
  sprintf(
    '<svg x="%s" y="%s" width="%s" height="%s" viewBox="194 187 634 634">%s</svg>',
    x, y, size, size, logo_content
  )
}

svg <- sprintf(
'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1500 430" role="img" aria-labelledby="title desc">
  <title id="title">Flujo de cambios y despliegue</title>
  <desc id="desc">Una rama feature pasa a dev, se despliega en CensoLabDev, se valida y luego pasa a main y CensoLab.</desc>
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="9" markerHeight="9" orient="auto-start-reverse">
      <path d="M 0 0 L 10 5 L 0 10 z" fill="#6AAAB2"/>
    </marker>
    <style>
      @import url("https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300;400;600&amp;display=swap");
      text { font-family: "IBM Plex Sans", sans-serif; font-weight: 300; fill: #202326; }
      .group { fill: #F2F7F7; stroke: #6AAAB2; stroke-width: 2; }
      .group-title { fill: #0E4F5A; font-size: 18px; text-anchor: middle; }
      .node { fill: #FFFFFF; stroke: #0E4F5A; stroke-width: 2; }
      .node-text { font-size: 20px; text-anchor: middle; dominant-baseline: middle; }
      .branch-label { font-weight: 600; }
      .edge { fill: none; stroke: #6AAAB2; stroke-width: 2; marker-end: url(#arrow); }
      .edge.return { stroke-dasharray: 5 4; }
      .edge-label { fill: #4D6266; font-size: 17px; text-anchor: middle; }
      .environment { fill: #0E4F5A; stroke: #0E4F5A; stroke-width: 2; }
      .environment-label { fill: #FFFFFF; font-size: 13px; font-weight: 400; text-anchor: middle; }
    </style>
  </defs>

  <rect class="group" x="20" y="40" width="220" height="350" rx="5"/>
  <text class="group-title" x="130" y="70">CAMBIOS</text>

  <rect class="group" x="270" y="40" width="790" height="350" rx="5"/>
  <text class="group-title" x="665" y="70">VALIDACIÓN</text>

  <rect class="group" x="1090" y="40" width="390" height="350" rx="5"/>
  <text class="group-title" x="1285" y="70">PUBLICACIÓN</text>

  <rect class="node" x="60" y="105" width="120" height="65"/>
  <text class="node-text" x="120" y="138">feature/a</text>
  <rect class="node" x="60" y="240" width="120" height="65"/>
  <text class="node-text" x="120" y="273">feature/b</text>

  <rect class="node" x="330" y="170" width="80" height="70"/>
  <text class="node-text branch-label" x="370" y="205">dev</text>

  <rect class="environment" x="535" y="153" width="104" height="104" rx="5"/>
  %s
  <text class="environment-label" x="587" y="247">DEV</text>

  <path class="node" d="M 820 135 L 930 205 L 820 275 L 710 205 Z"/>
  <text class="node-text" x="820" y="205">Validación</text>

  <rect class="node" x="1140" y="170" width="90" height="70"/>
  <text class="node-text branch-label" x="1185" y="205">main</text>

  <rect class="environment" x="1330" y="153" width="104" height="104" rx="5"/>
  %s

  <path class="edge" d="M 180 138 L 318 186"/>
  <text class="edge-label" x="245" y="116"><tspan x="245">Pull</tspan><tspan x="245" dy="19">request</tspan></text>
  <path class="edge" d="M 180 273 L 318 224"/>
  <text class="edge-label" x="245" y="302"><tspan x="245">Pull</tspan><tspan x="245" dy="19">request</tspan></text>

  <path class="edge" d="M 410 205 H 523"/>
  <text class="edge-label" x="472" y="177"><tspan x="472">deploy</tspan><tspan x="472" dy="19">automático</tspan></text>

  <path class="edge" d="M 639 205 H 698"/>
  <path class="edge" d="M 930 205 H 1128"/>
  <text class="edge-label" x="1035" y="177"><tspan x="1035">Aprobado:</tspan><tspan x="1035" dy="19">PR dev → main</tspan></text>

  <path class="edge" d="M 1230 205 H 1318"/>
  <text class="edge-label" x="1280" y="177"><tspan x="1280">deploy</tspan><tspan x="1280" dy="19">automático</tspan></text>

  <path class="edge return" d="M 780 255 C 680 360, 310 365, 190 280"/>
  <text class="edge-label" x="485" y="345"><tspan x="485">Requiere</tspan><tspan x="485" dy="19">ajustes</tspan></text>
</svg>',
  logo(556, 163),
  logo(1351, 174)
)

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
writeLines(svg, output_path, useBytes = TRUE)
message("SVG generado en: ", output_path)

vertical_svg <- sprintf(
'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 760" role="img" aria-labelledby="title desc">
  <title id="title">Flujo vertical de cambios y despliegue</title>
  <desc id="desc">Una rama feature pasa a dev, se despliega en CensoLabDev, se valida y luego pasa a main y CensoLab.</desc>
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="9" markerHeight="9" orient="auto-start-reverse">
      <path d="M 0 0 L 10 5 L 0 10 z" fill="#6AAAB2"/>
    </marker>
    <style>
      @import url("https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300;400;600&amp;display=swap");
      text { font-family: "IBM Plex Sans", sans-serif; font-weight: 300; fill: #202326; }
      .group { fill: #F2F7F7; stroke: #6AAAB2; stroke-width: 2; }
      .group-title { fill: #0E4F5A; font-size: 17px; text-anchor: middle; }
      .node { fill: #FFFFFF; stroke: #0E4F5A; stroke-width: 2; }
      .node-text { font-size: 19px; text-anchor: middle; dominant-baseline: middle; }
      .branch-label { font-weight: 600; }
      .edge { fill: none; stroke: #6AAAB2; stroke-width: 2; marker-end: url(#arrow); }
      .edge.return { stroke-dasharray: 5 4; }
      .edge-label { fill: #4D6266; font-size: 15px; }
      .environment { fill: #0E4F5A; stroke: #0E4F5A; stroke-width: 2; }
      .environment-label { fill: #FFFFFF; font-size: 12px; font-weight: 400; text-anchor: middle; }
    </style>
  </defs>

  <rect class="group" x="75" y="15" width="470" height="135" rx="5"/>
  <text class="group-title" x="310" y="42">CAMBIO</text>
  <rect class="node" x="245" y="62" width="130" height="62"/>
  <text class="node-text" x="310" y="93">feature/*</text>

  <rect class="group" x="75" y="175" width="470" height="370" rx="5"/>
  <text class="group-title" x="155" y="202">VALIDACIÓN</text>
  <rect class="node" x="265" y="230" width="90" height="58"/>
  <text class="node-text branch-label" x="310" y="259">dev</text>
  <rect class="environment" x="258" y="330" width="104" height="104" rx="5"/>
  %s
  <text class="environment-label" x="310" y="424">DEV</text>
  <path class="node" d="M 310 453 L 390 494 L 310 535 L 230 494 Z"/>
  <text class="node-text" x="310" y="494">Validación</text>

  <rect class="group" x="75" y="575" width="470" height="170" rx="5"/>
  <text class="group-title" x="170" y="602">PUBLICACIÓN</text>
  <rect class="node" x="155" y="650" width="90" height="58"/>
  <text class="node-text branch-label" x="200" y="679">main</text>
  <rect class="environment" x="375" y="627" width="104" height="104" rx="5"/>
  %s

  <path class="edge" d="M 310 124 V 230"/>
  <text class="edge-label" x="330" y="151"><tspan x="330">Pull request</tspan><tspan x="330" dy="18">a dev</tspan></text>
  <path class="edge" d="M 310 288 V 330"/>
  <text class="edge-label" x="325" y="315">deploy automático</text>
  <path class="edge" d="M 310 434 V 453"/>
  <path class="edge" d="M 310 535 C 310 590, 250 620, 215 650"/>
  <text class="edge-label" x="380" y="545"><tspan x="380">Aprobado:</tspan><tspan x="380" dy="18">PR dev → main</tspan></text>
  <path class="edge" d="M 245 679 H 375"/>
  <text class="edge-label" x="310" y="663" text-anchor="middle">deploy automático</text>
  <path class="edge return" d="M 230 494 C 105 475, 105 105, 245 93"/>
  <text class="edge-label" x="103" y="330"><tspan x="103">Requiere</tspan><tspan x="103" dy="18">ajustes</tspan></text>
</svg>',
  logo(279, 343, 62),
  logo(396, 648, 62)
)

writeLines(vertical_svg, vertical_output_path, useBytes = TRUE)
message("SVG vertical generado en: ", vertical_output_path)
