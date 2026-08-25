library(shiny)
library(bslib)
library(forecast)

# user interface ----------------------------------------------------------
ui <- page_sidebar(
  title = "App 01 · Widgets y outputs",
  fillable = TRUE,
  sidebar = sidebar(
    textInput("title", "Título", value = "Pasajeros aéreos"),
    sliderInput("n", "Cantidad de puntos", min = 24, max = 144, value = 48, step = 24),
    checkboxInput("forecast", "Mostrar pronóstico", value = FALSE)
  ),
  card(
    card_header(textOutput("plot_title")),
    plotOutput("plot")
  )
)

# server ------------------------------------------------------------------
server <- function(input, output, session) {

  output$plot_title <- renderText(paste0(input$title, " (", input$n, " observaciones)"))

  output$plot <- renderPlot({

    series <- head(AirPassengers, input$n)

    if (input$forecast) {
      plot(forecast::forecast(series), col = "#0E4F5A", fcol = "#0E4F5A",
        shadecols = c("#DCECEE", "#A9CED2"), bty = "l", main = "", xlab = NULL, ylab = "Miles")
    } else {
      plot(series, col = "#0E4F5A", lwd = 2,
        bty = "l", main = "", xlab = NULL, ylab = "Miles")
    }
  })
}

shinyApp(ui, server)
