library(shiny)
library(rdeck)

source('helper.R')

shinyUI = fillPage(
  rdeckOutput("map", height = "100%"),
  absolutePanel(
    top = 10, left = 10
    , sliderInput("years"
                , "years to compare"
                , min = 2002
                , max = 2021
                , value = c(2002, 2021)
                , width = '500px'
                , sep = ''
    )
    , sliderInput("breakSize"
                  , "more <- or less -> groups"
                  , min = 0.025
                  , max = 0.25
                  , value = 0.1)
    , radioButtons("region", label = "region borders",
                   choices = list("states" = 'nuts2shp', "districts" = 'districtShp'), 
                   selected = 'nuts2shp')
    , radioButtons("level", label = "aggregation level",
                   choices = list("state" = 'state', "district" = 'district', "commune" = 'commune'), 
                   selected = 'commune')
  )
)
