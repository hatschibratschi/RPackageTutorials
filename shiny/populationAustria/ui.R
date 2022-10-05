library(shiny)
library(rdeck)

source('helper.R')

shinyUI(fluidPage(

    titlePanel("Austrian population change"),

    sidebarLayout(
        sidebarPanel(
            sliderInput("years",
                        "Select the years to compare:",
                        min = 2002,
                        max = 2021,
                        value = c(2001, 2021))
        ),

        mainPanel(
            #plotOutput("distPlot")
            rdeckOutput("distPlot")
        )
        
    )
))
