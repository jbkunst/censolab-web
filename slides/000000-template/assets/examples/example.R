library(shiny)

ui <- fluidPage(
  textInput("name", "Nombre"),
  actionButton("greet", "Saludar"),
  textOutput("message")
)

server <- function(input, output, session) {
  greeting <- eventReactive(input$greet, {
    req(input$name)
    paste("Hola", input$name)
  })

  output$message <- renderText({
    greeting()
  })
}

shinyApp(ui, server)
