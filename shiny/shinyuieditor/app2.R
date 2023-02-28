library(shiny)

ui = navbarPage("App Title",
           tabPanel("map"),
           tabPanel("data1"),
           tabPanel("data2")
)

server = function(input, output) {
}

shinyApp(ui = ui, server = server)
