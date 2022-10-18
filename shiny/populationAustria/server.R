library(shiny)
library(data.table)
library(sf)
library(rdeck)
library(lubridate)

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
    
    level = input$level
    print(paste('level', level, 'selected'))
    levelShp = NULL
    if (level == 'state')
      levelShp = get('nuts2shp')
    if (level == 'district')
      levelShp = get('districtShp')
    if (level == 'commune')
      levelShp = get('communeShp')
    
    # get data
    pop1 = getPopulationData(year1, level)
    pop2 = getPopulationData(year2, level)
    
    print('pop and area...')
    pop = popChange(pop1, pop2)
    # order nuts2Shp by name and create new id-col with 1:n
    if(level == 'state'){
      levelShp = levelShp[order(levelShp$name),]
      levelShp$id = 1:nrow(levelShp)
    }
    pop = getAreaData(pop, levelShp, data.id = 'id', sf.id = 'id', breakSize = 1/input$breakSize)
    
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
        , get_line_width = get('communeLineWidth')
        , get_line_color = get('communeBorderColor')
        , get_fill_color = scale_color_category(col = 'cut'
                                                , palette = getColors(pop))
        , pickable = TRUE
        , tooltip = c(name, change)
      ) |>
      add_polygon_layer(
        id = regionLayerId
        , data = newRegion()
        , name = 'regions'
        , get_polygon = geometry
        , get_line_width = get('regionLineWidth')
        , get_line_color = get('regionBorderColor')
        , filled = FALSE
      )
  })
})