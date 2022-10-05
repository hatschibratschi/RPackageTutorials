library(shiny)
library(rdeck)

source('helper.R')

shinyUI = fillPage(
  rdeckOutput("map", height = "100%"),
  absolutePanel(
    top = 10, left = 10,
    sliderInput("years"
                , "Select the years to compare:"
                , min = 2002
                , max = 2021
                , value = c(2002, 2021)
                , width = '500px'
                , sep = ''
    )
  )
)
