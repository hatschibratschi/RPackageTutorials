library(shiny)
library(data.table)
library(sf)
library(rdeck)
library(lubridate)
library(ggplot2)

#options(shiny.port = 5445)

shinyServer(function(input, output) {
  
  output$map <- renderRdeck({ # renderPlot
    map()
  })
  
  newRegion = reactive({
    region = input$region
    print(paste('region', region, 'selected'))
    shp = get(input$region) # get object named after 'region'. eg nuts2shp
    shp = tidySfForRdeck(shp)
    shp
  })
  
  newData <- reactive({
    year1 = input$years[1]
    year2 = input$years[2]
    
    # get data
    pop1 = getPopulationData(year1)
    pop2 = getPopulationData(year2)
    
    print('pop and area...')
    pop = popChange(pop1, pop2)
    pop = getAreaData(pop, communeShp, data.id = 'gkz', sf.id = 'id')
    
    print('tidy shps...')
    pop = tidySfForRdeck(pop)

    pop$change = paste0(round(pop$diff, 2) * 100, '%')
    pop
  })
  
  observe({
    pop = newData()
    rdeck_proxy("map") |>
      update_polygon_layer(
        id = communeLayerId
        , name = paste('Pop', input$years[1], input$years[2])
        , data = pop
        , get_polygon = geometry
        , get_line_width = 100
        , get_line_color = '#b1b1b1'
        , get_fill_color = scale_color_category(col = 'cut'
                                                , palette = getColors(pop))
        , pickable = TRUE
        , tooltip = c(name, change)
      )|>
      add_polygon_layer(
        id = regionLayerId
        , data = newRegion()
        , name = 'regions'
        , get_polygon = geometry
        , get_line_width = 200
        , get_line_color = '#010101'
        , filled = FALSE
      )
  })
})