#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("eruptions",
                        "Select eruptions:",
                        min = min(faithful$eruptions),
                        max = max(faithful$eruptions),
                        value = c(min(faithful$eruptions), max(faithful$eruptions)))
            , sliderInput("waiting",
                        "Select waiting:",
                        min = min(faithful$waiting),
                        max = max(faithful$waiting),
                        value = c(min(faithful$waiting), max(faithful$waiting)))
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("eruptionsPlot")
           , plotOutput("waitingPlot")
           , plotOutput("faithfulPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$eruptionsPlot <- renderPlot({
      
        # get data in range
        eruptions = faithful$eruptions[faithful$eruptions >= input$eruptions[1] & faithful$eruptions <= input$eruptions[2]]
        plot(eruptions, main = paste('number of eruptions: ', length(eruptions)))
    })
    output$waitingPlot <- renderPlot({
      
        # get data in range
        waiting = faithful$waiting[faithful$waiting >= input$waiting[1] & faithful$waiting <= input$waiting[2]]
        plot(waiting, main = paste('number of waiting: ', length(waiting)))
    })
    output$faithfulPlot <- renderPlot({
      
        # get data in range
        eruptions = faithful$eruptions[faithful$eruptions >= input$eruptions[1] & faithful$eruptions <= input$eruptions[2]]
        waiting = faithful$waiting[faithful$waiting >= input$waiting[1] & faithful$waiting <= input$waiting[2]]
        plot(x = eruptions, y = waiting)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
