library(shiny)

radioLab <-list(tags$div(align = 'left', 
                         class = 'multicol', 
                         radioButtons(inputId  = 'typeofanalysis', 
                                      label = "TRIPS & TRAVELS",
                                      choices  = c("OVERNIGHT TRIPS - LAST 365 DAYS","OVERNIGHT TRIPS - LAST 30 DAYS", "SAMEDAY TRIPS - LAST 30 DAYS","LONG DURATION TRIPS - 180-365 DAYS"),
                                      selected = "OVERNIGHT TRIPS - LAST 365 DAYS",
                                      inline   = FALSE)
                         , style = "font-size:75%")) 

multicolLab <- list(tags$head(tags$style(HTML("
                                       .multicol { 
                                       height: 200px;
                                       width: 600px;
                                       -webkit-column-count: 2; /* Chrome, Safari, Opera */ 
                                       -moz-column-count: 2;    /* Firefox */ 
                                       column-count: 2; 
                                       -moz-column-fill: auto;
                                       -column-fill: auto;
                                       } 
                                       ")))) 

ui <- shinyUI(
  navbarPage("TITLE",
             tabPanel("TABULATE",
                      multicolLab,
                      fluidRow(    
                        column(width = 6, radioLab, align = "center"),
                        column(6)
                      )
             )))

server <- shinyServer(function(input, output) {
  
})

shinyApp(ui,server)