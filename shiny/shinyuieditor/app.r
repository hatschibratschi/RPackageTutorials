library(DT)
library(shiny)
library(gridlayout)
library(ggplot2)

ui <- navbarPage(
  title = "Chick Weights",
  selected = "Line Plots",
  collapsible = TRUE,
  theme = bslib::bs_theme(),
  tabPanel(
    title = "Line Plots",
    grid_container(
      layout = "num_chicks linePlots",
      row_sizes = "1fr",
      col_sizes = c(
        "250px",
        "1fr"
      ),
      gap_size = "10px",
      grid_card(
        area = "num_chicks",
        sliderInput(
          inputId = "numChicks",
          label = "Number of chicks",
          min = 1L,
          max = 15L,
          value = 5L,
          step = 1L,
          width = "100%"
        )
      ),
      grid_card_plot(area = "linePlots")
    )
  ),
  tabPanel(
    title = "Distributions",
    grid_container(
      layout = c(
        "area1",
        "area0"
      ),
      row_sizes = c(
        "165px",
        "1fr"
      ),
      col_sizes = "1fr",
      gap_size = "10px",
      grid_card(
        area = "area0",
        DTOutput(
          outputId = "myTable",
          width = "100%"
        )
      ),
      grid_card(
        area = "area1",
        grid_container(
          layout = "area0 area1 area2",
          row_sizes = "1fr",
          col_sizes = c(
            "1fr",
            "1fr",
            "1fr"
          ),
          gap_size = "10px",
          grid_card(
            area = "area0",
            textInput(
              inputId = "myTextInput",
              label = "Text Input",
              value = ""
            )
          ),
          grid_card(
            area = "area1",
            textInput(
              inputId = "myTextInput",
              label = "Text Input",
              value = ""
            )
          ),
          grid_card(
            area = "area2",
            textInput(
              inputId = "myTextInput",
              label = "Text Input",
              value = ""
            )
          )
        )
      )
    )
  )
)

server <- function(input, output) {
  output$linePlots <- renderPlot({
    obs_to_include <- as.integer(ChickWeight$Chick) <= input$numChicks
    chicks <- ChickWeight[obs_to_include, ]

    ggplot(
      chicks,
      aes(
        x = Time,
        y = weight,
        group = Chick
      )
    ) +
      geom_line(alpha = 0.5) +
      ggtitle("Chick weights over time")
  })

  output$dists <- renderPlot({
    ggplot(
      ChickWeight,
      aes(x = weight)
    ) +
      facet_wrap(input$distFacet) +
      geom_density(fill = "#fa551b", color = "#ee6331") +
      ggtitle("Distribution of weights by diet")
  })
}

shinyApp(ui, server)
