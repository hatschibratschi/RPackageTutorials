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
    #, get_fill_color = '#545454'
    , get_fill_color = scale_color_quantize(
      col = PERIMETER,
      palette = viridis(6, 0.8)
    )
    
  )

ui = fillPage(
  rdeckOutput("map", height = "100%"),
  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE
                , draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto"
                , width = 330, height = "auto"
                
                , h2("info")
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
