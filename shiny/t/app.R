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
      sliderInput(
        inputId = "bins",
        label = "Number of bins",
        min = 1,
        max = 50,
        value = 30
      ),
      # selectInput(
      #   inputId = "color1",
      #   label = "Colors to choose",
      #   choices = c("grey", "lightgrey", "red", "black"),
      #   selected = "grey",
      #   multiple = FALSE,
      #   selectize = TRUE,
      #   width = NULL,
      #   size = NULL
      # ),
      radioButtons(inputId = "color", "Choose color",
                   choices = list("grey" = 'grey', "lightgrey" = 'lightgrey',
                                  "black" = 'black')
                   , selected = 'grey'),
      sliderInput(inputId = "eruptions",
                  "Select eruptions",
                  min = min(faithful$eruptions),
                  max = max(faithful$eruptions),
                  value = c(min(faithful$eruptions), max(faithful$eruptions))
      ),
      h3("Scatter plot"),
      checkboxInput(inputId = "showLine", 
                    label = "Show regression line", 
                    value = FALSE),
      #h3("Reset"),
      actionButton(inputId = "btnReset", "Reset")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput(outputId = "distPlot"),
      plotOutput(outputId = "eruptionsPlot"),
      plotOutput(outputId = "scatterPlot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  faithfulData = reactive({
    data = faithful[faithful$eruptions >= input$eruptions[1] & faithful$eruptions <= input$eruptions[2],]
    data
  })
  
  output$distPlot <- renderPlot({
    # generate bins based on input$bins from ui.R
    x = faithfulData()
    x = x$eruptions
    bins = seq(min(x), max(x), length.out = input$bins + 1)
    
    # print(paste('length of input:', length(input)))
    # print(paste('names:', names(input), collapse = ', '))
    
    # draw the histogram with the specified number of bins
    hist(
      x,
      breaks = bins,
      col = input$color,
      border = 'white',
      xlab = 'Eruption time (in mins)',
      main = 'Histogram of eruption times'
    )
  })
  
  output$eruptionsPlot <- renderPlot({
    
    # get data from reactive function
    data = faithfulData()
    data = data$eruptions
    plot(data, main = paste('Eruption time in mins.\nNumber of eruptions: ', length(data)))
  })
  
  output$scatterPlot <- renderPlot({
    
    data = faithfulData()
    reg1 <- lm(eruptions~waiting,data=data) 
    with(data,plot(waiting, eruptions))
    if(input$showLine){
      abline(reg1)
    }
  })
  
  observeEvent(input$btnReset, {
    updateNumericInput(session, "bins", value = 30)
    updateNumericInput(session, "eruptions", value = c(min(faithful$eruptions), max(faithful$eruptions)))
    updateRadioButtons(session, "color", selected = 'grey')
    updateCheckboxInput(session, 'showLine', value = FALSE)
    #updateTextInput(session, "mytext", value = "test")
  }) 
}

# Run the application 
shinyApp(ui = ui, server = server)
