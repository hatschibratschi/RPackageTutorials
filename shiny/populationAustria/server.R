library(shiny)
library(data.table)
library(sf)
library(rdeck)
library(lubridate)
library(ggplot2)

shinyServer(function(input, output) {

    output$distPlot <- renderPlot({
        year1 = input$years[1]
        year2 = input$years[2]
      
        # maps
        load('data/maps/communeShp.rdata')
        load('data/maps/nuts2shp.rdata')
  
        # get data
        pop1 = getPopulationData(year1)
        pop2 = getPopulationData(year2)
        
        pop = popChange(pop1, pop2)
        pop = getAreaData(pop, communeShp, data.id = 'gkz', sf.id = 'id')
        
        print('plot data...')
        ggplot() +
          geom_sf(data = pop, aes(fill = cut), color = NA) +
          geom_sf(data = nuts2shp, color = 'black', fill = NA) +
          scale_fill_manual(values = getColors(pop), name = 'pop rate') +
          ggtitle(paste('Population change from', year1, 'to', year2)) +
          theme_void()
        
        
    })
})
