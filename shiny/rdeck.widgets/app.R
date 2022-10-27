library(shiny)
source(file = 'helper.R', encoding = 'UTF-8')

map = rdeck(map_style = NULL
  , theme = "light"
  , initial_bounds = sf::st_bbox(nc)
) %>%
  add_polygon_layer(
    data = nc
    , name = 'nc'
    , get_polygon = geometry
    , get_line_width = 200
    , get_line_color = '#b1b1b1' # lightgray
    , get_fill_color = '#545454'
  )

ui = fillPage(
  rdeckOutput("map", height = "100%"),
  absolutePanel(
    top = 10, left = 10,
    sliderInput("range", "value", 0, 1, c(0, 1), step = 0.1)
  )
)

# Define server logic required to draw a histogram
server = function(input, output) {

  output$map = renderRdeck({
    map
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
