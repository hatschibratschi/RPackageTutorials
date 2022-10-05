library(shiny)

# Make a palette of 40 colors
colors <- rainbow(40, alpha = NULL)
# Mirror the rainbow, so we cycle back and forth smoothly
colors <- c(colors, rev(colors[c(-1, -40)]))

ui <- fluidPage(
  tags$head(
    # Listen for background-color messages
    tags$script("
      Shiny.addCustomMessageHandler('background-color', function(color) {
        document.body.style.backgroundColor = color;
        document.body.innerText = color;
      });
    "),
    
    # A little CSS never hurt anyone
    tags$style("body { font-size: 40pt; text-align: center; }")
  )
)

server <- function(input, output, session) {
  pos <- 0L
  
  # Returns a hex color string, e.g. "#FF0073"
  nextColor <- function() {
    # Choose the next color, wrapping around to the start if necessary
    pos <<- (pos %% length(colors)) + 1L
    colors[[pos]]
  }
  
  observe({
    # Send the next color to the browser
    session$sendCustomMessage("background-color", nextColor())
    
    # Update the color every 100 milliseconds
    invalidateLater(100)
  })
}

shinyApp(ui, server)