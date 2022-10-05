library(shiny)
library(data.table)
library(sf)
library(rdeck)
library(lubridate)
library(ggplot2)

shinyServer(function(input, output) {

    output$distPlot <- renderRdeck({ # renderPlot
        year1 = input$years[1]
        year2 = input$years[2]
      
        # maps
        load('data/maps/communeShp.rdata')
        load('data/maps/nuts2shp.rdata')
  
        # get data
        pop1 = getPopulationData(year1)
        pop2 = getPopulationData(year2)
        
        print('pop and area...')
        pop = popChange(pop1, pop2)
        pop = getAreaData(pop, communeShp, data.id = 'gkz', sf.id = 'id')
        
        # ggplot() +
        #   geom_sf(data = pop, aes(fill = cut), color = NA) +
        #   geom_sf(data = nuts2shp, color = 'black', fill = NA) +
        #   scale_fill_manual(values = getColors(pop), name = 'pop rate') +
        #   ggtitle(paste('Population change from', year1, 'to', year2)) +
        #   theme_void()
        
        print('tidy shps...')
        pop = tidySfForRdeck(pop)
        nuts2shp = tidySfForRdeck(nuts2shp)
        
        pop$change = paste0(round(pop$diff, 2) * 100, '%')
        
        print('plot...')
        options(warn=-1)
        p = rdeck(map_style = NULL
              , initial_bounds = sf::st_bbox(pop)
              , theme = "light") |>
          add_polygon_layer(
            data = pop
            , name = 'Population change'
            , get_polygon = geometry
            , get_line_width = 100
            , get_line_color = '#b1b1b1'
            , get_fill_color = scale_color_category(col = 'cut'
                                                    , palette = getColors(pop))
            , pickable = TRUE
            , tooltip = c(name, change)
          ) |>
          add_polygon_layer(
            data = nuts2shp
            , name = 'nuts2 areas'
            , get_polygon = geometry
            , get_line_width = 200
            , get_line_color = '#010101'
            , filled = FALSE
          )
        options(warn=0)
        p
    })
})
