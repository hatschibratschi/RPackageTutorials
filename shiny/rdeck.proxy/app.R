library(shiny)
library(dplyr)
library(rdeck)
library(h3jsr)
library(viridis)

# objects & functions -----------------------------------------------------
h3_data <- tibble(
  hexagon = get_res0() %>%
    get_children(res = 3) %>%
    unlist() %>%
    unique(),
  value = runif(length(hexagon))
)

map <- rdeck() %>%
  add_h3_hexagon_layer(
    id = "h3_hexagon",
    name = "hexagons",
    data = h3_data,
    get_fill_color = scale_color_quantize(
      col = value,
      palette = viridis(6, 0.3)
    ),
    pickable = TRUE,
    auto_highlight = TRUE,
    tooltip = c(hexagon, value)
  )

# ui ----------------------------------------------------------------------
ui <- fillPage(
  rdeckOutput("map", height = "100%"),
  absolutePanel(
    top = 10, left = 10,
    sliderInput("range", "value", 0, 1, c(0, 1), step = 0.1)
  )
)

# server ------------------------------------------------------------------
server <- function(input, output, session) {
  
  output$map <- renderRdeck({
    map
  })
  
  filtered_data <- reactive({
    h3_data %>%
      filter(value >= input$range[1] & value <= input$range[2])
  })
  
  checkClick = reactive({
    print('clicked_object: ')
    o = get_clicked_object('map')
    print(sapply(o, eval))
    print('clicked_coordinates: ')
    l = get_clicked_coordinates('map')
    print(sapply(l, eval))
  })
  
  observe({
    checkClick()
    rdeck_proxy("map") %>%
      add_h3_hexagon_layer(
        id = "h3_hexagon",
        name = "hexagons",
        data = filtered_data(),
        get_fill_color = scale_color_quantize(
          col = value,
          palette = cividis(6, 0.3)
        ),
        pickable = TRUE,
        auto_highlight = TRUE,
        tooltip = c(hexagon, value)
      )
  })
}

app <- shinyApp(ui, server)