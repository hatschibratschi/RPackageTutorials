library(shiny)
source(file = 'helper.R', encoding = 'UTF-8')

map = rdeck(map_style = NULL
  , theme = "light"
  , initial_bounds = sf::st_bbox(nc)
) |> 
  add_polygon_layer(
    data = ncCenter
    , name = 'ncCenter'
    , get_polygon = geometry
    , get_line_color = '#b1b1b1'
  ) |> 
  add_polygon_layer(
    data = nc
    , name = 'nc'
    , get_polygon = geometry
    , get_line_width = 200
    , get_line_color = '#b1b1b1' # lightgray
    , get_fill_color = scale_color_quantize(
      col = PERIMETER,
      palette = viridis(6, 0.8)
      )
    )


ui = navbarPage("App Title",
  tabPanel("Plot",
    rdeckOutput("map", height = "800px")
    # controls
    , absolutePanel(id ="controls"
                  , top = 80, left = 20 #, left = "auto", bottom = "auto", width = 'auto', height = 'auto'
                  , sliderInput(inputId = "testSlider"
                                , label = "Test Values"
                                , min = 1, max = 10, value = 5)
                  )
    # draggable info-box
    , absolutePanel(id = "infobox"
                  , class = "panel panel-default"
                  , fixed = TRUE
                  , draggable = TRUE
                  , top = 200
                  , left = 20
                  , right = "auto"
                  , bottom = "auto"
                  , width = 330
                  , height = "auto"
                  , h2("info")
                  )
    ),
  tabPanel("Summary"),
  tabPanel("Table")
)

# Define server logic required to draw a histogram
server = function(input, output) {
  output$map = renderRdeck({
    map
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
